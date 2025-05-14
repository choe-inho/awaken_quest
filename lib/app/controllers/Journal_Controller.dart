import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:intl/intl.dart';
import '../../../utils/diagonal_pattern_painter.dart';
import 'dart:math' as math;
import '../widgets/Hunter_Status_Frame.dart';

// 저널 컨트롤러
class JournalController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  // 선택된 날짜
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // 날짜별 미션 기록 데이터
  final RxMap<String, List<QuestModel>> quest = <String, List<QuestModel>>{}.obs;

  // 필터 상태 (전체, 완료, 미완료)
  final RxString filter = 'all'.obs;

  // 로딩 상태
  final RxBool isLoading = false.obs;

  // 이미 로드한 날짜 데이터를 추적
  final List<String> _saveDate = [];

  // 로컬 캐시 - 날짜별 미션 데이터 저장
  final Map<String, Map<String, List<QuestModel>>> _localCache = {};

  @override
  void onInit() {
    super.onInit();
    // 초기 데이터 로드
    loadQuestModels();
  }

  // 날짜 변경 메서드
  void changeDate(DateTime newDate) {
    selectedDate.value = newDate.toLocal();
    loadQuestModels(); // 날짜 변경 시 데이터 다시 로드 (캐시 확인 후)
  }

  // 날짜를 문자열로 변환 (키 용도)
  String dateToString(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }

  // 필터 변경 메서드
  void changeFilter(String newFilter) {
    filter.value = newFilter;
  }

  // 미션 기록 로드
  void loadQuestModels() async {
    isLoading.value = true;

    try {
      // 현재 선택된 날짜의 키
      final dateKey = dateToString(selectedDate.value);

      // 로컬 캐시에 데이터가 있는지 확인
      if (_localCache.containsKey(dateKey)) {
        debugPrint("캐시에서 미션 데이터를 로드합니다: $dateKey");
        quest.value = Map.from(_localCache[dateKey]!);
      } else {
        // 캐시에 없으면 Firebase에서 로드
        await _loadMissionsFromFirebase();
      }
    } catch (e) {
      debugPrint("미션 로드 중 오류 발생: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Firebase에서 미션 데이터 로드
  Future<void> _loadMissionsFromFirebase() async {
    final dateKey = dateToString(selectedDate.value);

    // 이미 이 날짜를 불러온 적이 있다면 추가 요청을 방지
    if (_saveDate.contains(dateKey)) {
      debugPrint("이미 로드된 날짜입니다: $dateKey");
      return;
    }

    final Map<String, List<QuestModel>> missionData = {};

    try {
      debugPrint("Firebase에서 미션 데이터를 로드합니다: $dateKey");

      // 해당 날짜의 미션 문서 가져오기
      final doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('missions')
          .doc(dateKey)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _saveDate.add(dateKey); // 로드한 날짜 추적

        // 메인 미션
        if (data.containsKey('main')) {
          final mainMissions = List<Map<String, dynamic>>.from(data['main'])
              .map((e) => QuestModel.fromJson(e))
              .toList();
          missionData['main'] = mainMissions;
        }

        // 서브 미션
        if (data.containsKey('sub')) {
          final subMissions = List<Map<String, dynamic>>.from(data['sub'])
              .map((e) => QuestModel.fromJson(e))
              .toList();
          missionData['sub'] = subMissions;
        }

        // 커스텀 미션
        if (data.containsKey('custom')) {
          final customMissions = List<Map<String, dynamic>>.from(data['custom'] ?? [])
              .map((e) => QuestModel.fromJson(e))
              .toList();
          missionData['custom'] = customMissions;
        }

        // 로컬 캐시에 저장
        _localCache[dateKey] = Map.from(missionData);
      } else {
        // 데이터가 없는 경우도 캐시에 빈 데이터로 저장 (불필요한 재요청 방지)
        _localCache[dateKey] = {};
        _saveDate.add(dateKey);
      }

      // 데이터 설정
      quest.value = missionData;
      update();
    } catch (e) {
      debugPrint("Firebase에서 미션 로드 중 오류: $e");
    }
  }

  // 특정 날짜의 필터링된 미션 목록 반환
  List<QuestModel> getFilteredMissions(String dateStr, String missionType) {
    if (!quest.containsKey(missionType)) {
      return [];
    }

    final missions = quest[missionType]!;

    switch (filter.value) {
      case 'completed':
        return missions.where((mission) => mission.isClear != null).toList();
      case 'incomplete':
        return missions.where((mission) => mission.isClear == null).toList();
      case 'all':
      default:
        return missions;
    }
  }
}
