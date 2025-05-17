// lib/app/widgets/Title_Card.dart
import 'package:awaken_quest/model/Title_Model.dart';
import 'package:awaken_quest/utils/handler/Title_Handler.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'dart:math' as math;

class TitleCard extends StatefulWidget {
  final TitleModel title;
  final bool isSelected;
  final VoidCallback? onTap;
  final int? currentValue; // 현재 진행도 값 (선택적)

  const TitleCard({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
    this.currentValue,
  });

  @override
  State<TitleCard> createState() => _TitleCardState();
}

class _TitleCardState extends State<TitleCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 펄스 애니메이션
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: widget.isSelected ? 1.05 : 1.00,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    // 글로우 애니메이션
    _glowAnimation = Tween<double>(
      begin: 0.3, 
      end: widget.isSelected ? 0.7 : 0.5,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    // 선택된 항목만 애니메이션 실행
    if (widget.isSelected) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.title.isAcquired ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.title.isAcquired
                      ? widget.isSelected
                      ? widget.title.color.withValues(alpha: 0.9)
                      : widget.title.color.withValues(alpha: 0.7)
                      : Colors.grey.withValues(alpha: 0.5),
                  width: widget.isSelected ? 2.5 : 1.5,
                ),
                boxShadow: widget.title.isAcquired
                    ? [
                  BoxShadow(
                    color: widget.title.color.withValues(
                      alpha: widget.title.hasEffect
                          ? _glowAnimation.value * 0.6
                          : 0.4,
                    ),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    // 배경 효과 (미획득 시에는 어두운 효과)
                    Positioned.fill(
                      child: _buildBackground(),
                    ),

                    // 메인 콘텐츠
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상단 영역: 칭호 이름과 등급
                          Row(
                            children: [
                              // 칭호 아이콘
                              _buildTitleIcon(),

                              const SizedBox(width: 8),

                              // 칭호 이름
                              Expanded(
                                child: Text(
                                  widget.title.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: widget.title.isAcquired
                                        ? widget.title.color
                                        : Colors.grey,
                                    shadows: widget.title.isAcquired
                                        ? [
                                      Shadow(
                                        color: widget.title.color.withValues(
                                          alpha: 0.7,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ]
                                        : null,
                                  ),
                                ),
                              ),

                              // 등급 뱃지
                              _buildRarityBadge(),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // 칭호 설명
                          Text(
                            widget.title.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.title.isAcquired
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.grey.withValues(alpha: 0.7),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 획득 조건 또는 획득 날짜
                          widget.title.isAcquired
                              ? _buildAcquiredInfo()
                              : _buildProgressInfo(),
                        ],
                      ),
                    ),

                    // 특수 효과 (전설 등급 등)
                    if (widget.title.isAcquired && widget.title.hasEffect)
                      _buildSpecialEffect(),

                    // 선택 표시
                    if (widget.isSelected)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.title.color.withValues(alpha: 0.8),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: const Icon(
                            BootstrapIcons.check2,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),

                    // 잠금 오버레이 (미획득 시)
                    if (!widget.title.isAcquired)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              BootstrapIcons.lock,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 칭호 배경 효과
  Widget _buildBackground() {
    if (!widget.title.isAcquired) {
      // 미획득 상태일 때 어두운 배경
      return Container(color: Colors.black.withValues(alpha: 0.3));
    }

    // 등급에 따른 배경 효과
    switch (widget.title.rarity) {
      case 3: // 전설 등급
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return CustomPaint(
              painter: LegendaryBackgroundPainter(
                color: widget.title.color,
                animValue: _animController.value,
              ),
            );
          },
        );

      case 2: // 영웅 등급
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.title.color.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        );

      case 1: // 희귀 등급
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.title.color.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        );

      case 0: // 일반 등급
      default:
        return Container(
          color: Colors.black.withValues(alpha: 0.7),
        );
    }
  }

  // 칭호 아이콘
  Widget _buildTitleIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: widget.title.isAcquired
            ? widget.title.color.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.title.isAcquired
              ? widget.title.color.withValues(alpha: 0.8)
              : Colors.grey.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: widget.title.isAcquired
            ? [
          BoxShadow(
            color: widget.title.color.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ]
            : null,
      ),
      child: Center(
        child: Icon(
          _getTitleIcon(),
          color: widget.title.isAcquired
              ? widget.title.color
              : Colors.grey.withValues(alpha: 0.7),
          size: 18,
        ),
      ),
    );
  }

  // 등급 뱃지
  Widget _buildRarityBadge() {
    Color badgeColor;
    String rarityText;

    switch (widget.title.rarity) {
      case 3:
        badgeColor = Colors.orange;
        rarityText = '전설';
        break;
      case 2:
        badgeColor = Colors.purple;
        rarityText = '영웅';
        break;
      case 1:
        badgeColor = Colors.blue;
        rarityText = '희귀';
        break;
      case 0:
      default:
        badgeColor = Colors.green;
        rarityText = '일반';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: widget.title.isAcquired
            ? badgeColor.withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.title.isAcquired
              ? badgeColor.withValues(alpha: 0.8)
              : Colors.grey.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        rarityText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: widget.title.isAcquired
              ? badgeColor
              : Colors.grey,
        ),
      ),
    );
  }

  // 획득 정보
  Widget _buildAcquiredInfo() {
    if (widget.title.acquiredAt == null) return const SizedBox();

    return Row(
      children: [
        Icon(
          BootstrapIcons.calendar_check,
          color: widget.title.color.withValues(alpha: 0.8),
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          '획득: ${TitleHandler().formatAcquiredDate(widget.title.acquiredAt!)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  // 진행 정보
  Widget _buildProgressInfo() {
    // 현재 진행 값이 없으면 조건만 표시
    if (widget.currentValue == null) {
      return Text(
        _getConditionText(),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.withValues(alpha: 0.8),
        ),
      );
    }

    // 진행도 계산
    final progress = TitleHandler().getTitleProgress(
      widget.title,
      widget.currentValue!,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              BootstrapIcons.hourglass_split,
              color: Colors.grey.withValues(alpha: 0.8),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              _getConditionText(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 진행 상태 바
        Stack(
          children: [
            // 배경
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 진행 바
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.title.color.withValues(alpha: 0.7),
                      widget.title.color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.title.color.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 진행 텍스트
        Text(
          '${widget.currentValue}/${widget.title.conditionValue} (${(progress * 100).toInt()}%)',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  // 특수 효과
  Widget _buildSpecialEffect() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          painter: SpecialEffectPainter(
            color: widget.title.color,
            animValue: _animController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  // 칭호 아이콘 결정 (조건 타입에 따라)
  IconData _getTitleIcon() {
    if (widget.title.conditionType.startsWith('level_up')) {
      return BootstrapIcons.arrow_up_circle;
    } else if (widget.title.conditionType.startsWith('mission_complete')) {
      return BootstrapIcons.check2_all;
    } else if (widget.title.conditionType.startsWith('streak')) {
      return BootstrapIcons.calendar2_week;
    } else if (widget.title.conditionType.startsWith('job_mission')) {
      return BootstrapIcons.briefcase;
    } else if (widget.title.conditionType.startsWith('time_mission')) {
      return BootstrapIcons.clock;
    } else if (widget.title.conditionType.startsWith('day_complete')) {
      return BootstrapIcons.trophy;
    } else if (widget.title.conditionType.startsWith('hidden')) {
      return BootstrapIcons.gem;
    } else if (widget.title.conditionType.startsWith('registration')) {
      return BootstrapIcons.person_plus;
    }

    return BootstrapIcons.award;
  }

  // 조건 텍스트 생성
  String _getConditionText() {
    if (widget.title.conditionType.startsWith('level_up')) {
      return '레벨 ${widget.title.conditionValue} 도달';
    } else if (widget.title.conditionType.startsWith('mission_complete')) {
      return '미션 ${widget.title.conditionValue}개 완료';
    } else if (widget.title.conditionType.startsWith('streak')) {
      return '${widget.title.conditionValue}일 연속 접속';
    } else if (widget.title.conditionType.startsWith('job_mission')) {
      // job_mission_warrior 등 직업명 추출
      final parts = widget.title.conditionType.split('_');
      String jobName = '직업';
      if (parts.length > 2) {
        jobName = parts[2];
      }
      return '$jobName 미션 ${widget.title.conditionValue}개 완료';
    } else if (widget.title.id == 'title_early_bird') {
      return '새벽 ${widget.title.conditionValue}시 전에 미션 완료';
    } else if (widget.title.id == 'title_night_owl') {
      return '밤 12시 이후 미션 완료';
    } else if (widget.title.conditionType.startsWith('day_complete')) {
      return '하루 동안 모든 미션 완료';
    } else if (widget.title.conditionType.startsWith('hidden')) {
      return '???';
    }

    return widget.title.description;
  }
}

// 전설 등급 배경 효과
class LegendaryBackgroundPainter extends CustomPainter {
  final Color color;
  final double animValue;

  LegendaryBackgroundPainter({
    required this.color,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // 그라데이션 배경
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.3),
          Colors.black.withValues(alpha: 0.7),
          color.withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      bgPaint,
    );

    // 빛나는 파티클 효과
    final particlePaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // 고정 시드로 일관된 패턴

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * canvasSize.width;
      final y = random.nextDouble() * canvasSize.height;

      // 애니메이션 값에 따라 크기 변화
      final brightness = 0.3 + 0.7 * math.sin((animValue * 2 * math.pi) + i * 0.2);
      final particleSize = 1.0 + brightness * 2.0;

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        particlePaint..color = color.withValues(alpha: brightness * 0.6),
      );
    }

    // 움직이는 광선 효과
    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const rayCount = 6;
    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * math.pi * 2 + (animValue * math.pi);
      final x1 = centerX + math.cos(angle) * (canvasSize.width * 0.6);
      final y1 = centerY + math.sin(angle) * (canvasSize.height * 0.6);

      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(x1, y1),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LegendaryBackgroundPainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
}

// 특수 효과 페인터
class SpecialEffectPainter extends CustomPainter {
  final Color color;
  final double animValue;

  SpecialEffectPainter({
    required this.color,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 코너에 빛나는 효과
    final cornerPaint = Paint()
      ..color = color.withValues(alpha: 0.7 * (0.5 + 0.5 * math.sin(animValue * math.pi * 2)))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 좌상단 코너
    final path1 = Path()
      ..moveTo(0, 20)
      ..lineTo(0, 0)
      ..lineTo(20, 0);

    // 우상단 코너
    final path2 = Path()
      ..moveTo(size.width - 20, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 20);

    // 좌하단 코너
    final path3 = Path()
      ..moveTo(0, size.height - 20)
      ..lineTo(0, size.height)
      ..lineTo(20, size.height);

    // 우하단 코너
    final path4 = Path()
      ..moveTo(size.width - 20, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - 20);

    canvas.drawPath(path1, cornerPaint);
    canvas.drawPath(path2, cornerPaint);
    canvas.drawPath(path3, cornerPaint);
    canvas.drawPath(path4, cornerPaint);

    // 원형 글로우 효과
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.1 * (0.5 + 0.5 * math.sin(animValue * math.pi * 2 + math.pi / 2)))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.3 * (0.8 + 0.2 * math.sin(animValue * math.pi * 2)),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SpecialEffectPainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
}