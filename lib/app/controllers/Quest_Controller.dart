
import 'package:awaken_quest/utils/items/Level_Info.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:intl/intl.dart';

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
    today.value = DateFormat('yyyyMMdd').format(DateTime.now().toLocal());
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
        //사용자의 수치변경
        await calculateUserStat(item);

        final userController = Get.find<UserController>();
        await TitleIntegration().integrateWithMissionComplete(
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
    final level = user.level;
    final gained_exp = item.exp;
    final rand = Random();
    final my_mp = user.mp;
    final my_hp = user.hp;

    final hp = JobInfo.plusHp.contains(item.id) ? rand.nextInt(9) + 1 : -(rand.nextInt(14) + 1);
    final mp = rand.nextDouble() <= 0.2 ? rand.nextInt(9) + 1 : -(rand.nextInt(14)+1);

    final new_hp = my_hp - hp;
    final new_mp = my_mp - mp;

    final max_exp = LevelInfo.maxExpPrev + (LevelInfo.baseExp + level * LevelInfo.factor);
    final total_exp = user.exp + gained_exp;

    if (total_exp >= max_exp) {
      final new_exp = total_exp - max_exp;
      final new_level = level + 1;

      // 1. Firestore 업데이트
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'level': new_level,
        'exp': new_exp,
        'hp' : new_hp,
        'mp' : new_mp
      });

      // 2. 로컬 모델 업데이트
      userController.updateUser(
          level: new_level,
          exp: new_exp.toInt(),
          hp: new_hp,
          mp: new_mp
      );
      userController.user.refresh(); // GetX에서 Rx 객체 수동 갱신
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
      userController.user.refresh();
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
