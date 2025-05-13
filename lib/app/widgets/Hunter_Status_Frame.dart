import 'package:flutter/material.dart';
import 'dart:math' as math;

// Offset 확장 메서드 - normalize 함수 직접 구현
extension OffsetExtension on Offset {
  Offset normalizeVector() {
    // 벡터의 길이 계산
    final double length = math.sqrt(dx * dx + dy * dy);

    // 길이가 0이면 원래 벡터 반환 (0으로 나눌 수 없음)
    if (length == 0) return this;

    // 벡터의 각 성분을 길이로 나누어 정규화
    return Offset(dx / length, dy / length);
  }
}

class HunterStatusFrame extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final double borderWidth;
  final double cornerSize;
  final double glowIntensity;
  final bool showInnerBorder;
  final int polygonSides;
  final bool showStatusLines;
  final String? title;

  const HunterStatusFrame({
    super.key,
    required this.child,
    this.width = 300,
    this.height = 200,
    this.primaryColor = const Color(0xFF5D00FF),
    this.secondaryColor = const Color(0xFFFF5500),
    this.borderWidth = 2.5,
    this.cornerSize = 15.0,
    this.glowIntensity = 1.0,
    this.showInnerBorder = true,
    this.polygonSides = 6,  // 기본 육각형
    this.showStatusLines = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 글로우 효과
        CustomPaint(
          size: Size(width, height),
          painter: HunterStatusFramePainter(
            primaryColor: primaryColor.withAlpha((glowIntensity * 100).toInt()),
            secondaryColor: secondaryColor.withAlpha((glowIntensity * 100).toInt()),
            borderWidth: borderWidth + 6,
            cornerSize: cornerSize + 2,
            showInnerBorder: false,
            polygonSides: polygonSides,
            showStatusLines: false,
          ),
        ),

        // 메인 프레임
        CustomPaint(
          size: Size(width, height),
          painter: HunterStatusFramePainter(
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            borderWidth: borderWidth,
            cornerSize: cornerSize,
            showInnerBorder: showInnerBorder,
            polygonSides: polygonSides,
            showStatusLines: showStatusLines,
          ),
        ),

        // 내부 콘텐츠
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(borderWidth * 2 + cornerSize),
            child: child,
          ),
        ),

        // 제목이 있으면 표시
        if (title != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  border: Border.all(
                    color: primaryColor,
                    width: borderWidth - 0.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  title!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: primaryColor,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class HunterStatusFramePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double borderWidth;
  final double cornerSize;
  final bool showInnerBorder;
  final int polygonSides;
  final bool showStatusLines;

  HunterStatusFramePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.borderWidth,
    required this.cornerSize,
    required this.showInnerBorder,
    required this.polygonSides,
    required this.showStatusLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 기본 페인트 설정
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.bevel;

    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 0.8
      ..strokeCap = StrokeCap.butt;

    // 메인 프레임 그리기 (다각형)
    if (polygonSides >= 3) {
      _drawPolygonWithCorners(canvas, size, paint);
    } else {
      _drawRectangleWithCorners(canvas, size, paint);
    }

    // 내부 테두리 그리기 (선택 사항)
    if (showInnerBorder) {
      final innerPadding = cornerSize + borderWidth;
      final innerRect = Rect.fromLTWH(
          innerPadding,
          innerPadding,
          size.width - innerPadding * 2,
          size.height - innerPadding * 2
      );

      // 내부 테두리에 대시 패턴 추가
      final dashPaint = Paint()
        ..color = primaryColor.withAlpha(150)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * 0.7;

      _drawDashedRect(canvas, innerRect, dashPaint, 5, 3);
    }

    // 상태 선 그리기 (선택 사항)
    if (showStatusLines) {
      _drawStatusLines(canvas, size, secondaryPaint);
    }
  }

  void _drawPolygonWithCorners(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - borderWidth;

    // 다각형 기본 경로 생성
    final points = <Offset>[];
    for (int i = 0; i < polygonSides; i++) {
      final angle = (i * (2 * math.pi / polygonSides)) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      points.add(Offset(x, y));
    }

    // 다각형 그리기 (모서리 효과 포함)
    for (int i = 0; i < points.length; i++) {
      final currentPoint = points[i];
      final nextPoint = points[(i + 1) % points.length];

      // 각 모서리에 추가적인 꺾임 효과
      // normalize를 직접 구현
      final directionVector = nextPoint - currentPoint;
      final direction = directionVector.normalizeVector();
      final perpendicular = Offset(-direction.dy, direction.dx);

      final cornerPoint1 = currentPoint + Offset(direction.dx * cornerSize, direction.dy * cornerSize);
      final cornerPoint2 = nextPoint - Offset(direction.dx * cornerSize, direction.dy * cornerSize);

      final cornerOffset = Offset(perpendicular.dx * (cornerSize * 0.5), perpendicular.dy * (cornerSize * 0.5));
      final cornerMidPoint1 = Offset(cornerPoint1.dx + cornerOffset.dx, cornerPoint1.dy + cornerOffset.dy);
      final cornerMidPoint2 = Offset(cornerPoint2.dx + cornerOffset.dx, cornerPoint2.dy + cornerOffset.dy);

      if (i == 0) {
        path.moveTo(currentPoint.dx, currentPoint.dy);
      }

      path.lineTo(cornerPoint1.dx, cornerPoint1.dy);
      path.lineTo(cornerMidPoint1.dx, cornerMidPoint1.dy);
      path.lineTo(cornerMidPoint2.dx, cornerMidPoint2.dy);
      path.lineTo(cornerPoint2.dx, cornerPoint2.dy);
      path.lineTo(nextPoint.dx, nextPoint.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawRectangleWithCorners(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final rect = Rect.fromLTWH(
        borderWidth / 2,
        borderWidth / 2,
        size.width - borderWidth,
        size.height - borderWidth
    );

    // 왼쪽 상단 모서리
    path.moveTo(rect.left, rect.top + cornerSize);
    path.lineTo(rect.left, rect.top);
    path.lineTo(rect.left + cornerSize, rect.top);

    // 모서리 효과
    path.lineTo(rect.left + cornerSize * 1.5, rect.top - cornerSize * 0.5);
    path.lineTo(rect.right - cornerSize * 1.5, rect.top - cornerSize * 0.5);

    // 오른쪽 상단 모서리
    path.lineTo(rect.right - cornerSize, rect.top);
    path.lineTo(rect.right, rect.top);
    path.lineTo(rect.right, rect.top + cornerSize);

    // 모서리 효과
    path.lineTo(rect.right + cornerSize * 0.5, rect.top + cornerSize * 1.5);
    path.lineTo(rect.right + cornerSize * 0.5, rect.bottom - cornerSize * 1.5);

    // 오른쪽 하단 모서리
    path.lineTo(rect.right, rect.bottom - cornerSize);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.right - cornerSize, rect.bottom);

    // 모서리 효과
    path.lineTo(rect.right - cornerSize * 1.5, rect.bottom + cornerSize * 0.5);
    path.lineTo(rect.left + cornerSize * 1.5, rect.bottom + cornerSize * 0.5);

    // 왼쪽 하단 모서리
    path.lineTo(rect.left + cornerSize, rect.bottom);
    path.lineTo(rect.left, rect.bottom);
    path.lineTo(rect.left, rect.bottom - cornerSize);

    // 모서리 효과
    path.lineTo(rect.left - cornerSize * 0.5, rect.bottom - cornerSize * 1.5);
    path.lineTo(rect.left - cornerSize * 0.5, rect.top + cornerSize * 1.5);

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint, double dashLength, double dashGap) {
    // 대시 패턴으로 사각형 그리기
    double currentLength = 0;
    final dashPath = Path();

    // 상단 선
    while (currentLength < rect.width) {
      dashPath.moveTo(rect.left + currentLength, rect.top);
      dashPath.lineTo(rect.left + currentLength + dashLength, rect.top);
      currentLength += dashLength + dashGap;
    }

    // 오른쪽 선
    currentLength = 0;
    while (currentLength < rect.height) {
      dashPath.moveTo(rect.right, rect.top + currentLength);
      dashPath.lineTo(rect.right, rect.top + currentLength + dashLength);
      currentLength += dashLength + dashGap;
    }

    // 하단 선
    currentLength = 0;
    while (currentLength < rect.width) {
      dashPath.moveTo(rect.right - currentLength, rect.bottom);
      dashPath.lineTo(rect.right - currentLength - dashLength, rect.bottom);
      currentLength += dashLength + dashGap;
    }

    // 왼쪽 선
    currentLength = 0;
    while (currentLength < rect.height) {
      dashPath.moveTo(rect.left, rect.bottom - currentLength);
      dashPath.lineTo(rect.left, rect.bottom - currentLength - dashLength);
      currentLength += dashLength + dashGap;
    }

    canvas.drawPath(dashPath, paint);
  }

  void _drawStatusLines(Canvas canvas, Size size, Paint paint) {
    final padding = cornerSize * 2 + borderWidth * 3;
    final contentArea = Rect.fromLTWH(
        padding,
        padding,
        size.width - padding * 2,
        size.height - padding * 2
    );

    // 횡단 선 그리기 (상태창의 특성)
    final linePaint = Paint()
      ..color = secondaryColor.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 0.5;

    // 수평선 그리기
    for (int i = 1; i < 4; i++) {
      final y = contentArea.top + (contentArea.height / 4) * i;
      canvas.drawLine(
        Offset(contentArea.left, y),
        Offset(contentArea.right, y),
        linePaint,
      );
    }

    // 수직선 그리기 (옵션)
    canvas.drawLine(
      Offset(contentArea.left + contentArea.width * 0.3, contentArea.top),
      Offset(contentArea.left + contentArea.width * 0.3, contentArea.bottom),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(HunterStatusFramePainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
          oldDelegate.secondaryColor != secondaryColor ||
          oldDelegate.borderWidth != borderWidth ||
          oldDelegate.cornerSize != cornerSize ||
          oldDelegate.showInnerBorder != showInnerBorder ||
          oldDelegate.polygonSides != polygonSides ||
          oldDelegate.showStatusLines != showStatusLines;
}

// 사용 예제는 이전과 동일하게 구현할 수 있습니다.