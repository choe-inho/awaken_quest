// 빛나는 테두리 페인터
import '../../utils/manager/Import_Manager.dart';

class GlowingBorderPainter extends CustomPainter {
  final double progress;
  final Color color;

  GlowingBorderPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(14),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withValues(alpha: 0.7 * progress)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.outer,
        5 * progress,
      );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GlowingBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}