import 'dart:math' as math;
import 'package:awaken_quest/app/pages/signing/awakening/widget/Flaming_Aura.dart';
import 'package:awaken_quest/app/pages/signing/awakening/widget/Job_Image.dart';
import '../../../../utils/animation/Flip_Animation.dart';
import '../../../../utils/animation/Simmer_Text.dart';
import '../../../../utils/manager/Import_Manager.dart';
import '../../../widgets/Glass_Container.dart';
import '../../../widgets/Light_Overlay.dart';

class JobResult extends GetView<UserController> {
  const JobResult({super.key});

  @override
  Widget build(BuildContext context) {
    // 직업별 특성 색상
    final jobColor = JobInfo.jobToColor(controller.user.value?.job ?? '전사');

    // 직업 확인 (널 체크)
    final job = controller.user.value?.job ?? '전사';

    // 직업별 배경 에셋 경로
    final backdropPath = job == "전사" ? 'assets/image/job/backdrop/warrior_backdrop.png' :
    job == "마법사" ? 'assets/image/job/backdrop/magic_backdrop.png' :
    job == "힐러" ? 'assets/image/job/backdrop/healer_backdrop.png' :
    job == "대장장이" ? 'assets/image/job/backdrop/smith_backdrop.png' :
    'assets/image/job/backdrop/explorer_backdrop.png';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Stack(
              children: [
                // 배경 에너지 파티클 효과
                Positioned.fill(
                  child: JobParticlesEffect(color: jobColor),
                ),

                // 중앙을 기준으로 방사형으로 뻗어나가는 에너지 선
                Positioned.fill(
                  child: CustomPaint(
                    painter: EnergyLinesPainter(color: jobColor),
                  ),
                ),

                // 메인 컨텐츠
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 상단 타이틀
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: ShimmerText(
                          text: '각성 완료',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: jobColor,
                          ),
                        ),
                      ),

                      // 강화된 네온 디바이더
                      EnhancedNeonDivider(color: jobColor),

                      // 직업 이미지 섹션
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Center(
                          child: FadeInUpBig(
                            from: 20,
                            duration: const Duration(milliseconds: 800),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 외부 장식 링 (회전)
                                RotatingRing(color: jobColor, size: 320),

                                // 회전하는 백드롭 이미지
                                ElasticIn(
                                  delay: const Duration(milliseconds: 300),
                                  child: EnhancedRotatingBox(
                                    imagePath: backdropPath,
                                    duration: const Duration(seconds: 8),
                                    size: 300,
                                    glowColor: jobColor,
                                  ),
                                ),

                                // 직업 이미지 + 화염 오라
                                SizedBox(
                                  height: 300,
                                  child: FittedBox(
                                    child: JobImage(job: job)
                                  ),
                                ),

                                // 전경 이펙트 파티클
                                ForegroundParticles(color: jobColor),

                                // 직업 아이콘 장식
                                ...List.generate(
                                  3,
                                      (index) => JobIconDecoration(
                                    job: job,
                                    index: index,
                                    color: jobColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 설명 텍스트 섹션
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                        child: GlassContainer(
                          color: jobColor.withValues(alpha: 0.15),
                          child: Column(
                            children: [
                              FadeInUp(
                                from: 8,
                                delay: const Duration(milliseconds: 300),
                                child: Text(
                                  '각성이 완료되었습니다.',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withValues(alpha: 0.95),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              FadeInUp(
                                from: 8,
                                delay: const Duration(milliseconds: 600),
                                child: ShimmerText(
                                  text: '[ ${job} ]',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: jobColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              FadeInUp(
                                from: 8,
                                delay: const Duration(milliseconds: 800),
                                child: Text(
                                  JobInfo.awakenText[job]!['firstText']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              FadeInUp(
                                from: 8,
                                delay: const Duration(milliseconds: 900),
                                child: Text(
                                  JobInfo.awakenText[job]!['secondText']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),

                      // 확인 버튼
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Center(
                          child: EnhancedStatusButton(
                            label: '확인',
                            color: jobColor,
                            onPressed: ()=>  Get.offAllNamed('/home')
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 오버레이 빛 효과
                Positioned.fill(
                  child: IgnorePointer(child: LightOverlayEffect(color: jobColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 향상된 네온 디바이더
class EnhancedNeonDivider extends StatelessWidget {
  final Color color;

  const EnhancedNeonDivider({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 기존 네온 디바이더
        NeonDivider(color: color),

        // 추가 발광 효과
        Container(
          width: 100,
          height: 4,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
        ),

        // 끝 부분 점
        ...[-1, 1].map((direction) => Positioned(
          left: direction == -1 ? MediaQuery.of(context).size.width / 2 - 100 : null,
          right: direction == 1 ? MediaQuery.of(context).size.width / 2 - 100 : null,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

// 향상된 회전 박스
class EnhancedRotatingBox extends StatefulWidget {
  final String imagePath;
  final Duration duration;
  final double size;
  final Color glowColor;

  const EnhancedRotatingBox({
    super.key,
    required this.imagePath,
    required this.duration,
    required this.size,
    required this.glowColor,
  });

  @override
  State<EnhancedRotatingBox> createState() => _EnhancedRotatingBoxState();
}

class _EnhancedRotatingBoxState extends State<EnhancedRotatingBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 향상된 화염 오라
class EnhancedFlamingAura extends StatelessWidget {
  final Color color;
  final Widget child;
  final double intensity;

  const EnhancedFlamingAura({
    super.key,
    required this.color,
    required this.child,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 기존 화염 오라
        FlamingAura(color: color, child: SizedBox()),

        // 메인 캐릭터 이미지
        Positioned.fill(
          child: FlipAnimation(
            axis: Axis.vertical,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: child
          ),
        ),
      ],
    );
  }
}

// 회전 링 애니메이션
class RotatingRing extends StatefulWidget {
  final Color color;
  final double size;

  const RotatingRing({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  State<RotatingRing> createState() => _RotatingRingState();
}

class _RotatingRingState extends State<RotatingRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withValues(alpha: 0.7),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(12, (index) {
                final angle = index * (math.pi / 6);
                final x = math.cos(angle) * (widget.size / 2 - 5);
                final y = math.sin(angle) * (widget.size / 2 - 5);

                return Positioned(
                  left: widget.size / 2 + x - 4,
                  top: widget.size / 2 + y - 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.7),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

// 직업 아이콘 장식
class JobIconDecoration extends StatefulWidget {
  final String job;
  final int index;
  final Color color;

  const JobIconDecoration({
    super.key,
    required this.job,
    required this.index,
    required this.color,
  });

  @override
  State<JobIconDecoration> createState() => _JobIconDecorationState();
}

class _JobIconDecorationState extends State<JobIconDecoration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _orbitAnimation;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _orbitAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = 150.0; // 궤도 반경
        final angle = _orbitAnimation.value + (widget.index * (2 * math.pi / 3));

        return Transform.translate(
          offset: Offset(
            math.cos(angle) * offset,
            math.sin(angle) * offset,
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.7),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 직업 파티클 효과
class JobParticlesEffect extends StatefulWidget {
  final Color color;

  const JobParticlesEffect({
    super.key,
    required this.color,
  });

  @override
  State<JobParticlesEffect> createState() => _JobParticlesEffectState();
}

class _JobParticlesEffectState extends State<JobParticlesEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<JobParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _generateParticles();
  }

  void _generateParticles() {
    final random = math.Random();

    for (int i = 0; i < 50; i++) {
      _particles.add(
        JobParticle(
          position: Offset(
            random.nextDouble() * 400,
            random.nextDouble() * 800,
          ),
          velocity: Offset(
            (random.nextDouble() - 0.5) * 0.3,
            -0.3 - random.nextDouble() * 0.5,
          ),
          color: HSLColor.fromColor(widget.color)
              .withLightness(0.5 + random.nextDouble() * 0.5)
              .toColor()
              .withValues(alpha: 0.3 + random.nextDouble() * 0.3),
          size: 1 + random.nextDouble() * 3,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: JobParticlesPainter(
            particles: _particles,
            color: widget.color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// 직업 파티클 페인터
class JobParticlesPainter extends CustomPainter {
  final List<JobParticle> particles;
  final Color color;

  JobParticlesPainter({
    required this.particles,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(size);

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );

      // 발광 효과
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        particle.position,
        particle.size * 2,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant JobParticlesPainter oldDelegate) => true;
}

// 직업 파티클
class JobParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;

  JobParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });

  void update(Size screenSize) {
    position += velocity;

    // 화면 밖으로 나가면 아래서 다시 시작
    if (position.dy < -size ||
        position.dx < -size ||
        position.dx > screenSize.width + size) {
      position = Offset(
        math.Random().nextDouble() * screenSize.width,
        screenSize.height + size,
      );
      size = 1 + math.Random().nextDouble() * 3;
    }
  }
}

// 전경 파티클
class ForegroundParticles extends StatefulWidget {
  final Color color;

  const ForegroundParticles({
    super.key,
    required this.color,
  });

  @override
  State<ForegroundParticles> createState() => _ForegroundParticlesState();
}

class _ForegroundParticlesState extends State<ForegroundParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SparklesPainter(
            color: widget.color,
            progress: _controller.value,
          ),
          size: const Size(300, 300),
        );
      },
    );
  }
}

// 스파클 페인터
class SparklesPainter extends CustomPainter {
  final Color color;
  final double progress;
  final List<Sparkle> _sparkles = [];

  SparklesPainter({
    required this.color,
    required this.progress,
  }) {
    if (_sparkles.isEmpty) {
      _generateSparkles();
    }
  }

  void _generateSparkles() {
    final random = math.Random();

    for (int i = 0; i < 20; i++) {
      _sparkles.add(
        Sparkle(
          x: -150 + random.nextDouble() * 300,
          y: -150 + random.nextDouble() * 300,
          size: 1 + random.nextDouble() * 3,
          angle: random.nextDouble() * math.pi * 2,
          delay: random.nextDouble(),
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var sparkle in _sparkles) {
      final adjustedProgress = (progress + sparkle.delay) % 1.0;

      // 스파클 깜빡임 효과
      final opacity = math.sin(adjustedProgress * math.pi * 2) * 0.8;

      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // 스파클 위치 계산
      final centerX = size.width / 2;
      final centerY = size.height / 2;

      // 스파클 그리기
      canvas.save();
      canvas.translate(centerX + sparkle.x, centerY + sparkle.y);
      canvas.rotate(sparkle.angle);

      // 마름모꼴 스파클
      final path = Path()
        ..moveTo(0, -sparkle.size * 2)
        ..lineTo(sparkle.size, 0)
        ..lineTo(0, sparkle.size * 2)
        ..lineTo(-sparkle.size, 0)
        ..close();

      canvas.drawPath(path, paint);

      // 발광 효과
      final glowPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawPath(path, glowPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SparklesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// 스파클 클래스
class Sparkle {
  final double x;
  final double y;
  final double size;
  final double angle;
  final double delay;

  Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.angle,
    required this.delay,
  });
}

// 에너지 라인 페인터
class EnergyLinesPainter extends CustomPainter {
  final Color color;

  EnergyLinesPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 + 60; // 직업 이미지 중심점

    // 바닥에서 중심점을 향해 방사형으로 선을 그림
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 발광 효과용 페인트
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final count = 12;
    final angleStep = math.pi / count;

    for (int i = 0; i < count; i++) {
      final angle = (i * angleStep) - (math.pi / 2);

      // 시작점과 끝점 계산
      final startX = centerX + math.cos(angle) * 30;
      final startY = centerY + math.sin(angle) * 30;

      final endX = centerX + math.cos(angle) * size.width;
      final endY = centerY + math.sin(angle) * size.height;

      // 에너지 라인 그리기
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // 발광 효과 라인
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



// 향상된 상태 버튼
class EnhancedStatusButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const EnhancedStatusButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<EnhancedStatusButton> createState() => _EnhancedStatusButtonState();
}

class _EnhancedStatusButtonState extends State<EnhancedStatusButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return InkWell(
           onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.2),
                  blurRadius:  10,
                  spreadRadius:  1,
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        );
      },
    );
  }
}

