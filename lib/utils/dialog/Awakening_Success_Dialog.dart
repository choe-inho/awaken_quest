import 'dart:ui';
import 'dart:math' as math;
import '../manager/Import_Manager.dart';

class AwakeningSuccessDialog extends StatefulWidget {
  const AwakeningSuccessDialog({
    super.key,
    required this.nickname,
    this.onComplete,
  });

  final String nickname;
  final VoidCallback? onComplete;

  @override
  State<AwakeningSuccessDialog> createState() => _AwakeningSuccessDialogState();
}

class _AwakeningSuccessDialogState extends State<AwakeningSuccessDialog>
    with SingleTickerProviderStateMixin {
  late int _countdown = 3;
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 맥박 애니메이션
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 글로우 애니메이션
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {});
    });

    // 파티클 초기화
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle.random());
    }

    // 카운트다운 타이머
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      elevation: 0,
      child: PopScope(
        canPop: false,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 배경 파티클 효과
            Positioned.fill(
              child: _buildParticlesEffect(),
            ),

            // 메인 컨테이너
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              from: 40,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 타이틀
                            _buildAnimatedTitle(),

                            const SizedBox(height: 16),

                            // 본문 텍스트
                            _buildMessageText(widget.nickname),

                            const SizedBox(height: 24),

                            // 카운트다운 타이머
                            _buildCountdownTimer(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 상단 효과
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: Center(
                child: FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: Lottie.network(
                    'https://assets2.lottiefiles.com/packages/lf20_obhph3sh.json',
                    height: 60,
                    width: 120,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),

            // 각성 에너지 빔 효과
            Positioned(
              top: -100,
              left: 0,
              right: 0,
              bottom: -100,
              child: FadeIn(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 1000),
                child: Center(
                  child: IgnorePointer(
                    child: _buildEnergyBeam(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: const [
            Colors.cyanAccent,
            Colors.white,
            Colors.cyanAccent,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(_controller.value * math.pi),
        ).createShader(bounds);
      },
      child: Flash(
        delay: const Duration(milliseconds: 200),
        duration: const Duration(milliseconds: 2000),
        child: const Text(
          '각성에 성공하였습니다',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.cyanAccent,
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMessageText(String nickname) {
    return FadeIn(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 800),
      child: Text(
        '$nickname 님에게 적합한 루트를 탐색합니다.',
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
    );
  }

  Widget _buildCountdownTimer() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      from: 30,
      child: SizedBox(
        height: 60,
        width: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 외부 원
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: CircleGlowPainter(
                    color: Colors.cyanAccent,
                    glowAmount: _glowAnimation.value,
                  ),
                  size: const Size(60, 60),
                );
              },
            ),

            // 회전하는 원
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 4 * math.pi,
                  child: CustomPaint(
                    painter: DashedCirclePainter(
                      color: Colors.cyanAccent.withValues(alpha: 0.8),
                      dashes: 12,
                    ),
                    size: const Size(40, 40),
                  ),
                );
              },
            ),

            // 진행 원
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.transparent,
                  width: 2,
                ),
              ),
              child: CircularProgressIndicator(
                value: _countdown / 3,
                color: Colors.cyanAccent,
                strokeCap: StrokeCap.round,
                strokeWidth: 2,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),

            // 카운트다운 숫자
            Text(
              '$_countdown',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.cyanAccent,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticlesEffect() {
    return IgnorePointer(
      child: CustomPaint(
        painter: AwakeningParticlesPainter(
          particles: _particles,
          animationValue: _controller.value,
        ),
      ),
    );
  }

  Widget _buildEnergyBeam() {
    return CustomPaint(
      painter: EnergyBeamPainter(
        animationValue: _controller.value,
        beamWidth: 80,
        color: Colors.cyanAccent,
      ),
      size: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
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

    // 각성 테마 색상들
    final colors = [
      Colors.cyanAccent,
      Colors.blue,
      const Color(0xFF00CFFF),
      Colors.white,
    ];

    return Particle(
      position: Offset(
        -100 + random.nextDouble() * 500,
        -100 + random.nextDouble() * 500,
      ),
      velocity: Offset(
        (random.nextDouble() - 0.5) * 2,
        (random.nextDouble() - 0.5) * 2,
      ),
      size: 1 + random.nextDouble() * 5,
      color: colors[random.nextInt(colors.length)],
      opacity: 0.3 + random.nextDouble() * 0.7,
    );
  }
}

// 각성용 파티클 페인터
class AwakeningParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  AwakeningParticlesPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];

      // 중심을 향해 모이는 파티클 효과
      final theta = math.atan2(particle.position.dy, particle.position.dx);
      final distance = math.sqrt(math.pow(particle.position.dx, 2) + math.pow(particle.position.dy, 2));

      final moveFactor = math.sin(animationValue * math.pi + i * 0.1) * 0.3;
      final adjustedDistance = distance * (1 - moveFactor);

      final posX = math.cos(theta) * adjustedDistance;
      final posY = math.sin(theta) * adjustedDistance;

      final position = Offset(
        centerX + posX,
        centerY + posY,
      );

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity * math.sin(animationValue * math.pi + i * 0.1))
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.8);

      // 더 길어진 흐름 효과를 위한 선
      final tailLength = particle.size * 5 * math.sin(animationValue * math.pi + i * 0.2);
      final tailStart = Offset(
        position.dx - math.cos(theta) * tailLength,
        position.dy - math.sin(theta) * tailLength,
      );

      // 꼬리 그리기
      final tailPaint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity * 0.5 * math.sin(animationValue * math.pi + i * 0.1))
        ..style = PaintingStyle.stroke
        ..strokeWidth = particle.size * 0.6
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);

      canvas.drawLine(tailStart, position, tailPaint);
      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 원형 글로우 효과
class CircleGlowPainter extends CustomPainter {
  final Color color;
  final double glowAmount;

  CircleGlowPainter({
    required this.color,
    required this.glowAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * glowAmount);

    canvas.drawCircle(center, radius, paint);

    // 추가 외부 글로우
    final outerPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * glowAmount)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 8 * glowAmount);

    canvas.drawCircle(center, radius + 4, outerPaint);
  }

  @override
  bool shouldRepaint(covariant CircleGlowPainter oldDelegate) {
    return oldDelegate.glowAmount != glowAmount;
  }
}

// 점선 원 페인터
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final int dashes;

  DashedCirclePainter({
    required this.color,
    required this.dashes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dashLength = (2 * math.pi) / (dashes * 2);

    for (int i = 0; i < dashes * 2; i += 2) {
      final startAngle = i * dashLength;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 에너지 빔 페인터
class EnergyBeamPainter extends CustomPainter {
  final double animationValue;
  final double beamWidth;
  final Color color;

  EnergyBeamPainter({
    required this.animationValue,
    required this.beamWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(animationValue.toInt() * 10000);

    // 중앙 빔
    final beamPaint = Paint()
      ..color = color.withValues(alpha: 0.15 + 0.1 * math.sin(animationValue * math.pi * 2))
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);

    final beamRect = Rect.fromCenter(
      center: center,
      width: beamWidth - 10 * math.sin(animationValue * math.pi * 4),
      height: size.height,
    );

    canvas.drawRect(beamRect, beamPaint);

    // 추가 장식 효과 - 빔 내부의 작은 불규칙한 빛
    for (int i = 0; i < 8; i++) {
      final sparkPaint = Paint()
        ..color = color.withValues(alpha: 0.4 + 0.3 * math.sin(animationValue * math.pi * 3 + i))
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

      final offsetX = (random.nextDouble() - 0.5) * beamWidth * 0.5;
      final offsetY = (random.nextDouble() - 0.5) * size.height * 0.7;
      final sparkRadius = 2 + random.nextDouble() * 8;

      canvas.drawCircle(
          center.translate(offsetX, offsetY),
          sparkRadius,
          sparkPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 실용적인 사용 함수
Future<void> showAwakeningDialog({
  required BuildContext context,
  required String nickname,
  VoidCallback? onComplete,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (BuildContext context) {
      return AwakeningSuccessDialog(
        nickname: nickname,
        onComplete: () {
          Navigator.of(context).pop();
          if (onComplete != null) {
            onComplete();
          }
        },
      );
    },
  );
}