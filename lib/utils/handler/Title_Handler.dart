// lib/utils/handler/Title_Handler.dart
import 'package:awaken_quest/model/Title_Model.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class TitleHandler {
  // 싱글톤 패턴
  static final TitleHandler _instance = TitleHandler._internal();
  factory TitleHandler() => _instance;
  TitleHandler._internal();

  // Firebase 참조
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 칭호 Hive Box
  static final titlesBox = Hive.box<TitleModel>('titles_box');
  static final userTitlesBox = Hive.box('user_titles_box');

  // 모든 칭호 리스트
  final List<TitleModel> _allTitles = [];

  // 칭호 추가 리스너
  final _titleAcquiredStream = StreamController<TitleModel>.broadcast();
  Stream<TitleModel> get onTitleAcquired => _titleAcquiredStream.stream;

  // 현재 선택된 칭호 ID
  String? _currentTitleId;
  String? get currentTitleId => _currentTitleId;

  // 모든 칭호 로드
  Future<void> loadAllTitles() async {
    // 이미 로드된 경우 스킵
    if (_allTitles.isNotEmpty) return;

    try {
      // 모든 기본 칭호 정의 로드
      _loadBaseTitles();

      // 사용자 칭호 정보 동기화
      await _syncUserTitles();

      // 현재 선택된 칭호 로드
      _loadCurrentTitle();

    } catch (e) {
      print('칭호 로딩 오류: $e');
    }
  }

  // 기본 칭호 정의 로드
  void _loadBaseTitles() {
    _allTitles.clear();
    _allTitles.addAll([
      // 시작 칭호
      const TitleModel(
        id: 'title_beginner',
        name: '초심자',
        description: '모험을 시작한 것을 축하합니다!',
        rarity: 0,
        conditionType: 'registration',
        conditionValue: 1,
        colorHex: '#66BB6A',
        iconPath: 'assets/image/titles/beginner.png',
      ),

      // 레벨 관련 칭호
      const TitleModel(
        id: 'title_awakened',
        name: '각성자',
        description: '레벨 5에 도달한 자에게 주어지는 칭호',
        rarity: 0,
        conditionType: 'level_up',
        conditionValue: 5,
        colorHex: '#42A5F5',
        iconPath: 'assets/image/titles/awakened.png',
      ),
      const TitleModel(
        id: 'title_challenger',
        name: '도전자',
        description: '레벨 10에 도달한 자에게 주어지는 칭호',
        rarity: 1,
        conditionType: 'level_up',
        conditionValue: 10,
        colorHex: '#AB47BC',
        iconPath: 'assets/image/titles/challenger.png',
      ),
      const TitleModel(
        id: 'title_conqueror',
        name: '정복자',
        description: '레벨 20에 도달한 자에게 주어지는 칭호',
        rarity: 2,
        conditionType: 'level_up',
        conditionValue: 20,
        colorHex: '#EC407A',
        iconPath: 'assets/image/titles/conqueror.png',
      ),
      const TitleModel(
        id: 'title_legend',
        name: '전설',
        description: '레벨 30에 도달한 자에게 주어지는 칭호',
        rarity: 3,
        conditionType: 'level_up',
        conditionValue: 30,
        colorHex: '#FFA000',
        hasEffect: true,
        iconPath: 'assets/image/titles/legend.png',
      ),

      // 미션 완료 관련 칭호
      const TitleModel(
        id: 'title_diligent',
        name: '성실한 자',
        description: '10개의 미션을 완료한 자에게 주어지는 칭호',
        rarity: 0,
        conditionType: 'mission_complete',
        conditionValue: 10,
        colorHex: '#26A69A',
        iconPath: 'assets/image/titles/diligent.png',
      ),
      const TitleModel(
        id: 'title_industrious',
        name: '근면한 자',
        description: '50개의 미션을 완료한 자에게 주어지는 칭호',
        rarity: 1,
        conditionType: 'mission_complete',
        conditionValue: 50,
        colorHex: '#7E57C2',
        iconPath: 'assets/image/titles/industrious.png',
      ),
      const TitleModel(
        id: 'title_dedicated',
        name: '헌신적인 자',
        description: '100개의 미션을 완료한 자에게 주어지는 칭호',
        rarity: 2,
        conditionType: 'mission_complete',
        conditionValue: 100,
        colorHex: '#EF5350',
        iconPath: 'assets/image/titles/dedicated.png',
      ),

      // 연속 달성 관련 칭호
      const TitleModel(
        id: 'title_consistent',
        name: '일관된 자',
        description: '7일 연속 미션 수행',
        rarity: 0,
        conditionType: 'streak',
        conditionValue: 7,
        colorHex: '#5C6BC0',
        iconPath: 'assets/image/titles/consistent.png',
      ),
      const TitleModel(
        id: 'title_unstoppable',
        name: '멈추지 않는 자',
        description: '30일 연속 미션 수행',
        rarity: 2,
        conditionType: 'streak',
        conditionValue: 30,
        colorHex: '#FF7043',
        hasEffect: true,
        iconPath: 'assets/image/titles/unstoppable.png',
      ),

      // 직업별 칭호
      const TitleModel(
        id: 'title_warrior_master',
        name: '전사의 길',
        description: '전사로서 100개의 미션 완료',
        rarity: 2,
        conditionType: 'job_mission',
        conditionValue: 100,
        colorHex: '#F44336',
        iconPath: 'assets/image/titles/warrior.png',
      ),
      const TitleModel(
        id: 'title_mage_master',
        name: '마법의 길',
        description: '마법사로서 100개의 미션 완료',
        rarity: 2,
        conditionType: 'job_mission',
        conditionValue: 100,
        colorHex: '#2196F3',
        iconPath: 'assets/image/titles/mage.png',
      ),
      const TitleModel(
        id: 'title_healer_master',
        name: '치유의 길',
        description: '힐러로서 100개의 미션 완료',
        rarity: 2,
        conditionType: 'job_mission',
        conditionValue: 100,
        colorHex: '#4CAF50',
        iconPath: 'assets/image/titles/healer.png',
      ),
      const TitleModel(
        id: 'title_smith_master',
        name: '제작의 길',
        description: '대장장이로서 100개의 미션 완료',
        rarity: 2,
        conditionType: 'job_mission',
        conditionValue: 100,
        colorHex: '#FF9800',
        iconPath: 'assets/image/titles/smith.png',
      ),
      const TitleModel(
        id: 'title_explorer_master',
        name: '탐험의 길',
        description: '탐험가로서 100개의 미션 완료',
        rarity: 2,
        conditionType: 'job_mission',
        conditionValue: 100,
        colorHex: '#9C27B0',
        iconPath: 'assets/image/titles/explorer.png',
      ),

      // 특별 칭호
      const TitleModel(
        id: 'title_early_bird',
        name: '이른 새',
        description: '새벽 5시 전에 미션 완료',
        rarity: 1,
        conditionType: 'time_mission',
        conditionValue: 5,
        colorHex: '#FFC107',
        iconPath: 'assets/image/titles/early_bird.png',
      ),
      const TitleModel(
        id: 'title_night_owl',
        name: '밤 올빼미',
        description: '자정 이후 미션 완료',
        rarity: 1,
        conditionType: 'time_mission',
        conditionValue: 0,
        colorHex: '#3F51B5',
        iconPath: 'assets/image/titles/night_owl.png',
      ),
      const TitleModel(
        id: 'title_perfectionist',
        name: '완벽주의자',
        description: '하루에 모든 미션 완료',
        rarity: 2,
        conditionType: 'day_complete',
        conditionValue: 1,
        colorHex: '#E91E63',
        iconPath: 'assets/image/titles/perfectionist.png',
      ),

      // 히든 칭호
      const TitleModel(
        id: 'title_hidden_gem',
        name: '숨겨진 보석',
        description: '특별한 방법으로 얻은 비밀 칭호',
        rarity: 3,
        conditionType: 'hidden',
        conditionValue: 1,
        colorHex: '#00BCD4',
        hasEffect: true,
        iconPath: 'assets/image/titles/hidden_gem.png',
      ),
    ]);

    // Hive에 저장
    for (var title in _allTitles) {
      titlesBox.put(title.id, title);
    }
  }

  // 사용자 칭호 정보 동기화
  Future<void> _syncUserTitles() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      // Firebase에서 사용자 칭호 데이터 가져오기
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('user_data')
          .doc('titles')
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('acquired_titles')) {
          // 획득한 칭호 목록 업데이트
          final acquiredTitles = List<Map<String, dynamic>>.from(data['acquired_titles']);

          // 로컬 저장소 업데이트
          for (var titleData in acquiredTitles) {
            final titleId = titleData['id'];
            final baseTitle = titlesBox.get(titleId);

            if (baseTitle != null) {
              final updatedTitle = TitleModel.fromJson(titleData, baseTitle);
              titlesBox.put(titleId, updatedTitle);
            }
          }

          // 선택된 칭호 ID 업데이트
          if (data.containsKey('selected_title_id')) {
            _currentTitleId = data['selected_title_id'];
            userTitlesBox.put('selected_title_id', _currentTitleId);
          }
        }
      } else {
        // 신규 사용자인 경우 초기 칭호 부여
        await _grantInitialTitle();
      }
    } catch (e) {
      print('사용자 칭호 동기화 오류: $e');
    }
  }

  // 초기 칭호 부여
  Future<void> _grantInitialTitle() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    print('초심자 타이틀 부여');
    // 초심자 칭호 부여
    final initialTitle = titlesBox.get('title_beginner');
    if (initialTitle != null) {
      final updatedTitle = initialTitle.copyWith(acquiredAt: DateTime.now());

      // Hive 업데이트
      titlesBox.put('title_beginner', updatedTitle);

      // 현재 칭호로 설정
      _currentTitleId = 'title_beginner';
      userTitlesBox.put('selected_title_id', _currentTitleId);

      // Firebase 업데이트
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('user_data')
          .doc('titles')
          .set({
        'acquired_titles': [updatedTitle.toJson()],
        'selected_title_id': _currentTitleId,
      });

      // 칭호 획득 이벤트 발생
      _titleAcquiredStream.add(updatedTitle);
    }
  }

  // 현재 선택된 칭호 로드
  void _loadCurrentTitle() {
    _currentTitleId = userTitlesBox.get('selected_title_id');
  }

  // 칭호 조건 체크 및 획득 처리
  Future<void> checkAndGrantTitles(String conditionType, int value, {String? jobType}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // 직업 특화 칭호 조건 체크
    if (conditionType == 'job_mission' && jobType != null) {
      conditionType = '${conditionType}_$jobType';
    }

    // 새로 획득한 칭호 리스트
    final List<TitleModel> newlyAcquiredTitles = [];

    // 조건에 맞는 칭호 찾기
    for (var title in _allTitles) {
      // 이미 획득한 칭호는 스킵
      if (title.isAcquired) continue;

      // 조건 매칭 확인
      bool conditionMatched = false;

      if (title.conditionType == conditionType) {
        if (conditionType == 'level_up' && value >= title.conditionValue) {
          conditionMatched = true;
        } else if (conditionType == 'mission_complete' && value >= title.conditionValue) {
          conditionMatched = true;
        } else if (conditionType == 'streak' && value >= title.conditionValue) {
          conditionMatched = true;
        } else if (conditionType.startsWith('job_mission_') && value >= title.conditionValue) {
          conditionMatched = true;
        } else if (conditionType == 'time_mission') {
          // 시간 기반 칭호 체크
          final hour = DateTime.now().hour;
          if ((title.id == 'title_early_bird' && hour < title.conditionValue) ||
              (title.id == 'title_night_owl' && hour >= title.conditionValue)) {
            conditionMatched = true;
          }
        } else if (conditionType == 'day_complete' && value >= title.conditionValue) {
          conditionMatched = true;
        }
      }

      // 조건 충족 시 칭호 획득 처리
      if (conditionMatched) {
        final updatedTitle = title.copyWith(acquiredAt: DateTime.now());
        titlesBox.put(title.id, updatedTitle);
        newlyAcquiredTitles.add(updatedTitle);
      }
    }

    // 획득한 칭호가 있으면 Firebase 업데이트
    if (newlyAcquiredTitles.isNotEmpty) {
      // 현재 획득한 칭호 목록 가져오기
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('user_data')
          .doc('titles');

      final doc = await docRef.get();
      final List<Map<String, dynamic>> acquiredTitles = [];

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('acquired_titles')) {
          acquiredTitles.addAll(List<Map<String, dynamic>>.from(data['acquired_titles']));
        }
      }

      // 새로 획득한 칭호 추가
      for (var title in newlyAcquiredTitles) {
        acquiredTitles.add(title.toJson());
      }

      // Firebase 업데이트
      await docRef.set({
        'acquired_titles': acquiredTitles,
        'selected_title_id': _currentTitleId,
      });

      for (var title in newlyAcquiredTitles) {
        try {
          _titleAcquiredStream.add(title);
          print('칭호 획득 이벤트 발행: ${title.name}');
        } catch (e) {
          print('칭호 이벤트 발행 오류: $e');
        }
      }
    }
  }

  // 현재 사용 중인 칭호 변경
  Future<void> changeCurrentTitle(String titleId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // 칭호 존재 여부 확인
    final title = titlesBox.get(titleId);
    if (title == null || !title.isAcquired) return;

    // 현재 칭호 업데이트
    _currentTitleId = titleId;
    userTitlesBox.put('selected_title_id', _currentTitleId);

    // Firebase 업데이트
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('user_data')
        .doc('titles')
        .update({
      'selected_title_id': _currentTitleId,
    });
  }

  // 현재 선택된 칭호 가져오기
  TitleModel? getCurrentTitle() {
    if (_currentTitleId == null) return null;
    return titlesBox.get(_currentTitleId);
  }

  // 모든 칭호 가져오기
  List<TitleModel> getAllTitles() {
    return _allTitles.map((title) => titlesBox.get(title.id) ?? title).toList();
  }

  // 획득한 칭호만 가져오기
  List<TitleModel> getAcquiredTitles() {
    return getAllTitles().where((title) => title.isAcquired).toList();
  }

  // 미획득 칭호만 가져오기
  List<TitleModel> getLockedTitles() {
    return getAllTitles().where((title) => !title.isAcquired).toList();
  }

  // 희귀도별 칭호 가져오기
  List<TitleModel> getTitlesByRarity(int rarity) {
    return getAllTitles().where((title) => title.rarity == rarity).toList();
  }

  // 칭호 ID로 칭호 가져오기
  TitleModel? getTitleById(String id) {
    return titlesBox.get(id);
  }

  // 칭호 진행도 계산 (조건 타입과 현재 값 기준)
  double getTitleProgress(TitleModel title, int currentValue) {
    if (title.isAcquired) return 1.0;

    // 진행도 계산 (0.0 ~ 1.0)
    return (currentValue / title.conditionValue).clamp(0.0, 1.0);
  }

  // 획득 날짜 포맷
  String formatAcquiredDate(DateTime dateTime) {
    return DateFormat('yyyy년 MM월 dd일').format(dateTime);
  }

  // 리소스 해제
  void dispose() {
    _titleAcquiredStream.close();
  }
}