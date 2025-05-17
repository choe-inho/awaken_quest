
// 플립 애니메이션 (뒤집기 효과)
import 'dart:math' as math;

import '../manager/Import_Manager.dart';

class FlipAnimation extends StatefulWidget {
  final Widget child;
  final Axis axis;
  final Duration duration;
  final Curve curve;

  const FlipAnimation({
    super.key,
    required this.child,
    this.axis = Axis.horizontal,
    this.duration = const Duration(seconds: 10),
    this.curve = Curves.linear,
  });

  @override
  State<FlipAnimation> createState() => _FlipAnimationState();
}

class _FlipAnimationState extends State<FlipAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
        final value = widget.curve.transform(_controller.value);
        return Transform(
          alignment: Alignment.center,
          transform: widget.axis == Axis.horizontal
              ? Matrix4.rotationY(value * 2 * math.pi)
              : Matrix4.rotationX(value * 2 * math.pi),
          child: widget.child,
        );
      },
    );
  }
}
