// 빛 오버레이 효과
import '../../utils/manager/Import_Manager.dart';

class LightOverlayEffect extends StatefulWidget {
  final Color color;

  const LightOverlayEffect({
    super.key,
    required this.color,
  });

  @override
  State<LightOverlayEffect> createState() => _LightOverlayEffectState();
}

class _LightOverlayEffectState extends State<LightOverlayEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.2),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 0.0),
        weight: 35,
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
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, 0.2),
                radius: 0.8,
                colors: [
                  widget.color,
                  widget.color.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

