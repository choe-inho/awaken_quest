import '../../utils/manager/Import_Manager.dart';
import 'dart:math' as math;

class HunterEffectOverlay extends StatefulWidget {
  const HunterEffectOverlay({
    super.key,
    this.count = 25,
    this.height = 300,
    this.primaryColor = const Color(0xFF5D00FF),
    this.secondaryColor = const Color(0xFFFF5500),
  });

  final int count;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  State<HunterEffectOverlay> createState() => _HunterEffectOverlayState();
}

class _HunterEffectOverlayState extends State<HunterEffectOverlay> with TickerProviderStateMixin {
  final Random _random = Random();
  late final int _effectCount;
  final List<AnimationController> _controllers = [];
  late final List<Widget> _effects;

  @override
  void initState() {
    super.initState();
    _effectCount = widget.count;
    _effects = List.generate(_effectCount, (_) => _buildRandomEffect());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  Widget _buildRandomEffect() {
    // 효과 종류를 랜덤하게 선택
    final effectType = _random.nextInt(5);

    switch (effectType) {
      case 0:
        return _buildEnergyLine();
      case 1:
        return _buildMagicCircle();
      case 2:
        return _buildHunterSymbol();
      case 3:
        return _buildLightningEffect();
      case 4:
      default:
        return _buildEnergyParticle();
    }
  }

  Widget _buildEnergyLine() {
    final double left = _random.nextDouble() * Get.width - (Get.width / 2);
    final double top = _random.nextDouble() * widget.height - (widget.height / 2);
    final double length = 30.0 + _random.nextDouble() * 70;
    final double thickness = 1.0 + _random.nextDouble() * 2.0;
    final double angle = _random.nextDouble() * math.pi * 2;
    final bool isPrimary = _random.nextBool();

    final Color baseColor = isPrimary ? widget.primaryColor : widget.secondaryColor;

    final controller = AnimationController(
      duration: Duration(milliseconds: 800 + _random.nextInt(1200)),
      vsync: this,
    )..repeat(reverse: true);

    _controllers.add(controller);

    final opacityAnimation = Tween<double>(begin: 0.2, end: 0.7).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    );

    final lengthAnimation = Tween<double>(begin: length * 0.7, end: length).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: Get.width / 2 + left,
          top: Get.height / 2 + top,
          child: Transform.rotate(
            angle: angle,
            child: Opacity(
              opacity: opacityAnimation.value,
              child: Container(
                width: lengthAnimation.value,
                height: thickness,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      baseColor.withAlpha(0),
                      baseColor.withAlpha(180),
                      baseColor.withAlpha(255),
                      baseColor.withAlpha(180),
                      baseColor.withAlpha(0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withAlpha(150),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMagicCircle() {
    final double left = _random.nextDouble() * Get.width - (Get.width / 2);
    final double top = _random.nextDouble() * widget.height - (widget.height / 2);
    final double size = 20.0 + _random.nextDouble() * 30;
    final bool isPrimary = _random.nextBool();

    final Color baseColor = isPrimary ? widget.primaryColor : widget.secondaryColor;

    final controller = AnimationController(
      duration: Duration(milliseconds: 1500 + _random.nextInt(1500)),
      vsync: this,
    )..repeat(reverse: false);

    _controllers.add(controller);

    final opacityAnimation = Tween<double>(begin: 0.0, end: 0.7).animate(
        CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.3, curve: Curves.easeIn)
        )
    );

    final fadeOutAnimation = Tween<double>(begin: 0.7, end: 0.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut)
        )
    );

    final rotationAnimation = Tween<double>(begin: 0, end: math.pi * 2).animate(controller);

    final scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final currentOpacity = controller.value < 0.7
            ? opacityAnimation.value
            : fadeOutAnimation.value;

        return Positioned(
          left: Get.width / 2 + left,
          top: Get.height / 2 + top,
          child: Transform.rotate(
            angle: rotationAnimation.value,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Opacity(
                opacity: currentOpacity,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: baseColor.withAlpha(200),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withAlpha(100),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: size * 0.6,
                      height: size * 0.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: baseColor.withAlpha(180),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHunterSymbol() {
    final double left = _random.nextDouble() * Get.width - (Get.width / 2);
    final double top = _random.nextDouble() * widget.height - (widget.height / 2);
    final double size = 15.0 + _random.nextDouble() * 25;
    final bool isPrimary = _random.nextBool();

    final Color baseColor = isPrimary ? widget.primaryColor : widget.secondaryColor;
    final symbolType = _random.nextInt(3); // 0: X, 1: 십자, 2: 오각형

    final controller = AnimationController(
      duration: Duration(milliseconds: 1200 + _random.nextInt(1000)),
      vsync: this,
    )..repeat(reverse: true);

    _controllers.add(controller);

    final opacityAnimation = Tween<double>(begin: 0.1, end: 0.8).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    );

    final rotationAnimation = Tween<double>(
        begin: -0.1,
        end: 0.1
    ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: Get.width / 2 + left,
          top: Get.height / 2 + top,
          child: Transform.rotate(
            angle: rotationAnimation.value,
            child: Opacity(
              opacity: opacityAnimation.value,
              child: SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: HunterSymbolPainter(
                    color: baseColor,
                    symbolType: symbolType,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLightningEffect() {
    final double left = _random.nextDouble() * Get.width - (Get.width / 2);
    final double top = _random.nextDouble() * widget.height - (widget.height / 2);
    final double height = 40.0 + _random.nextDouble() * 60;
    final double width = 2.0 + _random.nextDouble() * 4.0;
    final bool isPrimary = _random.nextBool();

    final Color baseColor = isPrimary ? widget.primaryColor : widget.secondaryColor;

    final controller = AnimationController(
      duration: Duration(milliseconds: 500 + _random.nextInt(500)),
      vsync: this,
    );

    // 완전히 랜덤한 타이밍으로 번쩍이도록 설정
    Future.delayed(Duration(milliseconds: _random.nextInt(3000)), () {
      if (mounted && !controller.isAnimating) {
        controller.forward().then((_) {
          controller.reset();
          // 랜덤한 딜레이 후 다시 실행
          Future.delayed(Duration(milliseconds: 500 + _random.nextInt(2500)), () {
            if (mounted && !controller.isAnimating) {
              controller.forward().then((_) {
                controller.reset();
              });
            }
          });
        });
      }
    });

    _controllers.add(controller);

    final opacityAnimation = Tween<double>(begin: 0.0, end: 0.9).animate(
        CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.2, curve: Curves.easeIn)
        )
    );

    final fadeOutAnimation = Tween<double>(begin: 0.9, end: 0.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut)
        )
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final currentOpacity = controller.value < 0.6
            ? opacityAnimation.value
            : fadeOutAnimation.value;

        return Positioned(
          left: Get.width / 2 + left,
          top: Get.height / 2 + top,
          child: Opacity(
            opacity: currentOpacity,
            child: SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: LightningPainter(
                  color: baseColor,
                  segments: 3 + _random.nextInt(3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnergyParticle() {
    final double left = _random.nextDouble() * Get.width - (Get.width / 2);
    final double top = _random.nextDouble() * widget.height - (widget.height / 2);
    final double size = 3.0 + _random.nextDouble() * 8;
    final bool isPrimary = _random.nextBool();

    final Color baseColor = isPrimary ? widget.primaryColor : widget.secondaryColor;

    final controller = AnimationController(
      duration: Duration(milliseconds: 800 + _random.nextInt(1200)),
      vsync: this,
    )..repeat(reverse: true);

    _controllers.add(controller);

    final opacityAnimation = Tween<double>(begin: 0.0, end: 0.9).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    );

    final scaleAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: Get.width / 2 + left,
          top: Get.height / 2 + top,
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: Opacity(
              opacity: opacityAnimation.value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: baseColor,
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withAlpha(150),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: _effects);
  }
}

// 헌터 심볼을 그리는 커스텀 페인터
class HunterSymbolPainter extends CustomPainter {
  final Color color;
  final int symbolType; // 0: X, 1: 십자, 2: 오각형

  HunterSymbolPainter({
    required this.color,
    required this.symbolType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (symbolType) {
      case 0: // X 표시
        canvas.drawLine(
          Offset(0, 0),
          Offset(size.width, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(size.width, 0),
          Offset(0, size.height),
          paint,
        );
        break;
      case 1: // 십자 표시
        canvas.drawLine(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          paint,
        );
        break;
      case 2: // 다각형 (오각형)
        final path = Path();
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.width / 2;
        final sides = 5;

        for (int i = 0; i < sides; i++) {
          final angle = (i * (2 * math.pi / sides)) - math.pi / 2;
          final x = center.dx + radius * math.cos(angle);
          final y = center.dy + radius * math.sin(angle);

          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }

        path.close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(HunterSymbolPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.symbolType != symbolType;
}

// 번개 효과를 그리는 커스텀 페인터
class LightningPainter extends CustomPainter {
  final Color color;
  final int segments;
  final Random _random = Random();

  LightningPainter({
    required this.color,
    required this.segments,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width / 2, 0);

    // 번개 모양 만들기
    final double segmentHeight = size.height / segments;
    for (int i = 1; i <= segments; i++) {
      final double offsetX = (_random.nextDouble() * 2 - 1) * size.width * 2;
      path.lineTo(
        size.width / 2 + offsetX,
        segmentHeight * i,
      );
    }

    final shadowPaint = Paint()
      ..color = color.withAlpha(100)
      ..strokeWidth = size.width * 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, shadowPaint); // 그림자
    canvas.drawPath(path, paint); // 번개
  }

  @override
  bool shouldRepaint(LightningPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.segments != segments;
}