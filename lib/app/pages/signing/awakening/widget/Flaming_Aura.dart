import 'dart:math';
import 'package:flutter/material.dart';

class FlamingAura extends StatefulWidget {
  final Widget child;
  final Color color;
  const FlamingAura({required this.child, super.key, required this.color});

  @override
  State<FlamingAura> createState() => _FlamingAuraState();
}

class _FlamingAuraState extends State<FlamingAura> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(); // 무한 반복
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
        return ShaderMask(
          shaderCallback: (bounds) {
            final double progress = _controller.value;
            final double radius = bounds.width * 0.6 + sin(progress * 2 * pi) * 20;
            return RadialGradient(
              center: Alignment.center,
              radius: 0.5,
              colors: [
                widget.color.withValues(alpha: 0.3),
                widget.color.withValues(alpha: 0.6),
                Colors.transparent,
              ],
              stops: [0.1, 0.4, 1],
              tileMode: TileMode.mirror,
            ).createShader(Rect.fromCircle(center: bounds.center, radius: radius));
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
