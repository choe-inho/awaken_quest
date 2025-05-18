// lib/utils/utils/Title_Integration.dart
import 'package:awaken_quest/model/Title_Model.dart';
import 'package:awaken_quest/utils/handler/Title_Handler.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:hive/hive.dart';

import '../../app/controllers/Quest_Controller.dart';
import '../../model/User_Model.dart';

/// 칭호 시스템을 앱의 다른 부분과 통합하기 위한 유틸리티 클래스
class TitleIntegration {
  // 싱글톤 패턴
  static final TitleIntegration _instance = TitleIntegration._internal();
  factory TitleIntegration() => _instance;
  TitleIntegration._internal();
  final TitleHandler _titleHandler = TitleHandler();

  // 사용자 프로필과 통합
  Future<void> integrateWithUserProfile(UserController userController) async {
    // 사용자 모델이 로드된 경우
    if (userController.user.value != null) {
      // 로드된 사용자 정보 확인
      final user = userController.user.value!;

      // 레벨 관련 칭호 체크
      await _titleHandler.checkAndGrantTitles('level_up', user.level);

      // 직업 관련 칭호 체크 (여기서는 직업 정보만 유지)
      // 실제 미션 완료 수는 미션 컨트롤러에서 관리해야 함
      final jobType = user.job;

      // 첫 로그인 칭호 (초심자 칭호)
      if (userController.firebaseConnected.value) {
        await _titleHandler.checkAndGrantTitles('registration', 1);
      }
    }
  }

  // 미션 완료와 통합
  Future<void> integrateWithMissionComplete(
      UserController userController,
      QuestController questController,
      String missionType,
      String jobType,
      ) async {
    // 미션 타입에 따라 다른 조건 체크
    if (missionType == 'main' || missionType == 'sub' || missionType == 'custom') {
      // 일반 미션 완료 칭호 체크
      // 여기서 미션 완료 누적 개수를 가져와야 함
      // 임시로 하드코딩된 값 사용
      final missionCompleteCount = _getMissionCompletedCount(userController);
      await _titleHandler.checkAndGrantTitles('mission_complete', missionCompleteCount);

      // 직업별 미션 완료 칭호 체크
      final jobMissionCount = _getJobMissionCompletedCount(userController);
      await _titleHandler.checkAndGrantTitles('job_mission', jobMissionCount, jobType: jobType);

      // 시간 기반 미션 체크 (새벽 미션, 밤 미션)
      final hour = DateTime.now().toLocal().hour;
      if (hour < 5) {
        // 새벽 5시 이전 (새벽 미션)
        await _titleHandler.checkAndGrantTitles('time_mission', hour);
      } else if (hour >= 0 && hour < 3) {
        // 자정 이후 (밤 미션)
        await _titleHandler.checkAndGrantTitles('time_mission', 0);
      }

      // 하루 동안 모든 미션 완료 체크
      final allDailyMissionsCompleted = _checkAllDailyMissionsCompleted(questController);
      if (allDailyMissionsCompleted) {
        await _titleHandler.checkAndGrantTitles('day_complete', 1);
      }
    }
  }

  // 연속 접속 체크와 통합
  Future<void> integrateWithLoginStreak(int streakDays) async {
    // 연속 접속 일수에 따른 칭호 체크
    await _titleHandler.checkAndGrantTitles('streak', streakDays);
  }

  // 히든 칭호 획득 트리거
  Future<void> triggerHiddenTitle(String action) async {
    // 특별 액션에 따른 히든 칭호 체크
    if (action == 'secret_combination') {
      await _titleHandler.checkAndGrantTitles('hidden', 1);
    }
  }

  // 칭호 표시를 위한 유틸리티 함수
  String getTitleDisplayName(UserModel user) {
    final currentTitle = _titleHandler.getCurrentTitle();
    return currentTitle?.name ?? '초심자';
  }

  Color getTitleDisplayColor(UserModel user) {
    final currentTitle = _titleHandler.getCurrentTitle();
    return currentTitle?.color ?? Colors.cyanAccent;
  }

  // 칭호 특수 효과 체크 (전설급 칭호의 특수 효과 등)
  bool hasTitleSpecialEffect() {
    final currentTitle = _titleHandler.getCurrentTitle();
    return currentTitle?.hasEffect == true;
  }

  // 파이어베이스에 기록된 직업별 완료 계수
  int _getMissionCompletedCount(UserController controller) {
    final cleared = controller.cleared.value!;

    int count = 0;

    count += cleared.warrior;
    count += cleared.magic;
    count += cleared.healer;
    count += cleared.smith;
    count += cleared.explorer;

    return count;
  }

  // 직업별 미션 완료 수 계산 (예시)
  int _getJobMissionCompletedCount(UserController controller) {
    final job = controller.user.value!.job;
    final cleared = controller.cleared.value!;

    if(job == '전사'){
      return cleared.warrior;
    }else if(job == '마법사'){
      return cleared.magic;
    }else if(job == '힐러'){
      return cleared.healer;
    }else if(job == '대장장이'){
      return cleared.smith;
    }else if(job == '탐험가'){
      return cleared.explorer;
    }else{
      return 0;
    }
  }

  // 하루 동안 모든 미션이 완료되었는지 체크 (예시)
  bool _checkAllDailyMissionsCompleted(QuestController questController) {
    // 메인 미션 중 완료되지 않은 것이 있는지 체크
    final anyMainIncomplete = questController.todayMainMissions
        .any((mission) => mission.isClear == null);

    // 서브 미션 중 완료되지 않은 것이 있는지 체크
    final anySubIncomplete = questController.todaySubMissions
        .any((mission) => mission.isClear == null);

    // 모든 미션이 완료되었으면 true 반환
    return !anyMainIncomplete && !anySubIncomplete &&
        questController.todayMainMissions.isNotEmpty &&
        questController.todaySubMissions.isNotEmpty;
  }
}

// 칭호 시스템 초기화 함수 (앱 시작 시 호출)
Future<void> initializeTitleSystem() async {
  // Hive 어댑터 등록 (미리 등록되지 않은 경우)
  // Hive.registerAdapter(TitleModelAdapter());

  try {
    // Hive 박스 열기 전에 이미 열려있는지 확인
    if (!Hive.isBoxOpen('titles_box')) {
      await Hive.openBox<TitleModel>('titles_box');
    }

    if (!Hive.isBoxOpen('user_titles_box')) {
      await Hive.openBox('user_titles_box');
    }

    // 칭호 핸들러 초기화
    await TitleHandler().loadAllTitles();
  } catch (e) {
    print('칭호 시스템 초기화 오류: $e');
  }
}

// 칭호 시스템 Hive 등록 (main.dart에서 호출)
void registerTitleAdapters() {
  // 이미 등록되어 있는지 확인하는 로직 추가
  try {
    Hive.registerAdapter(TitleModelAdapter());
  } catch (e) {
    // 이미 등록된 경우 오류 무시
    print('TitleModelAdapter 등록 오류(무시됨): $e');
  }
}
