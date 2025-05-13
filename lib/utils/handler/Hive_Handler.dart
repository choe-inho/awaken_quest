import 'package:awaken_quest/model/Mission.dart';
import 'package:hive/hive.dart';

class HiveHandler{
  static final box = Hive.box<Mission>("customMissionBox");

  //로컬저장
  static saveCustomMission(Mission mission) async{
    await box.add(mission);
  }

  //불러오기
  static final allQuest = box.values.toList();

  //퀘스트 수정
  static void editCustomMission(int missionId){

  }
}