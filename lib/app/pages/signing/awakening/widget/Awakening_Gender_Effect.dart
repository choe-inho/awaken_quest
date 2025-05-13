import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AwakeningGenderEffect extends StatefulWidget {
  const AwakeningGenderEffect({super.key, required this.gender});
  final String gender;

  @override
  State<AwakeningGenderEffect> createState() => _AwakeningGenderEffectState();
}

class _AwakeningGenderEffectState extends State<AwakeningGenderEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;

  final List<EnergyRay> _energyRays = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // 펄스 애니메이션 (캐릭터 크기 변화)
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 회전 애니메이션 (오라 효과 회전)
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // 발광 효과 애니메이션
    _glowAnimation = Tween<double>(begin: 0.5, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 에너지 광선 생성
    _createEnergyRays();
  }

  void _createEnergyRays() {
    final count = 12; // 광선 수
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi;
      final delay = _random.nextDouble() * 2.0; // 랜덤 지연 시간

      _energyRays.add(
        EnergyRay(
          angle: angle,
          length: 0.3 + _random.nextDouble() * 0.3,
          width: 3 + _random.nextDouble() * 3,
          delay: delay,
          color: widget.gender == '남자'
              ? HSLColor.fromAHSL(
            1.0,
            210 + _random.nextDouble() * 30, // 파란색 계열
            0.8,
            0.5 + _random.nextDouble() * 0.3,
          ).toColor()
              : HSLColor.fromAHSL(
            1.0,
            320 + _random.nextDouble() * 30, // 분홍/보라색 계열
            0.7,
            0.6 + _random.nextDouble() * 0.2,
          ).toColor(),
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
    // 성별에 따른 색상 설정
    final primaryColor = widget.gender == '남자'
        ? const Color(0xFF3A7FFF) // 남자: 푸른색
        : const Color(0xFFEC4899); // 여자: 분홍색

    final secondaryColor = widget.gender == '남자'
        ? const Color(0xFF00CFFD) // 남자: 하늘색
        : const Color(0xFFD946EF); // 여자: 보라색

    return Stack(
      fit: StackFit.expand,
      children: [
        // 배경 효과 (그라데이션 배경)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      primaryColor.withValues(alpha: 0.3 * _glowAnimation.value),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 에너지 광선 효과
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: EnergyRaysPainter(
                  rays: _energyRays,
                  progress: _controller.value,
                ),
              );
            },
          ),
        ),

        // 파티클 효과
        Positioned.fill(
          child: AwakeningParticles(
            color: primaryColor,
            secondaryColor: secondaryColor,
          ),
        ),

        // 메인 캐릭터 이미지
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        widget.gender == '남자'
                            ? 'assets/image/awakening/male_awakening.png'
                            : 'assets/image/awakening/female_awakening.png',
                      ),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 오라 효과 1 (회전하는 내부 오라)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Opacity(
                    opacity: 0.8,
                    child: Lottie.asset(
                      'assets/lottie/awakening/aura.json',
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 오라 효과 2 (반대로 회전하는 외부 오라)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_rotateAnimation.value * 0.7, // 반대 방향, 느린 속도
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Opacity(
                    opacity: 0.6,
                    child: Lottie.asset(
                      'assets/lottie/awakening/aura.json',
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 발광 효과 오버레이
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: [
                      primaryColor.withValues(alpha: 0.4 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 주변 마법 심볼 (룬 문자)
        ...List.generate(6, (index) {
          final angle = (index / 6) * 2 * math.pi;
          final radius = MediaQuery.of(context).size.width * 0.4;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;

          return Positioned(
            left: MediaQuery.of(context).size.width / 2 + x - 20,
            top: MediaQuery.of(context).size.height / 2 + y - 20,
            child: RuneSymbol(
              color: secondaryColor,
              size: 40,
              delayFactor: index * 0.2,
            ),
          );
        }),

        // 각성 플래시 효과 (중앙에서 퍼지는 빛)
        Positioned.fill(
          child: FlashEffect(
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}

// 각성 파티클 효과
class AwakeningParticles extends StatefulWidget {
  final Color color;
  final Color secondaryColor;

  const AwakeningParticles({
    super.key,
    required this.color,
    required this.secondaryColor,
  });

  @override
  State<AwakeningParticles> createState() => _AwakeningParticlesState();
}

class _AwakeningParticlesState extends State<AwakeningParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<AwakeningParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // 파티클 생성
    _generateParticles();
  }

  void _generateParticles() {
    final random = math.Random();

    for (int i = 0; i < 50; i++) {
      _particles.add(
        AwakeningParticle(
          position: Offset(
            random.nextDouble() * 300,
            random.nextDouble() * 600,
          ),
          velocity: Offset(
            (random.nextDouble() - 0.5) * 0.8,
            (random.nextDouble() - 0.5) * 0.8 - 1.0, // 주로 위로 향하게
          ),
          color: random.nextBool()
              ? widget.color.withValues(alpha: 0.6 + random.nextDouble() * 0.4)
              : widget.secondaryColor.withValues(alpha: 0.6 + random.nextDouble() * 0.4),
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
          painter: ParticlesPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// 파티클 페인터
class ParticlesPainter extends CustomPainter {
  final List<AwakeningParticle> particles;
  final double progress;

  ParticlesPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // 파티클 위치 업데이트
      particle.update(size, progress);

      // 파티클 그리기
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
        ..color = particle.color.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

      canvas.drawCircle(
        particle.position,
        particle.size * 1.8,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) => true;
}

// 각성 파티클
class AwakeningParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;

  AwakeningParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });

  void update(Size screenSize, double progress) {
    // 애니메이션 진행 속도에 따라 파티클을 움직임
    position += velocity;

    // 화면 바깥으로 나가면 다시 아래에서 생성
    if (position.dy < -size ||
        position.dy > screenSize.height + size ||
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

// 에너지 광선
class EnergyRay {
  final double angle;
  final double length;
  final double width;
  final double delay;
  final Color color;

  EnergyRay({
    required this.angle,
    required this.length,
    required this.width,
    required this.delay,
    required this.color,
  });
}

// 에너지 광선 페인터
class EnergyRaysPainter extends CustomPainter {
  final List<EnergyRay> rays;
  final double progress;

  EnergyRaysPainter({
    required this.rays,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width < size.height
        ? size.width / 2
        : size.height / 2;

    for (var ray in rays) {
      // 애니메이션 진행 계산 (지연 적용)
      final rayProgress = (progress + ray.delay) % 1.0;

      // 광선 길이 계산 (펄스 효과)
      final currentLength = maxRadius * ray.length * (0.5 + math.sin(rayProgress * math.pi * 2) * 0.5);

      // 각도에 따른 끝점 계산
      final endPoint = Offset(
        center.dx + math.cos(ray.angle) * currentLength,
        center.dy + math.sin(ray.angle) * currentLength,
      );

      // 광선 그리기
      final paint = Paint()
        ..color = ray.color.withValues(alpha: 0.7)
        ..strokeWidth = ray.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(center, endPoint, paint);

      // 발광 효과
      final glowPaint = Paint()
        ..color = ray.color.withValues(alpha: 0.3)
        ..strokeWidth = ray.width * 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawLine(center, endPoint, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant EnergyRaysPainter oldDelegate) => true;
}

// 룬 심볼 (주변에 떠다니는 마법 문자)
class RuneSymbol extends StatefulWidget {
  final Color color;
  final double size;
  final double delayFactor;

  const RuneSymbol({
    super.key,
    required this.color,
    required this.size,
    required this.delayFactor,
  });

  @override
  State<RuneSymbol> createState() => _RuneSymbolState();
}

class _RuneSymbolState extends State<RuneSymbol> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  final List<String> _runeChars = [
    '⚈', '⚇', '⚆', '⚉', '⚋', '⚊', '⚌', '⚍', '⚎'
  ];
  late String _runeChar;

  @override
  void initState() {
    super.initState();

    // 랜덤 룬 문자 선택
    _runeChar = _runeChars[math.Random().nextInt(_runeChars.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0, 0.4,
          curve: Curves.easeOut,
        ),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.9),
        weight: 20,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 지연 후 애니메이션 시작
    Future.delayed(Duration(milliseconds: (widget.delayFactor * 500).toInt()), () {
      if (mounted) {
        _controller.repeat(reverse: true);
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.3),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _runeChar,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: widget.size * 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 각성 플래시 효과 (주기적으로 번쩍이는 효과)
class FlashEffect extends StatefulWidget {
  final Color color;

  const FlashEffect({
    super.key,
    required this.color,
  });

  @override
  State<FlashEffect> createState() => _FlashEffectState();
}

class _FlashEffectState extends State<FlashEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _flashAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.3),
        weight: 5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.0),
        weight: 25,
      ),
    ]).animate(_controller);

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
      animation: _flashAnimation,
      builder: (context, child) {
        return _flashAnimation.value > 0
            ? Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 0),
              radius: 0.8,
              colors: [
                widget.color.withValues(alpha: _flashAnimation.value),
                Colors.transparent,
              ],
              stops: const [0.1, 1.0],
            ),
          ),
        )
            : const SizedBox.shrink();
      },
    );
  }
}