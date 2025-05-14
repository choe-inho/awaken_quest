
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:intl/intl.dart';

import '../../utils/manager/Title_Integration.dart';

class QuestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxString today = ''.obs;
  List<Rx<QuestModel>> todayMainMissions = [];
  List<Rx<QuestModel>> todaySubMissions = [];
  List<Rx<QuestModel>> todayCustomMissions = [];

  @override
  void onInit() {
    today.value = DateFormat('yyyyMMdd').format(DateTime.now());
    getTodayQuest();
    super.onInit();
  }

  RxBool loading = false.obs;

  Future<void> getTodayQuest() async {
    loading.value = true;

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
          print(data.data());

          todayMainMissions = List<Map<String, dynamic>>.from(rawData['main'])
              .map((e) => Rx<QuestModel>(QuestModel.fromJson(e)))
              .toList();

          todaySubMissions = List<Map<String, dynamic>>.from(rawData['sub'])
              .map((e) => Rx<QuestModel>(QuestModel.fromJson(e)))
              .toList();

          todayCustomMissions =
              List<Map<String, dynamic>>.from(rawData['custom'] ?? [])
                  .map((e) => Rx<QuestModel>(QuestModel.fromJson(e)))
                  .toList();

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
      final index = missions.indexWhere((mission) => mission['id'] == id);

      if (index != -1) {
        missions[index]['isClear'] = Timestamp.now();

        await docRef.update({
          type: missions,
        });

        final updatedList = missions
            .map((e) => Rx<QuestModel>(QuestModel.fromJson(e)))
            .toList();

        print("미션 완료 처리 완료 (id: $id, type: $type)");

        if (type == "main") {
          todayMainMissions = updatedList;
        } else if (type == "sub") {
          todaySubMissions = updatedList;
        } else if (type == "custom") {
          todayCustomMissions = updatedList;
        }

        // 미션 완료 후 칭호 체크
        final userController = Get.find();
        await TitleIntegration().integrateWithMissionComplete(
            this,
            type,
            userController.user.value?.job ?? '전사'
        );

      } else {
        print("해당 id의 미션을 찾을 수 없습니다.");
      }
    } catch (e) {
      print("미션 완료 처리 중 오류: $e");
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
}
