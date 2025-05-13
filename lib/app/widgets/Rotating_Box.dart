
import '../../utils/manager/Import_Manager.dart';

class RotatingBox extends StatefulWidget {
  const RotatingBox({super.key, required this.duration, required this.imagePath, required this.size});
  final Duration duration;
  final String imagePath;
  final double size;
  @override
  State<RotatingBox> createState() => _RotatingBoxState();
}

class _RotatingBoxState extends State<RotatingBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(); // 계속 회전
  }

  @override
  void dispose() {
    _controller.dispose(); // 자원 정리
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * pi,
            child: child,
          );
        },
        child: Image.asset(widget.imagePath),
      ),
    );
  }
}
