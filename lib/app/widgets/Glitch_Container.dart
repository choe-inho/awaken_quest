import 'package:flutter/material.dart';

class GlitchedContainer extends StatelessWidget {
  final Widget child;

  const GlitchedContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AwakeningFramePainter(),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlueAccent.withValues(alpha: 0.2),
              Colors.cyanAccent.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _AwakeningFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outerPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final innerPaint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    // 외곽선 두 줄 그리기
    canvas.drawRRect(rRect, outerPaint);

    final insetRect = rect.deflate(4);
    final insetRRect = RRect.fromRectAndRadius(insetRect, const Radius.circular(6));
    canvas.drawRRect(insetRRect, innerPaint);

    // 디지털 장식 - 구석 포인트 (optional)
    final cornerPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final square = 6.0;

    // 좌상단
    canvas.drawRect(Rect.fromLTWH(0, 0, square, square), cornerPaint);
    canvas.drawRect(Rect.fromLTWH(12, 0, square, square), cornerPaint);

    // 우하단
    canvas.drawRect(Rect.fromLTWH(size.width - square, size.height - square, square, square), cornerPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - square - 12, size.height - square, square, square), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
