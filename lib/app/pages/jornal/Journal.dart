import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:intl/intl.dart';
import '../../../utils/diagonal_pattern_painter.dart';
import 'dart:math' as math;

import '../../widgets/Hunter_Status_Frame.dart';

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

  @override
  void onInit() {
    super.onInit();
    // 초기 데이터 로드
    loadQuestModels();
  }

  // 날짜 변경 메서드
  void changeDate(DateTime newDate) {
    selectedDate.value = newDate;
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
  void loadQuestModels() async{
    isLoading.value = true;
    
    // 실제로는 Firebase 또는 로컬 DB에서 로드
    await  _generateDummyData();

    isLoading.value = false;
  }

  // 더미 데이터 생성 메서드
  Future<void> _generateDummyData()  async{
    final Map<String, List<QuestModel>> dummyData = {};
    final date = dateToString(selectedDate.value);
    
    //해당 날짜 받아오기
    final data = await _firestore.collection('users').doc(_auth.currentUser!.uid).collection('missions').doc(date).get(); //list 형일건데
    
    
    quest.value = dummyData;
  }



  // 특정 날짜의 필터링된 미션 목록 반환
  List<QuestModel> getFilteredMissions(String dateStr) {
    if (!quest.containsKey(dateStr)) {
      return [];
    }

    final missions = quest[dateStr]!;

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

// 저널 페이지
class Journal extends StatelessWidget {
  const Journal({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX 컨트롤러 초기화
    final journalController = Get.put(JournalController());

    return SafeArea(
      child: Stack(
        children: [

          // 배경 효과
          Positioned.fill(
            child: _buildBackgroundEffects(),
          ),

          // 메인 컨텐츠
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 상단 제목 및 날짜 선택
                _buildHeader(journalController),

                const SizedBox(height: 16),

                // 필터 탭 바
                _buildFilterTabs(journalController),

                const SizedBox(height: 16),

                // 미션 목록
                Expanded(
                  child: _buildMissionList(journalController),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 배경 효과 위젯
  Widget _buildBackgroundEffects() {
    return CustomPaint(
      painter: DiagonalPatternPainter(
        lineColor: Colors.white.withAlpha(15),
        lineWidth: 1,
        gapSize: 30,
      ),
      child: Container(),
    );
  }

  // 상단 헤더 위젯
  Widget _buildHeader(JournalController controller) {
    return HunterStatusFrame(
      width: Get.width - 32,
      height: 80,
      primaryColor: const Color(0xFF00A3FF),
      secondaryColor: const Color(0xFF5D00FF),
      borderWidth: 2.0,
      cornerSize: 12,
      polygonSides: 5, // 오각형
      showStatusLines: false,
      showInnerBorder: false,
      glowIntensity: 1.2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 이전 날짜 버튼
            IconButton(
              onPressed: () {
                controller.changeDate(
                  controller.selectedDate.value.subtract(const Duration(days: 1)),
                );
              },
              icon: const Icon(
                BootstrapIcons.chevron_left,
                color: Colors.white,
              ),
            ),

            // 날짜 표시
            Obx(() {
              final dateStr = DateFormat('yyyy년 MM월 dd일').format(controller.selectedDate.value);
              final weekday = DateFormat('EEEE', 'ko_KR').format(controller.selectedDate.value);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weekday,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }),

            // 다음 날짜 버튼
            IconButton(
              onPressed: () {
                final tomorrow = controller.selectedDate.value.add(const Duration(days: 1));
                if (tomorrow.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                  controller.changeDate(tomorrow);
                }
              },
              icon: const Icon(
                BootstrapIcons.chevron_right,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 필터 탭 위젯
  Widget _buildFilterTabs(JournalController controller) {
    return Obx(() {
      final currentFilter = controller.filter.value;

      return Row(
        children: [
          _buildFilterTab(
            title: '전체',
            isSelected: currentFilter == 'all',
            onTap: () => controller.changeFilter('all'),
            color: Colors.blueGrey,
          ),
          const SizedBox(width: 8),
          _buildFilterTab(
            title: '완료',
            isSelected: currentFilter == 'completed',
            onTap: () => controller.changeFilter('completed'),
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _buildFilterTab(
            title: '미완료',
            isSelected: currentFilter == 'incomplete',
            onTap: () => controller.changeFilter('incomplete'),
            color: Colors.red,
          ),
        ],
      );
    });
  }

  // 필터 탭 아이템 위젯
  Widget _buildFilterTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(100) : Colors.black.withAlpha(100),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.white.withAlpha(60),
              width: 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: color.withAlpha(100),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ] : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 미션 목록 위젯
  Widget _buildMissionList(JournalController controller) {
    return Obx(() {
      final dateStr = controller.dateToString(controller.selectedDate.value);
      final missions = controller.getFilteredMissions(dateStr);

      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }

      if (missions.isEmpty) {
        return _buildEmptyState();
      }

      return HunterStatusFrame(
        width: Get.width - 32,
        height: Get.height - 220,
        primaryColor: const Color(0xFF00A3FF),
        secondaryColor: const Color(0xFF5D00FF),
        borderWidth: 2.0,
        cornerSize: 15,
        polygonSides: 8, // 팔각형
        showStatusLines: true,
        glowIntensity: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: missions.length,
            itemBuilder: (context, index) {
              final mission = missions[index];
              return _buildMissionItem(mission, controller);
            },
          ),
        ),
      );
    });
  }

  // 빈 상태 위젯
  Widget _buildEmptyState() {
    return HunterStatusFrame(
      width: Get.width - 32,
      height: 300,
      primaryColor: Colors.blueGrey,
      secondaryColor: Colors.grey,
      borderWidth: 1.5,
      cornerSize: 12,
      polygonSides: 4, // 사각형
      showStatusLines: false,
      glowIntensity: 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              BootstrapIcons.journal,
              color: Colors.white.withAlpha(150),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '이 날짜에 기록된 미션이 없습니다',
              style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 날짜를 선택하거나 필터를 변경해보세요',
              style: TextStyle(
                color: Colors.white.withAlpha(140),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 미션 아이템 위젯
  Widget _buildMissionItem(String type, String key,QuestModel mission, JournalController controller) {
    // 미션 유형에 따른 색상 설정
    final Color missionColor = _getMissionTypeColor(type);
    final dateStr = key;

    return FadeIn(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Stack(
          children: [
            // 배경 컨테이너
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: missionColor.withAlpha(mission.isClear != null ? 100 : 160),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: missionColor.withAlpha(mission.isClear != null ? 40 : 80),
                    blurRadius: 5,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 미션 상태 아이콘
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12, top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mission.isClear != null
                          ? const Color(0xFF00FF00).withAlpha(40)
                          : Colors.transparent,
                      border: Border.all(
                        color: mission.isClear != null
                            ? const Color(0xFF00FF00).withAlpha(160)
                            : missionColor.withAlpha(160),
                        width: 1.5,
                      ),
                    ),
                    child: mission.isClear != null
                        ? Icon(
                      BootstrapIcons.check,
                      size: 14,
                      color: Colors.white.withAlpha(220),
                    )
                        : null,
                  ),

                  // 미션 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 미션 유형 태그 및 제목
                        Row(
                          children: [
                            // 미션 유형 태그
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: missionColor.withAlpha(100),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getMissionTypeText(type),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 미션 제목
                            Expanded(
                              child: Text(
                                mission.quest,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: mission.isClear != null
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: Colors.white.withAlpha(150),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 미션 진행도
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 진행도 텍스트
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '진행: ${mission.amount}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(180),
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      BootstrapIcons.coin,
                                      color: Colors.amber.withAlpha(200),
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${mission.reward}',
                                      style: TextStyle(
                                        color: Colors.amber.withAlpha(220),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // 진행도 바
                            Stack(
                              children: [
                                // 배경
                                Container(
                                  height: 6,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(100),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),

                                // 진행 바
                                FractionallySizedBox(
                                  widthFactor: mission.targetAmount > 0
                                      ? (mission.completedAmount / mission.targetAmount).clamp(0.0, 1.0)
                                      : 0.0,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      gradient: LinearGradient(
                                        colors: [
                                          missionColor,
                                          missionColor.withAlpha(150),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: missionColor.withAlpha(100),
                                          blurRadius: 3,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 완료 표시 (완료된 미션에만)
            if (mission.isCleared)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF00).withAlpha(140),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '완료',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 미션 타입에 따른 색상 반환
  Color _getMissionTypeColor(String type) {
    switch (type) {
      case 'main':
        return const Color(0xFF5D00FF);
      case 'sub':
        return const Color(0xFFFF5500);
      case 'custom':
        return const Color(0xFF0055FF);
      default:
        return Colors.grey;
    }
  }

  // 미션 타입 텍스트 반환
  String _getMissionTypeText(String type) {
    switch (type) {
      case 'main':
        return '일일';
      case 'sub':
        return '특별';
      case 'custom':
        return '개인';
      default:
        return '기타';
    }
  }
}

// FadeIn 애니메이션 위젯
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}