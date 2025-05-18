
import 'package:awaken_quest/utils/dialog/Error_Dialog.dart';
import 'package:awaken_quest/utils/items/Level_Info.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:intl/intl.dart';

import '../../utils/handler/Hive_Handler.dart';
import '../../utils/manager/Title_Integration.dart';

class QuestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  RxString today = ''.obs;
  RxList<QuestModel> todayMainMissions = <QuestModel>[].obs;
  RxList<QuestModel> todaySubMissions = <QuestModel>[].obs;
  RxList<QuestModel> todayCustomMissions = <QuestModel>[].obs;

  @override
  void onInit() {
    getTodayQuest();
    super.onInit();
  }

  RxBool loading = false.obs;

  Future<void> getTodayQuest() async {
    loading.value = true;
    //시간 적용을 위한 딜레이
    await Future.delayed(const Duration(seconds: 1));

    today.value = DateFormat('yyyyMMdd').format(DateTime.now().toLocal());
    todayMainMissions = <QuestModel>[].obs;
    todaySubMissions = <QuestModel>[].obs;
    todayCustomMissions = <QuestModel>[].obs;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        DialogFrame.errorHandler("시스템과 상태창의 연결이 끊겼습니다");
        return;
      }

      bool initialized = false;

      while (!initialized) {
        final data = await _firestore
            .collection('users')
            .doc(uid)
            .collection("missions")
            .doc(today.value)
            .get();

        if (data.exists && data.data() != null) {
          final rawData = data.data()!;

          todayMainMissions = List<Map<String, dynamic>>.from(rawData['main'])
              .map((e) => QuestModel.fromJson(e))
              .toList().obs;

          todaySubMissions = List<Map<String, dynamic>>.from(rawData['sub'])
              .map((e) => QuestModel.fromJson(e))
              .toList().obs;

          todayCustomMissions =
              List<Map<String, dynamic>>.from(rawData['custom'] ?? [])
                  .map((e) => QuestModel.fromJson(e))
                  .toList().obs;

          initialized = true;
        } else {
          final res = await createTodayQuest();
          if (!res) {
            break; // 실패 시 루프 중단
          }
          // 루프 반복으로 get 재시도
        }
      }
    } on FirebaseException catch (error) {
      print("파이어베이스 오류 $error");
      FirebaseExceptionHandler.firebaseGeneralExceptionHandler(error.code);
    } catch (e) {
      print("기타 오류 $e");
    } finally {
      loading.value = false;
    }
  }


  //오늘 퀘스트 할당
  Future<bool> createTodayQuest() async {
    bool creating = false;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("시스템과 상태창 연결이 불안정합니다");

      final job = Get.find<UserController>().user.value?.job;
      if (job == null) throw Exception("직업 정보가 없습니다");

      final mainMissions = JobInfo.mainMissions[job];
      final subMissions = JobInfo.subMissions[job];
      
      if (mainMissions == null || subMissions == null) {
        throw Exception('시스템과 상태창의 연결이 불안정합니다');
      }


      final todayDoc = _firestore
          .collection("users")
          .doc(uid)
          .collection("missions")
          .doc(today.value);

      final randomMissions = List.of(subMissions)..shuffle();
      final selectedMissions = randomMissions.take(2).toList();

      await todayDoc.set({
        'main': mainMissions.map((e) => toMap(e, 'm')).toList(),
        'sub': selectedMissions.map((e) => toMap(e, 's')).toList(),
      });

      creating = true;
    } on FirebaseException catch (error) {
      print("사용자 퀘스트 만들던중 파이어베이스 오류 발생: $error");
      FirebaseExceptionHandler.firebaseGeneralExceptionHandler(error.code);
    } catch (error) {
      print("사용자 퀘스트 만들던중 오류 발생: $error");
      DialogFrame.errorHandler(error.toString());
    }

    return creating;
  }

  //미션 클리어
  Future<void> missionClear(QuestModel item, String type) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        DialogFrame.errorHandler("시스템과 상태창의 연결이 끊겼습니다");
        return;
      }

      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection("missions")
          .doc(today.value);

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        print("미션 문서가 존재하지 않습니다.");
        return;
      }

      final data = docSnapshot.data();
      final int id = item.id;

      final List<dynamic> missions = List.from(data?[type] ?? []);
      print(data);
      final index = missions.indexWhere((mission) => mission['id'] == id);

      if (index != -1) {

        //사용자의 수치변경
        final possible = await calculateUserStat(item);

        if(possible != null){
          Get.dialog(ErrorDialog(error: possible));
          return;
        }


        missions[index]['isClear'] = Timestamp.now();

        await docRef.update({
          type: missions,
        });

        final updatedList = missions
            .map((e) => QuestModel.fromJson(e))
            .toList();

        // 상태 업데이트 - 중요한 부분
        if (type == "main") {
          todayMainMissions.clear(); // 기존 목록 클리어
          todayMainMissions.addAll(updatedList); // 새 목록 추가
        } else if (type == "sub") {
          todaySubMissions.clear();
          todaySubMissions.addAll(updatedList);
        } else if (type == "custom") {
          todayCustomMissions.clear();
          todayCustomMissions.addAll(updatedList);
        }

        // 미션 완료 후 칭호 체크
        final userController = Get.find<UserController>();
        await TitleIntegration().integrateWithMissionComplete(
            userController,
            this,
            type,
            userController.user.value?.job ?? '전사'
        );

        // 미션 완료 알림 표시 (선택사항)
        Get.snackbar(
          '미션 완료!',
          '미션을 성공적으로 완료했습니다',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.7),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );

      } else {
        print("해당 id의 미션을 찾을 수 없습니다.");
      }
    } catch (e) {
      print("미션 완료 처리 중 오류: $e");
    }
  }

  //레벨 판정
  calculateUserStat(QuestModel item) async {
    final userController = Get.find<UserController>();
    final user = userController.user.value!;

    final my_mp = user.mp;
    final my_hp = user.hp;

    final hp = JobInfo.plusHp.contains(item.id) ? item.hp : -(item.hp);
    final mp = JobInfo.plusMp.contains(item.id) ? item.mp : -(item.mp);

    final new_hp = my_hp + hp;
    final new_mp = my_mp + mp;

    //가능한지 계산
    if(new_hp < 0 && new_mp > 0){
      return "미션을 완료하기위한 hp(${new_hp.abs()})가 부족합니다";
    }else if(new_mp < 0 && new_hp > 0){
      return "미션을 완료하기위한 mp(${new_mp.abs()})가 부족합니다";
    }else if(new_mp < 0 && new_hp < 0){
      return "미션을 완료하기위한 hp(${new_hp.abs()}), mp(${new_mp.abs()})가 부족합니다";
    }

    //기록 업데이트
    await userController.updateCleared();

    final level = user.level;
    final gained_exp = item.exp;


    final max_exp = LevelInfo.maxExpPrev + (LevelInfo.baseExp + level * LevelInfo.factor);
    final total_exp = user.exp + gained_exp;


    if (total_exp >= max_exp) {
      final extra_stat = user.extraStat + 1;
      final new_exp = total_exp - max_exp;
      final new_level = level + 1;

      // 1. Firestore 업데이트
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'level': new_level,
        'exp': new_exp,
        'hp' : new_hp,
        'mp' : new_mp,
        'extraStat' : extra_stat
      });

      // 2. 로컬 모델 업데이트
      userController.updateUser(
          level: new_level,
          exp: new_exp.toInt(),
          hp: new_hp,
          mp: new_mp,
          extraStat: extra_stat
      );

    } else {
      // 1. Firestore 업데이트
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'exp': total_exp,
        'hp' : new_hp,
        'mp' : new_mp
      });

      // 2. 로컬 모델 업데이트
      userController.updateUser(
          exp: total_exp.toInt(),
          hp: new_hp,
          mp: new_mp
      );
    }
  }

  //미션 생성용
  Map<String, dynamic> toMap(Mission mission, String type){
    return {
      'type' : type,
      'id' : mission.id,
      'isClear' : null,
    };
  }


  // 새 커스텀 미션 생성 및 저장
  Future<Mission> createCustomMission(String title, int amount, String unit) async {
    try {
      // 새 미션 생성
      final mission = Mission.toMission(
          title: title,
          baseAmount: amount,
          unit: unit
      );

      // Hive에 저장
      await HiveHandler.saveCustomMission(mission);

      // Get.find로 UserController 찾아서 커스텀 목록 업데이트
      final userController = Get.find<UserController>();
      await userController.loadCustomTodoList();

      return mission;
    } catch (e) {
      print("커스텀 미션 생성 오류: $e");
      DialogFrame.errorHandler("미션 생성 중 오류가 발생했습니다");
      rethrow;
    }
  }

// 미션을 오늘의 미션 목록에 추가 (기존 미션 또는 새 미션)
  Future<void> addMissionToToday(int missionId) async {
    try {
      // 이미 추가된 미션인지 확인
      final alreadyExists = todayCustomMissions.any((m) => m.id == missionId);
      if (alreadyExists) {
        Get.snackbar(
          '알림',
          '이미 추가된 미션입니다',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.7),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      // 오늘의 미션 목록에 추가
      final customMission = QuestModel.fromJson({
        'type': 'c',
        'id': missionId,
        'isClear': null,
      });

      todayCustomMissions.add(customMission);

      // Firebase에도 저장
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final docRef = _firestore
            .collection('users')
            .doc(uid)
            .collection("missions")
            .doc(today.value);

        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          List<Map<String, dynamic>> customMissions = [];

          if (data != null && data.containsKey('custom')) {
            customMissions = List<Map<String, dynamic>>.from(data['custom'] ?? []);
          }

          customMissions.add({
            'type': 'c',
            'id': missionId,
            'isClear': null,
          });

          await docRef.update({
            'custom': customMissions,
          });
        } else {
          // 오늘 문서가 없는 경우, 먼저 기본 문서 생성 후 다시 시도
          await createTodayQuest();
          await addMissionToToday(missionId);
          return;
        }
      }

      Get.snackbar(
        '미션 추가',
        '새로운 미션이 추가되었습니다',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );

    } catch (e) {
      print("오늘의 미션 추가 오류: $e");
      DialogFrame.errorHandler("미션 추가 중 오류가 발생했습니다");
    }
  }

// 기존 함수 - 새 미션 생성 후 바로 오늘의 미션에 추가
  Future<void> addCustomMission(String title, int amount, String unit) async {
    try {
      // 새 미션 생성 및 저장
      final mission = await createCustomMission(title, amount, unit);

      // 오늘의 미션에 추가
      await addMissionToToday(mission.id);
    } catch (e) {
      print("커스텀 미션 추가 오류: $e");
      DialogFrame.errorHandler("미션 추가 중 오류가 발생했습니다");
    }
  }
}
