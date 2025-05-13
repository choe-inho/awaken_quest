import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 대각선 패턴을 그리는 커스텀 페인터
/// 웹툰 스타일의 배경 효과를 위해 사용
class DiagonalPatternPainter extends CustomPainter {
  final Color lineColor;
  final double lineWidth;
  final double gapSize;

  DiagonalPatternPainter({
    required this.lineColor,
    required this.lineWidth,
    required this.gapSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    // 대각선 그리기 (좌상단에서 우하단 방향)
    double offset = 0;
    while (offset < size.width + size.height) {
      final path = Path();
      path.moveTo(math.max(0, offset - size.height), math.min(offset, size.height));
      path.lineTo(math.min(offset, size.width), math.max(0, offset - size.width));
      canvas.drawPath(path, paint);
      offset += gapSize;
    }
  }

  @override
  bool shouldRepaint(DiagonalPatternPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
          oldDelegate.lineWidth != lineWidth ||
          oldDelegate.gapSize != gapSize;
}