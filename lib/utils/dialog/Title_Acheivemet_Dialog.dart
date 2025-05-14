// lib/app/widgets/Title_Achievement_Dialog.dart
import 'package:awaken_quest/model/Title_Model.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'dart:math' as math;
import 'dart:ui';

class TitleAchievementDialog extends StatefulWidget {
  final TitleModel title;

  const TitleAchievementDialog({
    super.key,
    required this.title,
  });

  @override
  State<TitleAchievementDialog> createState() => _TitleAchievementDialogState();
}

class _TitleAchievementDialogState extends State<TitleAchievementDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _backgroundOpacityAnimation;

  final List<TitleParticle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // 스케일 애니메이션
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // 회전 애니메이션
    _rotateAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // 글로우 애니메이션
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
      ),
    );

    // 배경 투명도 애니메이션
    _backgroundOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // 파티클 생성
    _generateParticles();

    // 애니메이션 시작
    _controller.forward();
  }

  void _generateParticles() {
    // 칭호 등급에 따라 파티클 수 조정
    final particleCount = 30 + (widget.title.rarity * 15);

    for (int i = 0; i < particleCount; i++) {
      _particles.add(
        TitleParticle(
          position: Offset.zero,
          velocity: Offset(
            (_random.nextDouble() * 2 - 1) * 3,
            (_random.nextDouble() * 2 - 1) * 3,
          ),
          size: 1 + _random.nextDouble() * 3,
          color: _getParticleColor(),
          lifespan: 0.8 + _random.nextDouble() * 0.2,
          startDelay: _random.nextDouble() * 0.3,
        ),
      );
    }
  }

  Color _getParticleColor() {
    final baseColor = widget.title.color;
    final colorVariation = _random.nextDouble();

    if (colorVariation < 0.7) {
      // 70%는 기본 색상과 유사한 색
      return baseColor;
    } else if (colorVariation < 0.9) {
      // 20%는 밝은 버전
      return Color.lerp(baseColor, Colors.white, 0.5)!;
    } else {
      // 10%는 흰색 (반짝임 효과)
      return Colors.white;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 배경 블러 효과
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 8.0 * _backgroundOpacityAnimation.value,
                      sigmaY: 8.0 * _backgroundOpacityAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withValues(
                        alpha: 0.5 * _backgroundOpacityAnimation.value,
                      ),
                    ),
                  ),
                ),

                // 파티클 효과
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: TitleParticlePainter(
                        particles: _particles,
                        progress: _controller.value,
                      ),
                    ),
                  ),
                ),

                // 주요 콘텐츠
                Transform.rotate(
                  angle: _rotateAnimation.value * math.pi,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.title.color.withValues(
                            alpha: 0.8 * _glowAnimation.value,
                          ),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.title.color.withValues(
                              alpha: 0.5 * _glowAnimation.value,
                            ),
                            blurRadius: 20,
                            spreadRadius: 5 * _glowAnimation.value,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 상단 효과 아이콘
                          _buildTrophyIcon(),

                          const SizedBox(height: 16),

                          // 축하 텍스트
                          Flash(
                            duration: const Duration(milliseconds: 1500),
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    widget.title.color,
                                    Colors.white,
                                    widget.title.color,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Text(
                                '새로운 칭호 획득!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 칭호 이름
                          FadeIn(
                            delay: const Duration(milliseconds: 500),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: widget.title.color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: widget.title.color.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                widget.title.name,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: widget.title.color,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: widget.title.color.withValues(alpha: 0.8),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 칭호 설명
                          FadeInUp(
                            delay: const Duration(milliseconds: 700),
                            from: 20,
                            child: Text(
                              widget.title.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 등급 뱃지
                          FadeInUp(
                            delay: const Duration(milliseconds: 900),
                            from: 20,
                            child: _buildRarityBadge(),
                          ),

                          const SizedBox(height: 24),

                          // 확인 버튼
                          FadeInUp(
                            delay: const Duration(milliseconds: 1100),
                            from: 20,
                            child: _buildConfirmButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 상단 왕관 효과 (전설, 영웅 등급만)
                if (widget.title.rarity >= 2)
                  Positioned(
                    top: -40,
                    child: FadeIn(
                      delay: const Duration(milliseconds: 600),
                      child: _buildCrownEffect(),
                    ),
                  ),

                // 코너 각성 효과
                ...List.generate(4, (index) {
                  final positions = [
                    const Offset(-30, -30), // 좌상단
                    const Offset(30, -30),  // 우상단
                    const Offset(-30, 30),  // 좌하단
                    const Offset(30, 30),   // 우하단
                  ];

                  return Positioned(
                    left: positions[index].dx < 0 ? positions[index].dx : null,
                    right: positions[index].dx > 0 ? positions[index].dx : null,
                    top: positions[index].dy < 0 ? positions[index].dy : null,
                    bottom: positions[index].dy > 0 ? positions[index].dy : null,
                    child: FadeIn(
                      delay: Duration(milliseconds: 800 + (index * 100)),
                      child: _buildCornerEffect(),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  // 트로피 아이콘
  Widget _buildTrophyIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.title.color.withValues(alpha: 0.2),
        border: Border.all(
          color: widget.title.color.withValues(alpha: 0.7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.title.color.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: math.sin(_controller.value * math.pi * 2) * 0.05,
            child: Center(
              child: Icon(
                _getTitleIcon(),
                color: widget.title.color,
                size: 40,
              ),
            ),
          );
        },
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
        rarityText = '전설 등급';
        break;
      case 2:
        badgeColor = Colors.purple;
        rarityText = '영웅 등급';
        break;
      case 1:
        badgeColor = Colors.blue;
        rarityText = '희귀 등급';
        break;
      case 0:
      default:
        badgeColor = Colors.green;
        rarityText = '일반 등급';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: Text(
        rarityText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  // 확인 버튼
  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.title.color.withValues(alpha: 0.2),
        foregroundColor: widget.title.color,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: widget.title.color.withValues(alpha: 0.7),
            width: 2,
          ),
        ),
        elevation: 5,
        shadowColor: widget.title.color.withValues(alpha: 0.5),
      ),
      child: const Text(
        '확인',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 왕관 효과
  Widget _buildCrownEffect() {
    // 애니메이션 위젯 대신 Lottie 애니메이션을 사용하면 더 화려해 질 수 있음
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            widget.title.color,
            widget.title.color.withValues(alpha: 0.5),
            widget.title.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          widget.title.rarity >= 3
              ? BootstrapIcons.stars
              : BootstrapIcons.star,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  // 코너 효과
  Widget _buildCornerEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * math.pi * 2,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.title.color.withValues(alpha: 0.7),
                  widget.title.color.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.5 + 0.5 * math.sin(_controller.value * math.pi * 2),
                  ),
                ),
              ),
            ),
          ),
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
}

// 칭호 파티클 클래스
class TitleParticle {
  Offset position;
  final Offset velocity;
  final double size;
  final Color color;
  final double lifespan;
  final double startDelay;

  TitleParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.lifespan,
    required this.startDelay,
  });

  void update(double progress, Size screenSize) {
    // 시작 지연 처리
    if (progress < startDelay) return;

    final adjustedProgress = (progress - startDelay) / (1 - startDelay);

    // 생명 주기가 끝나면 이동 중지
    if (adjustedProgress > lifespan) return;

    // 위치 업데이트
    position += velocity;
  }

  double getOpacity(double progress) {
    if (progress < startDelay) return 0.0;

    final adjustedProgress = (progress - startDelay) / (1 - startDelay);

    // 페이드 인/아웃 효과
    if (adjustedProgress < 0.2) {
      return adjustedProgress / 0.2; // 페이드 인
    } else if (adjustedProgress > lifespan - 0.2) {
      return (lifespan - adjustedProgress) / 0.2; // 페이드 아웃
    }

    return 1.0;
  }
}

// 칭호 파티클 페인터
class TitleParticlePainter extends CustomPainter {
  final List<TitleParticle> particles;
  final double progress;

  TitleParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      // 시작 위치를 중앙으로 설정
      if (particle.position == Offset.zero) {
        particle.position = center;
      }

      // 파티클 업데이트
      particle.update(progress, size);

      // 파티클 불투명도
      final opacity = particle.getOpacity(progress);
      if (opacity <= 0) continue;

      // 파티클 그리기
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );

      // 발광 효과
      if (particle.size > 2.0) {
        final glowPaint = Paint()
          ..color = particle.color.withValues(alpha: opacity * 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawCircle(
          particle.position,
          particle.size * 2,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TitleParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// 다이얼로그 표시 유틸리티 함수
Future<void> showTitleAchievementDialog(BuildContext context, TitleModel title) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (BuildContext context) {
      return TitleAchievementDialog(title: title);
    },
  );
}