import 'dart:ui';
import 'dart:math' as math;
import 'package:awaken_quest/utils/App_Theme.dart';
import 'package:flutter/material.dart';
import '../manager/Import_Manager.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';

class BasicDialog extends StatefulWidget {
  const BasicDialog({
    super.key,
    required this.mainTitle,
    required this.text,
    this.confirmButtonText,
    this.cancelButtonText,
    this.onConfirm,
    this.onCancel,
    this.showEffects = true,
  });

  final String mainTitle;
  final String text;
  final String? confirmButtonText;
  final String? cancelButtonText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showEffects;

  @override
  State<BasicDialog> createState() => _BasicDialogState();
}

class _BasicDialogState extends State<BasicDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 스케일 애니메이션
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    // 페이드 애니메이션
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // 글로우 애니메이션
    _glowAnimation = Tween<double>(begin: 0.1, end: 0.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {});
    });

    // 파티클 초기화
    if (widget.showEffects) {
      for (int i = 0; i < 20; i++) {
        _particles.add(Particle.random());
      }
    }

    // 애니메이션 시작
    _controller.forward();
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
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleDialogClose();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildDialogContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 배경 파티클 효과
          if (widget.showEffects) _buildParticlesEffect(),

          // 메인 컨테이너
          Container(
            constraints: const BoxConstraints(maxWidth: 350),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              border: Border.all(
                color: const Color(0xFF00CFFF).withValues(alpha: 0.6),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00CFFF).withValues(alpha: _glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타이틀
                _buildAnimatedTitle(),

                const SizedBox(height: 16),

                // 본문 텍스트
                FlipInX(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.95),
                      shadows: [
                        Shadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.7),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                // 버튼 영역
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 500),
                  from: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 취소 버튼 (제공된 경우)
                      if (widget.cancelButtonText != null) ...[
                        _buildButton(
                          text: widget.cancelButtonText!,
                          color: Colors.redAccent,
                          onTap: () => _handleButtonPress(false),
                        ),
                        const SizedBox(width: 16),
                      ],

                      // 확인 버튼
                      _buildButton(
                        text: widget.confirmButtonText ?? '확인',
                        color: const Color(0xFF00CFFF),
                        onTap: () => _handleButtonPress(true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 추가 효과: 모서리 장식
          if (widget.showEffects) ..._buildCornerEffects(),
        ],
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: const [
            Color(0xFF80E5FF),
            Colors.white,
            Color(0xFF00CFFF),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(_controller.value * math.pi * 2),
        ).createShader(bounds);
      },
      child: Flash(
        delay: const Duration(milliseconds: 400),
        duration: const Duration(milliseconds: 1500),
        child: Text(
          widget.mainTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: const Color(0xFF00CFFF).withValues(alpha: 0.9),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return HunterButton(
      text: text,
      color: color,
      onTap: onTap,
    );
  }

  Widget _buildParticlesEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: ParticlesPainter(
            particles: _particles,
            animationValue: _controller.value,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerEffects() {
    return [
      // 상단 효과
      Positioned(
        top: -15,
        left: 0,
        right: 0,
        child: Center(
          child: FadeIn(
            delay: const Duration(milliseconds: 300),
            child: Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_obhph3sh.json',
              height: 40,
              width: 80,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),

      // 하단 효과
      Positioned(
        bottom: -15,
        left: 0,
        right: 0,
        child: Center(
          child: FadeIn(
            delay: const Duration(milliseconds: 400),
            child: Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_obhph3sh.json',
              height: 40,
              width: 80,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    ];
  }

  void _handleButtonPress(bool isConfirm) {
    if (isConfirm) {
      if (widget.onConfirm != null) {
        widget.onConfirm!();
      } else {
        Get.back(result: true);
      }
    } else {
      if (widget.onCancel != null) {
        widget.onCancel!();
      } else {
        Get.back(result: false);
      }
    }
  }

  void _handleDialogClose() {
    _controller.reverse().then((_) {
      Get.back(result: false);
    });
  }
}

// 커스텀 버튼 위젯
class HunterButton extends StatefulWidget {
  final String text;
  final Color? color;
  final VoidCallback onTap;

  const HunterButton({
    super.key,
    required this.text,
    this.color,
    required this.onTap,
  });

  @override
  State<HunterButton> createState() => _HunterButtonState();
}

class _HunterButtonState extends State<HunterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  Color color = AppTheme.glowingBlue;

  @override
  void initState() {
    super.initState();

    if(widget.color != null){
      color = widget.color!;
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // 버튼 효과
          _controller.reverse(from: 1.2).then((_) {
            _controller.forward().then((_) {
              widget.onTap();
            });
          });
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(
                    color: color.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: _glowAnimation.value),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: color.withValues(alpha: 0.8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// 파티클 클래스
class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.opacity,
  });

  static Particle random() {
    final random = math.Random();

    // 헌터 테마 색상들
    final colors = [
      const Color(0xFF00CFFF),
      const Color(0xFF80E5FF),
      const Color(0xFFB3F0FF),
      Colors.white,
    ];

    return Particle(
      position: Offset(
        -50 + random.nextDouble() * 350,
        -50 + random.nextDouble() * 350,
      ),
      velocity: Offset(
        (random.nextDouble() - 0.5) * 1.5,
        (random.nextDouble() - 0.5) * 1.5,
      ),
      size: 1 + random.nextDouble() * 4,
      color: colors[random.nextInt(colors.length)],
      opacity: 0.3 + random.nextDouble() * 0.6,
    );
  }
}

// 파티클 페인터
class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlesPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];

      // 애니메이션 값에 따라 파티클 이동 패턴
      final position = Offset(
        centerX + particle.position.dx + math.sin((animationValue * 2 + i) * 0.2) * 15,
        centerY + particle.position.dy + math.cos((animationValue * 2 + i) * 0.2) * 15,
      );

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity * math.sin(animationValue * math.pi + i * 0.1))
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

