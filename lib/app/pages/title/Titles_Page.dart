// lib/app/pages/profile/Titles_Page.dart
import 'dart:ui';
import 'package:awaken_quest/app/widgets/Hunter_Status_Frame.dart';
import 'package:awaken_quest/model/Title_Model.dart';
import 'package:awaken_quest/utils/handler/Title_Handler.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'dart:math' as math;
import '../../widgets/Title_Card_Widget.dart';

class TitlesPage extends StatefulWidget {
  const TitlesPage({super.key});

  @override
  State<TitlesPage> createState() => _TitlesPageState();
}

class _TitlesPageState extends State<TitlesPage> with SingleTickerProviderStateMixin {
  final TitleHandler _titleHandler = TitleHandler();
  final UserController _userController = Get.find<UserController>();

  // 현재 선택된 탭 인덱스
  int _selectedTabIndex = 0;

  // 현재 선택된 칭호 ID
  String? _selectedTitleId;

  // 애니메이션 컨트롤러
  late AnimationController _animController;

  // 필터링된 칭호 리스트
  List<TitleModel> _filteredTitles = [];

  // 로딩 상태
  bool _isLoading = true;

  // 스트림 구독
  StreamSubscription<TitleModel>? _titleAcquiredSubscription;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 데이터 로드
    _loadData();
  }

  // 데이터 로드
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 모든 칭호 로드
      await _titleHandler.loadAllTitles();

      // 현재 선택된 칭호
      _selectedTitleId = _titleHandler.currentTitleId;

      // 필터링된 칭호 초기화
      updateFilteredTitles();
    } catch (e) {
      print('칭호 데이터 로드 오류: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 필터링된 칭호 업데이트
  void updateFilteredTitles() {
    switch (_selectedTabIndex) {
      case 0: // 모든 칭호
        _filteredTitles = _titleHandler.getAllTitles();
        break;
      case 1: // 획득한 칭호
        _filteredTitles = _titleHandler.getAcquiredTitles();
        break;
      case 2: // 미획득 칭호
        _filteredTitles = _titleHandler.getLockedTitles();
        break;
      case 3: // 일반 등급
        _filteredTitles = _titleHandler.getTitlesByRarity(0);
        break;
      case 4: // 희귀 등급
        _filteredTitles = _titleHandler.getTitlesByRarity(1);
        break;
      case 5: // 영웅 등급
        _filteredTitles = _titleHandler.getTitlesByRarity(2);
        break;
      case 6: // 전설 등급
        _filteredTitles = _titleHandler.getTitlesByRarity(3);
        break;
      default:
        _filteredTitles = _titleHandler.getAllTitles();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleAcquiredSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '나의 칭호',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.cyanAccent.withValues(alpha: 0.7),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 정보 버튼
          IconButton(
            icon: const Icon(BootstrapIcons.info_circle, color: Colors.white),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Stack(
        children: [
          // 배경 효과
          Positioned.fill(
            child: _buildBackgroundEffects(),
          ),

          // 메인 콘텐츠
          SafeArea(
            child: Column(
              children: [
                // 현재 선택된 칭호 표시
                _buildCurrentTitle(),

                const SizedBox(height: 16),

                // 필터 탭 바
                _buildFilterTabs(),

                const SizedBox(height: 16),

                // 칭호 목록
                Expanded(
                  child: _buildTitlesList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 로딩 상태
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: Colors.cyanAccent,
              strokeWidth: 2,
              backgroundColor: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '칭호 데이터 로드 중...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 배경 효과
  Widget _buildBackgroundEffects() {
    return Stack(
      children: [
    // 기본 그라데이션 배경
    Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withValues(alpha: 0.7),
        const Color(0xFF050915).withValues(alpha: 0.9),
      ],
    ),
    ),
    ),

    // 반짝이는 패턴 효과
    CustomPaint(
    painter: TitleBackgroundPainter(
    animValue: _animController.value,
    ),
    size: Size.infinite,
    ),

        // 추가 오버레이 효과 (선택적)
        if (_selectedTitleId != null)
          Builder(builder: (context) {
            final currentTitle = _titleHandler.getCurrentTitle();
            if (currentTitle != null && currentTitle.hasEffect) {
              return AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: TitleBackgroundEffectPainter(
                      color: currentTitle.color,
                      animValue: _animController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              );
            }
            else {
              return Container();
            }
          })
      ],
    );
  }

  // 현재 선택된 칭호 표시
  Widget _buildCurrentTitle() {
    final currentTitle = _titleHandler.getCurrentTitle();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HunterStatusFrame(
        width: Get.width - 32,
        height: 140,
        primaryColor: currentTitle?.color ?? Colors.cyanAccent,
        secondaryColor: currentTitle?.color.withValues(alpha: 0.7) ??
            const Color(0xFF00A3FF),
        borderWidth: 2.0,
        cornerSize: 12,
        polygonSides: 6, // 육각형
        title: '선택된 칭호',
        showStatusLines: false,
        glowIntensity: currentTitle?.hasEffect == true ? 1.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: currentTitle != null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 칭호 이름
              Text(
                currentTitle.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: currentTitle.color,
                  shadows: [
                    Shadow(
                      color: currentTitle.color.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // 칭호 설명
              Text(
                currentTitle.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          )
              : Center(
            child: Text(
              '선택된 칭호가 없습니다',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 필터 탭 바
  Widget _buildFilterTabs() {
    final tabs = [
      {'icon': BootstrapIcons.collection, 'text': '전체'},
      {'icon': BootstrapIcons.award, 'text': '획득'},
      {'icon': BootstrapIcons.lock, 'text': '미획득'},
      {'icon': BootstrapIcons.circle_square, 'text': '일반'},
      {'icon': BootstrapIcons.diamond, 'text': '희귀'},
      {'icon': BootstrapIcons.star, 'text': '영웅'},
      {'icon': BootstrapIcons.stars, 'text': '전설'},
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
                updateFilteredTitles();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.cyanAccent.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.cyanAccent
                      : Colors.cyanAccent.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tabs[index]['icon'] as IconData,
                    color: isSelected
                        ? Colors.cyanAccent
                        : Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tabs[index]['text'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.cyanAccent
                          : Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 칭호 목록
  Widget _buildTitlesList() {
    if (_filteredTitles.isEmpty) {
      return Center(
        child: Text(
          '해당 필터에 일치하는 칭호가 없습니다',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredTitles.length,
      itemBuilder: (context, index) {
        final title = _filteredTitles[index];
        final isSelected = title.id == _selectedTitleId;

        // 현재 진행도 값 계산 (진행상황 표시용)
        int? currentValue;
        if (!title.isAcquired) {
          if (title.conditionType.startsWith('level_up')) {
            currentValue = _userController.user.value?.level ?? 0;
          } else if (title.conditionType.startsWith('mission_complete')) {
            // 미션 완료 수는 별도 추적이 필요함
            currentValue = 0; // 예시용 임시값
          } else if (title.conditionType.startsWith('streak')) {
            // 연속 접속 일수는 별도 추적이 필요함
            currentValue = 0; // 예시용 임시값
          }
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TitleCard(
            title: title,
            isSelected: isSelected,
            currentValue: currentValue,
            onTap: () {
              if (title.isAcquired) {
                // 칭호 선택
                _selectTitle(title.id);
              }
            },
          ),
        );
      },
    );
  }

  // 칭호 선택 처리
  Future<void> _selectTitle(String titleId) async {
    try {
      await _titleHandler.changeCurrentTitle(titleId);

      setState(() {
        _selectedTitleId = titleId;
      });

      // 토스트 메시지 표시
      Get.snackbar(
        '칭호 변경',
        '새로운 칭호가 적용되었습니다',
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      print('칭호 변경 오류: $e');

      // 오류 메시지 표시
      Get.snackbar(
        '오류',
        '칭호 변경 중 오류가 발생했습니다',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  // 정보 다이얼로그
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.cyanAccent.withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '칭호 시스템 안내',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoItem(
                  icon: BootstrapIcons.circle_square,
                  color: Colors.green,
                  title: '일반 등급',
                  description: '쉽게 획득할 수 있는 일반 칭호입니다.',
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  icon: BootstrapIcons.diamond,
                  color: Colors.blue,
                  title: '희귀 등급',
                  description: '특별한 조건을 달성해야 얻을 수 있는 희귀 칭호입니다.',
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  icon: BootstrapIcons.star,
                  color: Colors.purple,
                  title: '영웅 등급',
                  description: '높은 도전을 완료해야 획득할 수 있는 영웅 칭호입니다.',
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  icon: BootstrapIcons.stars,
                  color: Colors.orange,
                  title: '전설 등급',
                  description: '최고 난이도의 도전을 달성해야 얻을 수 있는 특별한 칭호입니다.',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
                    foregroundColor: Colors.cyanAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.cyanAccent.withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 정보 아이템
  Widget _buildInfoItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.7),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 칭호 페이지 배경 페인터
class TitleBackgroundPainter extends CustomPainter {
  final double animValue;

  TitleBackgroundPainter({
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 기하학적 패턴 그리기
    final lineCount = 15;
    final lineSpacing = size.height / lineCount;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 수평선
    for (int i = 0; i < lineCount; i++) {
      final y = i * lineSpacing;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // 수직선
    final columnCount = 10;
    final columnSpacing = size.width / columnCount;

    for (int i = 0; i < columnCount; i++) {
      final x = i * columnSpacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        linePaint,
      );
    }

    // 반짝이는 효과
    final random = math.Random(42); // 고정 시드로 일관된 패턴
    final sparkPaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // 애니메이션 값에 따라 크기 변화
      final sparkOpacity = 0.2 + 0.3 * math.sin((animValue * 2 * math.pi) + i * 0.2);
      final sparkSize = 1.5 + sparkOpacity * 1.5;

      canvas.drawCircle(
        Offset(x, y),
        sparkSize,
        sparkPaint..color = Colors.white.withValues(alpha: sparkOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant TitleBackgroundPainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
}

// 칭호 효과 배경 페인터 (특수 칭호용)
class TitleBackgroundEffectPainter extends CustomPainter {
  final Color color;
  final double animValue;

  TitleBackgroundEffectPainter({
    required this.color,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 중앙에서 밖으로 퍼지는 원형 그라데이션
    final radius = size.width * (0.3 + 0.1 * math.sin(animValue * math.pi * 2));

    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.3), // 약간 아래쪽으로 이동
        radius: 0.7,
        colors: [
          color.withValues(alpha: 0.05 + 0.05 * math.sin(animValue * math.pi * 2)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.3),
        width: radius * 2,
        height: radius * 2,
      ));

    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.3),
      radius,
      gradientPaint,
    );

    // 움직이는 광선 효과
    final rayCount = 8;
    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerX = size.width / 2;
    final centerY = size.height * 0.3;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * math.pi * 2 + (animValue * math.pi);
      final x1 = centerX + math.cos(angle) * (size.width * 0.4);
      final y1 = centerY + math.sin(angle) * (size.height * 0.4);

      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(x1, y1),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TitleBackgroundEffectPainter oldDelegate) {
    return oldDelegate.animValue != animValue || oldDelegate.color != color;
  }
}