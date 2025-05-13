import 'dart:math' as math;
import 'package:awaken_quest/utils/Animation_Utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:awaken_quest/app/pages/signing/login/Google_Login.dart';
import 'package:hive/hive.dart';
import '../../../../utils/manager/Import_Manager.dart';
import '../../../widgets/Digital_Effect.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final List<RuneParticle> _runeParticles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 설정
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 펄스 애니메이션
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // 룬 파티클 생성
    _generateRuneParticles();
  }

  void _generateRuneParticles() {
    for (int i = 0; i < 15; i++) {
      _runeParticles.add(
        RuneParticle(
          position: Offset(
            _random.nextDouble() * Get.width,
            _random.nextDouble() * Get.height,
          ),
          size: 12.0 + _random.nextDouble() * 16.0,
          opacity: 0.1 + _random.nextDouble() * 0.3,
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 0.3,
            -0.1 - _random.nextDouble() * 0.3,
          ),
          runeIndex: _random.nextInt(7),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 기존 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/image/widget/background/login_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. 반투명 블러 + 어두운 필터 (더 고급스러운 그라데이션으로 변경)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    const Color(0xFF050915).withValues(alpha: 0.8),
                    const Color(0xFF0A1030).withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          // 3. 룬 파티클 효과
          CustomPaint(
            painter: RuneParticlePainter(
              _runeParticles,
              _animationController,
            ),
            size: Size(Get.width, Get.height),
          ),

          // 4. 에너지 광선 효과
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: EnergyRaysPainter(
                    glowIntensity: _pulseAnimation.value,
                    baseColor: const Color(0xFF3A7FFF),
                  ),
                  size: Size(Get.width, Get.height),
                );
              },
            ),
          ),

          // 5. 중앙 멘트 & 버튼 (향상된 애니메이션과 효과)
          Center(
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              from: 40,
              child: GlowingContainer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 8. 메인 타이틀 (그라데이션 효과 추가)
                        ShimmerGradientText(
                          '잊혀진 힘이\n당신을 부르고 있습니다',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 9. 서브 타이틀
                        Text(
                          '자신의 한계를 시험해보세요',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // 10. 향상된 로그인 버튼
                        GoogleSignInButton(),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 12. 하단 로고 및 버전
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Center(
                child: Column(
                  children: [
                    SvgPicture.asset('assets/image/app/text_logo.svg', height: 40,),
                    const SizedBox(height: 6),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 향상된 글리치 컨테이너
class EnhancedGlitchContainer extends StatefulWidget {
  final Widget child;

  const EnhancedGlitchContainer({
    super.key,
    required this.child,
  });

  @override
  State<EnhancedGlitchContainer> createState() => _EnhancedGlitchContainerState();
}

class _EnhancedGlitchContainerState extends State<EnhancedGlitchContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _glitchAmount = 0;
  bool _isGlitching = false;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..addListener(_triggerGlitch);

    _controller.repeat();
  }

  void _triggerGlitch() {
    // 랜덤하게 글리치 효과 발생
    if (!_isGlitching && _random.nextDouble() < 0.03) {
      setState(() {
        _isGlitching = true;
        _glitchAmount = 2 + _random.nextDouble() * 8;
      });

      // 짧은 글리치 효과 후 원래 상태로 복귀
      Future.delayed(Duration(milliseconds: 50 + _random.nextInt(150)), () {
        if (mounted) {
          setState(() {
            _isGlitching = false;
            _glitchAmount = 0;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.85,
      padding: const EdgeInsets.all(2), // 테두리 두께
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3A7FFF),
            Color(0xFF9B4DFF),
            Color(0xFF3A7FFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A7FFF).withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFF9B4DFF).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 메인 배경
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: const Color(0xFF0A0A0A),
              child: widget.child,
            ),
          ),

          // 글리치 효과 레이어
          if (_isGlitching) ...[
            Positioned(
              left: _glitchAmount,
              right: -_glitchAmount,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: Colors.cyan.withValues(alpha: 0.3),
                  child: widget.child,
                ),
              ),
            ),
            Positioned(
              left: -_glitchAmount,
              right: _glitchAmount,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: Colors.red.withValues(alpha: 0.3),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 그라데이션 텍스트 위젯 (깜빡이는 효과 추가)
class ShimmerGradientText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ShimmerGradientText(
      this.text, {
        Key? key,
        this.style,
        this.textAlign,
      }) : super(key: key);

  @override
  State<ShimmerGradientText> createState() => _ShimmerGradientTextState();
}

class _ShimmerGradientTextState extends State<ShimmerGradientText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFF64B5F6),  // 하늘색
                Color(0xFFFFFFFF),  // 흰색 (반짝임)
                Color(0xFF9B4DFF),  // 보라색
              ],
              stops: [
                _shimmerAnimation.value - 1,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 1,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
          ),
        );
      },
    );
  }
}

// 룬 파티클 클래스
class RuneParticle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  int runeIndex;

  RuneParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.runeIndex,
  });

  void update(Size screenSize) {
    position += velocity;

    // 화면 밖으로 나가면 다시 아래에서 시작
    if (position.dy < -size) {
      position = Offset(
        math.Random().nextDouble() * screenSize.width,
        screenSize.height + size,
      );
      opacity = 0.1 + math.Random().nextDouble() * 0.3;
      size = 12.0 + math.Random().nextDouble() * 16.0;
    }
  }
}

// 룬 파티클 페인터
class RuneParticlePainter extends CustomPainter {
  final List<RuneParticle> particles;
  final Animation<double> animation;

  RuneParticlePainter(this.particles, this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final runeSigns = ['⚉', '⚇', '⚈', '⚆', '⚊', '⚋', '⚌'];

    for (var particle in particles) {
      particle.update(size);

      final textStyle = TextStyle(
        color: Colors.white.withValues(alpha: particle.opacity),
        fontSize: particle.size,
        fontWeight: FontWeight.w400,
      );

      final textSpan = TextSpan(
        text: runeSigns[particle.runeIndex],
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, particle.position);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 에너지 광선 페인터
class EnergyRaysPainter extends CustomPainter {
  final double glowIntensity;
  final Color baseColor;
  final math.Random random = math.Random();

  EnergyRaysPainter({
    required this.glowIntensity,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rayCount = 8;
    final centerX = size.width / 2;
    final centerY = size.height * 0.4; // 약간 위쪽에 중심점

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * math.pi;
      final rayLength = size.width * (0.4 + 0.1 * glowIntensity);

      final startX = centerX;
      final startY = centerY;
      final endX = centerX + rayLength * math.cos(angle);
      final endY = centerY + rayLength * math.sin(angle);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            baseColor.withValues(alpha: 0.4 * glowIntensity),
            baseColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(centerX, centerY),
            radius: rayLength,
          ),
        )
        ..strokeWidth = 20 + (10 * glowIntensity)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant EnergyRaysPainter oldDelegate) =>
      oldDelegate.glowIntensity != glowIntensity;
}

