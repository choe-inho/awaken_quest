
// 저널 페이지
import 'package:intl/intl.dart';

import '../../../utils/Diagonal_Pattern_Painter.dart';
import '../../../utils/manager/Import_Manager.dart';
import '../../controllers/Journal_Controller.dart';
import '../../widgets/Hunter_Status_Frame.dart';

class Journal extends StatelessWidget {
  const Journal({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX 컨트롤러 초기화
    final journalController = Get.find<JournalController>();

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
            Obx((){
              final sub_day = controller.selectedDate.value.subtract(const Duration(days: 1));
              final daysPassed = DateTime.now().difference(sub_day).inDays;
              final canBack = daysPassed < 60;
              return IconButton(
                onPressed: canBack
                    ? () => controller.changeDate(sub_day)
                    : () {
                  // 토스트 메시지나 스낵바로 알림
                  Get.snackbar(
                    '알림',
                    '60일 이전 기록은 조회할 수 없습니다',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black.withValues(alpha: 0.7),
                    colorText: Colors.white,
                  );
                },
                icon: Icon(
                  BootstrapIcons.chevron_left,
                  color: canBack
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4), // 비활성화시 투명도 조절
                ),
              );
            }),

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

           Obx((){
             final tomorrow = controller.selectedDate.value.add(const Duration(days: 1));
             final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

             // 내일이 아닌 오늘까지만 조회 가능 (오늘은 제외)
             final canFront = tomorrow.isBefore(today);

             return IconButton(
               onPressed: canFront
                   ? () => controller.changeDate(tomorrow)
                   : () {
                 // 사용자에게 피드백 제공
                 Get.snackbar(
                   '알림',
                   '오늘 날짜는 퀘스트 창에서 확인할 수 있습니다',
                   snackPosition: SnackPosition.BOTTOM,
                   backgroundColor: Colors.black.withValues(alpha: 0.7),
                   colorText: Colors.white,
                   duration: const Duration(seconds: 2),
                 );
               },
               icon: Icon(
                 BootstrapIcons.chevron_right,
                 color: canFront
                     ? Colors.white
                     : Colors.white.withValues(alpha: 0.3), // 비활성화시 더 투명하게
               ),
             );
           })
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
      final missionTypes = ['main', 'sub', 'custom'];

      // 모든 유형의 미션을 가져와서 병합
      final allMissions = <String, List<QuestModel>>{};
      for (final type in missionTypes) {
        if (controller.quest.containsKey(type)) {
          allMissions[type] = controller.getFilteredMissions(dateStr, type);
        }
      }

      // 미션이 하나도 없는지 확인
      final bool noMissions = allMissions.values.every((list) => list.isEmpty);

      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }

      if (noMissions) {
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
            itemCount: missionTypes.length, // 미션 유형별로 섹션 생성
            itemBuilder: (context, typeIndex) {
              final type = missionTypes[typeIndex];
              final missions = allMissions[type] ?? [];

              if (missions.isEmpty) {
                return const SizedBox.shrink(); // 해당 유형의 미션이 없으면 표시하지 않음
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 미션 유형 헤더
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getMissionTypeColor(type).withAlpha(120),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getMissionTypeText(type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // 해당 유형의 미션 리스트
                  ...missions.map((mission) => _buildMissionItem(type, mission)),
                ],
              );
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
  Widget _buildMissionItem(String type, QuestModel mission) {
    // 미션 유형에 따른 색상 설정
    final Color missionColor = _getMissionTypeColor(type);
    final bool isCompleted = mission.isClear != null;

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
                  color: missionColor.withAlpha(isCompleted ? 100 : 160),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: missionColor.withAlpha(isCompleted ? 40 : 80),
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
                      color: isCompleted
                          ? const Color(0xFF00FF00).withAlpha(40)
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? const Color(0xFF00FF00).withAlpha(160)
                            : missionColor.withAlpha(160),
                        width: 1.5,
                      ),
                    ),
                    child: isCompleted
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
                        // 미션 제목
                        Text(
                          mission.quest,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.white.withAlpha(150),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 미션 진행도
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '목표: ${mission.amount} ${mission.unit}',
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
                                  '${mission.exp}',
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

                        const SizedBox(height: 6),

                        // 날짜 정보 (완료된 경우에만)
                        if (isCompleted)
                          Text(
                            '완료: ${DateFormat('MM/dd HH:mm').format(mission.isClear!)}',
                            style: TextStyle(
                              color: Colors.white.withAlpha(140),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 완료 표시 (완료된 미션에만)
            if (isCompleted)
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
        return '일일 미션';
      case 'sub':
        return '특별 미션';
      case 'custom':
        return '개인 미션';
      default:
        return '기타 미션';
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