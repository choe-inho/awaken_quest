import 'package:awaken_quest/app/controllers/Quest_Controller.dart';
import 'package:awaken_quest/app/pages/loading/Loading.dart';
import 'package:intl/intl.dart';
import '../../../utils/Animation_Utils.dart';
import '../../../utils/animation/Simmer_Text.dart';
import '../../../utils/manager/Import_Manager.dart';
import '../../widgets/Day_Countdown_Timer.dart';
import '../../widgets/Hunter_Status_Frame.dart'; // 헌터 상태창 import

class Quest extends GetView<QuestController> {
  const Quest({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
    controller.loading.value
        ? const Loading()
        : _buildQuestPage(context)
    );
  }

  Widget _buildQuestPage(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16,),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // 오늘 날짜 표시 (애니메이션 효과와 함께)
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: _buildDateHeader(),
              ),

              const SizedBox(height: 20),

              // 일일 퀘스트 섹션
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                child: _buildQuestSection(
                  title: '일일 미션',
                  missions: controller.todayMainMissions,
                  missionType: 'main',
                  glowColor: const Color(0xFF5D00FF),
                ),
              ),

              const SizedBox(height: 20),

              // 특별 퀘스트 섹션
              FadeInRight(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 200),
                child: _buildQuestSection(
                  title: '특별 미션',
                  missions: controller.todaySubMissions,
                  missionType: 'sub',
                  glowColor: const Color(0xFFFF5500),
                ),
              ),

              const SizedBox(height: 20),

              // 개인 커스텀 퀘스트 섹션
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: _buildCustomQuestSection(),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 날짜 헤더 위젯 - 헌터 프레임 적용
  Widget _buildDateHeader() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy년 MM월 dd일 E', 'ko_KR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              dateFormat.format(now),
              style: TextStyle(
                color: Colors.white.withAlpha(240),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 12,),
        Center(
          child: HunterStatusFrame(
            width: Get.width - 40,
            height: 60,
            // 높이를 약간 더 높게 설정하여 카운트다운과 날짜를 모두 표시
            primaryColor: Get.theme.colorScheme.primary,
            secondaryColor: Get.theme.colorScheme.secondary,
            borderWidth: 1.8,
            cornerSize: 10,
            polygonSides: 0,
            // 직사각형 모드
            showStatusLines: false,
            showInnerBorder: false,
            glowIntensity: 1.2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DayCountdownTimer(),
            ),
          ),
        ),
      ],
    );
  }


  // 퀘스트 섹션 위젯 (일일, 특별 퀘스트용) - 헌터 프레임 적용
  Widget _buildQuestSection({
    required String title,
    required List<QuestModel> missions,
    required String missionType,
    required Color glowColor,
  }) {
    // 미션 종류에 따라 다각형 형태 결정
    final int sides = missionType == 'main' ? 6 : 5; // 일일 미션은 육각형, 특별 미션은 오각형

    return HunterStatusFrame(
      width: Get.width,
      height: missions.isEmpty ? 200 : max(180, 70.0 + missions.length * 65.0),
      primaryColor: glowColor,
      secondaryColor: missionType == 'main'
          ? const Color(0xFF9000FF)
          : const Color(0xFFFF8800),
      borderWidth: 2.0,
      cornerSize: 12,
      polygonSides: sides,
      title: title,
      showStatusLines: missions.isNotEmpty && missions.length > 1,
      glowIntensity: 1.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: missions.isEmpty
            ? _buildEmptyMissions()
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final item = missions[index];
            // 미션 아이템마다 살짝 지연된 애니메이션 효과
            return FadeIn(
              delay: Duration(milliseconds: 100 * index),
              duration: const Duration(milliseconds: 600),
              child: _buildMissionItem(item, missionType, index),
            );
          },
        ),
      ),
    );
  }

  // 개인 커스텀 퀘스트 섹션 - 헌터 프레임 적용
  Widget _buildCustomQuestSection() {
    final customMissions = controller.todayCustomMissions;

    return HunterStatusFrame(
      width: Get.width,
      height: customMissions.isEmpty
          ? 400  // 빈 상태일 때 높이
          : max(400, 120.0 + customMissions.length * 65.0), // 미션이 있을 때 미션 수에 따라 높이 조정
      primaryColor: const Color(0xFF0055FF),
      secondaryColor: const Color(0xFF00A3FF),
      borderWidth: 2.2,
      cornerSize: 15,
      polygonSides: 8, // 팔각형 모양
      title: '개인 미션',
      showStatusLines: customMissions.isNotEmpty && customMissions.length > 1,
      glowIntensity: 1.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          children: [
            // 커스텀 미션 리스트 또는 빈 상태 표시
            Expanded(
              child: controller.todayCustomMissions.isEmpty
                  ? _buildEmptyCustomMissions()
                  : Obx(
                    ()=> ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: controller.todayCustomMissions.length,
                                    itemBuilder: (context, index) {
                    final item = controller.todayCustomMissions[index];
                    return FadeIn(
                      delay: Duration(milliseconds: 100 * index),
                      duration: const Duration(milliseconds: 600),
                      child: _buildMissionItem(item, 'custom', index),
                    );
                    },),
                  )
            ),

            if(Get.find<UserController>().customTodoList.isNotEmpty)...[
              const SizedBox(height: 8),
              //기존 개인 미션 불러오기
              _buildLoadMyMission(),
            ],
            const SizedBox(height: 8),
            // 개인 미션 추가 버튼
            _buildAddCustomMissionButton(),
          ],
        ),
      ),
    );
  }

  // 미션 아이템 위젯
  Widget _buildMissionItem(dynamic item, String missionType, int index) {
    final isClear = item.isClear != null;

    // 미션 종류에 따라 색상 설정
    final Color missionColor = missionType == 'main'
        ? const Color(0xFF5D00FF)
        : missionType == 'sub'
        ? const Color(0xFFFF5500)
        : const Color(0xFF0055FF);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          _handleMissionTap(item, missionType);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(60),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isClear
                  ? Colors.white.withAlpha(40)
                  : missionColor.withAlpha(80),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isClear
                    ? Colors.transparent
                    : missionColor.withAlpha(40),
                blurRadius: 5,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 완료 선
              if (isClear)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      height: 1.5,
                      color: Colors.white.withAlpha(120),
                    ),
                  ),
                ),

              Row(
                children: [
                  // 완료 표시 아이콘
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isClear
                          ? const Color(0xFF00FF00).withAlpha(40)
                          : Colors.black.withAlpha(120),
                      border: Border.all(
                        color: isClear
                            ? const Color(0xFF00FF00).withAlpha(160)
                            : missionColor.withAlpha(140),
                        width: 1.8,
                      ),
                    ),
                    child: isClear
                        ? Icon(
                      BootstrapIcons.check,
                      size: 14,
                      color: Colors.white.withAlpha(220),
                    )
                        : null,
                  ),

                  const SizedBox(width: 10),

                  // 웹툰 스타일 오른쪽 화살표 표시
                  if (!isClear)
                    Icon(
                      BootstrapIcons.chevron_right,
                      size: 14,
                      color: missionColor.withAlpha(180),
                    ),

                  const SizedBox(width: 6),

                  // 미션 텍스트
                  Expanded(
                    child: Text(
                      item.quest,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isClear ? FontWeight.w400 : FontWeight.w500,
                        color: isClear
                            ? Colors.white.withAlpha(130)
                            : Colors.white.withAlpha(220),
                        decoration: isClear ? TextDecoration.lineThrough : null,
                        shadows: isClear
                            ? []
                            : [
                          Shadow(
                            color: missionColor.withAlpha(100),
                            blurRadius: 12,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 수량 표시 (웹툰 스타일로 변경)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isClear
                          ? Colors.white.withAlpha(20)
                          : missionColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isClear
                            ? Colors.white.withAlpha(60)
                            : missionColor.withAlpha(80),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.amount.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isClear
                                ? Colors.white.withAlpha(130)
                                : Colors.white.withAlpha(220),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          item.unit,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isClear
                                ? Colors.white.withAlpha(130)
                                : Colors.white.withAlpha(220),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 완료 효과 (미션이 완료되었을 때만)
              if (isClear)
                Positioned.fill(
                  child: FlipInX(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        BootstrapIcons.check_circle_fill,
                        color: const Color(0xFF00FF00).withAlpha(160),
                        size: 26,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 커스텀 미션 기존꺼 불러오기 버튼
  Widget _buildLoadMyMission() {
    return ElasticIn(
      child: InkWell(
        onTap: () {
          _showLoadMissionBottomSheet();
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(70),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              // 약간 다른 색상 사용
              color: const Color(0xFF2979FF).withAlpha(140),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2979FF).withAlpha(70),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2979FF).withAlpha(50),
                  border: Border.all(
                    color: const Color(0xFF2979FF).withAlpha(160),
                    width: 1.5,
                  ),
                ),
                // 다른 아이콘 사용
                child: Icon(
                  BootstrapIcons.folder,
                  size: 14,
                  color: Colors.white.withAlpha(240),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '나만의 미션 불러오기',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(220),
                  shadows: [
                    Shadow(
                      color: const Color(0xFF2979FF).withAlpha(120),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // 커스텀 미션 불러오기 바텀시트
  void _showLoadMissionBottomSheet() {
    final userController = Get.find<UserController>();

    // 사용자의 커스텀 미션 목록 가져오기
    final customMissions = userController.customTodoList;

    // 이미 오늘 추가된 미션 ID 목록 (중복 방지용)
    final alreadyAddedIds = controller.todayCustomMissions
        .map((mission) => mission.id)
        .toList();

    Get.bottomSheet(
      FractionallySizedBox(
        heightFactor: 0.7, // 화면의 70% 높이
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF050915),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: const Color(0xFF2979FF).withAlpha(120),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2979FF).withAlpha(40),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(100),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              // 제목
              Padding(
                padding: const EdgeInsets.all(16),
                child: ShimmerText(
                  text: '나만의 미션 목록',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2979FF),
                  ),
                ),
              ),

              // 미션이 없는 경우
              if (customMissions.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          BootstrapIcons.emoji_neutral,
                          size: 48,
                          color: Colors.white.withAlpha(120),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '저장된 미션이 없습니다',
                          style: TextStyle(
                            color: Colors.white.withAlpha(160),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '나만의 미션을 추가하면 여기에 표시됩니다',
                          style: TextStyle(
                            color: Colors.white.withAlpha(120),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 미션 목록
              if (customMissions.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: customMissions.length,
                    itemBuilder: (context, index) {
                      final mission = customMissions[index];
                      final isAlreadyAdded = alreadyAddedIds.contains(mission.id);

                      return FadeIn(
                        delay: Duration(milliseconds: 50 * index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(60),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isAlreadyAdded
                                  ? Colors.grey.withAlpha(70)
                                  : const Color(0xFF2979FF).withAlpha(100),
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              mission.title,
                              style: TextStyle(
                                color: isAlreadyAdded
                                    ? Colors.white.withAlpha(100)
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: isAlreadyAdded
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              '${mission.baseAmount} ${mission.unit}',
                              style: TextStyle(
                                color: Colors.white.withAlpha(150),
                                fontSize: 14,
                              ),
                            ),
                            trailing: isAlreadyAdded
                                ? Icon(
                              BootstrapIcons.check_circle_fill,
                              color: Colors.green.withAlpha(150),
                              size: 22,
                            )
                                :  Icon(
                              BootstrapIcons.plus_circle,
                              color: const Color(0xFF2979FF).withAlpha(200),
                              size: 22,
                            ),
                            enabled: !isAlreadyAdded,
                            // 바텀시트 코드 일부 수정
                            onTap: isAlreadyAdded
                                ? null
                                : () {
                              controller.addMissionToToday(mission.id);
                              Get.back(); // 바텀시트 닫기
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 하단 버튼
              Padding(
                padding: const EdgeInsets.all(16),
                child: HunterButton(
                  text: '닫기',
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true, // 스크롤 가능하도록
      barrierColor: Colors.black.withAlpha(150), // 반투명 어두운 배경
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    );
  }
  // 빈 미션 상태 위젯
  Widget _buildEmptyMissions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(40),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                BootstrapIcons.inbox,
                color: Colors.white.withAlpha(120),
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(60),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withAlpha(30),
                width: 1,
              ),
            ),
            child: Text(
              '미션이 없습니다',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(160),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 빈 커스텀 미션 상태 위젯
  Widget _buildEmptyCustomMissions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0055FF).withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF0055FF).withAlpha(60),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                BootstrapIcons.plus_circle,
                color: Colors.white.withAlpha(180),
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0055FF).withAlpha(30),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF0055FF).withAlpha(60),
                width: 1,
              ),
            ),
            child: Text(
              '나만의 미션을 추가해보세요',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(180),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 커스텀 미션 추가 버튼
  Widget _buildAddCustomMissionButton() {
    return ElasticIn(
      child: InkWell(
        onTap: () {
          _showAddCustomMissionDialog();
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(70),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFF0055FF).withAlpha(140),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0055FF).withAlpha(70),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0055FF).withAlpha(50),
                  border: Border.all(
                    color: const Color(0xFF0055FF).withAlpha(160),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  BootstrapIcons.plus,
                  size: 14,
                  color: Colors.white.withAlpha(240),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '나만의 미션 추가하기',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(220),
                  shadows: [
                    Shadow(
                      color: const Color(0xFF0055FF).withAlpha(120),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 미션 탭 처리 함수
  void _handleMissionTap(dynamic item, String missionType) {
    if(item.isClear == null) { // 완료되지 않은 상태
      if(item.id == -1) { // 광고보기 미션
        // 광고 관련 로직
      } else {
        // 미션 완료 처리
        controller.missionClear(item, missionType);

        // 미션 완료 애니메이션 효과 또는 소리 추가 가능
      }
    } else {
      // 이미 완료된 미션 - 추가 로직
      Get.snackbar(
        '이미 완료된 미션',
        '오늘 이미 완료한 미션입니다',
        backgroundColor: Colors.black.withAlpha(150),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  // 커스텀 미션 추가 다이얼로그
  void _showAddCustomMissionDialog() {
    final TextEditingController missionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController unitController = TextEditingController();

    Get.dialog(
      barrierDismissible: false,
      FadeIn(
        duration: const Duration(milliseconds: 200),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: ()=> FocusScope.of(Get.context!).unfocus(),
            child: HunterStatusFrame(
              width: 320,
              height: 320,
              primaryColor: const Color(0xFF0055FF),
              secondaryColor: const Color(0xFF00A3FF),
              borderWidth: 2.0,
              cornerSize: 12,
              polygonSides: 2, // 직사각형 모드
              title: '나만의 미션 추가',
              showStatusLines: false,
              showInnerBorder: true,
              glowIntensity: 1.2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),

                    // 미션 내용 입력 필드
                    TextField(
                      controller: missionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '미션 내용',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(120)),
                        filled: true,
                        fillColor: Colors.black.withAlpha(100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: const Color(0xFF0055FF).withAlpha(100),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: const Color(0xFF0055FF).withAlpha(100),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: const Color(0xFF0055FF).withAlpha(180),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 수량 및 단위 입력 필드
                    Row(
                      children: [
                        // 수량 입력
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '수량',
                              hintStyle: TextStyle(color: Colors.white.withAlpha(120)),
                              filled: true,
                              fillColor: Colors.black.withAlpha(100),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: const Color(0xFF0055FF).withAlpha(100),
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: const Color(0xFF0055FF).withAlpha(100),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: const Color(0xFF0055FF).withAlpha(180),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // 단위 입력
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: unitController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '단위',
                              hintStyle: TextStyle(color: Colors.white.withAlpha(120)),
                              filled: true,
                              fillColor: Colors.black.withAlpha(100),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: const Color(0xFF0055FF).withAlpha(100),
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: const Color(0xFF0055FF).withAlpha(100),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: const Color(0xFF0055FF).withAlpha(180),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 버튼들 - 헌터 상태창 스타일
                    Row(
                      children: [
                        // 취소 버튼
                        Expanded(
                          child: _buildDialogButton(
                            label: '취소',
                            onPressed: () {
                              Get.back();
                            },
                            isCancel: true,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 추가 버튼
                        Expanded(
                          child: _buildDialogButton(
                            label: '추가',
                            onPressed: () {
                              // 미션 추가 로직
                              if (missionController.text.isNotEmpty &&
                                  amountController.text.isNotEmpty &&
                                  unitController.text.isNotEmpty) {
                                // 컨트롤러로 미션 추가 호출
                                controller.addCustomMission(
                                    missionController.text,
                                    int.parse(amountController.text),
                                    unitController.text
                                );
                                Get.back();
                              } else {
                                Get.snackbar(
                                  '입력 오류',
                                  '모든 필드를 입력해주세요',
                                  backgroundColor: Colors.black.withAlpha(150),
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            isCancel: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 다이얼로그 버튼 위젯
  Widget _buildDialogButton({
    required String label,
    required VoidCallback onPressed,
    required bool isCancel,
  }) {

    final Color buttonColor = isCancel
        ? Colors.redAccent.withAlpha(120)
        : const Color(0xFF0055FF).withAlpha(120);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withAlpha(100),
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Colors.black.withAlpha(120),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          side: WidgetStateProperty.all(
            BorderSide(
              color: buttonColor.withAlpha(180),
              width: 1.8,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha(240),
            shadows: [
              Shadow(
                color: buttonColor.withAlpha(150),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
