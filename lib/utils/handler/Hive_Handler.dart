import 'package:hive/hive.dart';
import '../../model/Mission.dart';

class HiveHandler {
  static final box = Hive.box<Mission>("customMissionBox");

  // 로컬 저장
  static Future<void> saveCustomMission(Mission mission) async {
    await box.add(mission);
  }

  // 불러오기
  static List<Mission> get allQuest => box.values.toList();

  // 퀘스트 수정
  static Future<void> editCustomMission(int index, Mission updatedMission) async {
    await box.putAt(index, updatedMission);
  }

  // ID로 퀘스트 수정
  static Future<void> editCustomMissionById(int missionId, Mission updatedMission) async {
    final index = box.values.toList().indexWhere((mission) => mission.id == missionId);
    if (index != -1) {
      await box.putAt(index, updatedMission);
    }
  }

  // 퀘스트 삭제
  static Future<void> deleteCustomMission(int index) async {
    await box.deleteAt(index);
  }

  // ID로 퀘스트 삭제
  static Future<void> deleteCustomMissionById(int missionId) async {
    final index = box.values.toList().indexWhere((mission) => mission.id == missionId);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }

  // 모든 퀘스트 삭제
  static Future<void> clearAllCustomMissions() async {
    await box.clear();
  }
}