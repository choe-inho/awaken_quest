import 'dart:async';
import 'package:awaken_quest/utils/dialog/Dialog_Frame.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppController extends GetxController with WidgetsBindingObserver {
  RxInt progress = 0.obs;
  // 앱 상태
  final appLifecycleState = Rx<AppLifecycleState>(AppLifecycleState.resumed);
  // 인터넷 연결 상태
  final isConnected = false.obs;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final firestoreAppVersion = ''.obs;
  final localAppVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> appControllerInit() async{
    _initConnectivityListener(); //인터넷 연결확인
    await _loadAppVersions(); //현재 앱 버전 상태확인
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
          // 하나라도 연결된 게 있으면 연결 상태 true
          isConnected.value = results.any((r) => r != ConnectivityResult.none);
    });

    // 초기 상태 체크
    Connectivity().checkConnectivity().then((results) {
      isConnected.value = results.any((r) => r != ConnectivityResult.none);
    });
  }

  Future<void> _loadAppVersions() async {
    try {
      // Firestore에서 앱 버전 가져오기
      final doc = await FirebaseFirestore.instance
          .collection('app_info')
          .doc('current')
          .get();

      if (doc.exists && doc.data()?['version'] != null) {
        firestoreAppVersion.value = doc['version'];
      }

      final bool requiredUpdate = (doc.exists && doc.data()?['requiredUpdate'] != null) ? doc['requiredUpdate'] : false;

      // 로컬 앱 버전 가져오기
      final info = await PackageInfo.fromPlatform();
      localAppVersion.value = info.buildNumber;

      if(int.parse(localAppVersion.value) < int.parse(firestoreAppVersion.value) && requiredUpdate){ //현재 버전이 더 낮고 업데이트가 필수라면?
        DialogFrame.showUpdateDialog();
      }else{
        progress.value += 50;
      }
    } catch (e) {
      print('앱 버전 로딩 실패: $e');
    }
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appLifecycleState.value = state;
    debugPrint('🔄 앱 라이프사이클 상태 변경: $state');
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.onClose();
  }


}
