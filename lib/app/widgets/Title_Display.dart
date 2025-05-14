// lib/app/widgets/Title_Display.dart
import 'package:awaken_quest/model/Title_Model.dart';
import 'package:awaken_quest/utils/handler/Title_Handler.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'dart:math' as math;

/// 사용자 칭호를 표시하는 위젯
/// 프로필, 리더보드, 댓글 등 사용자 이름과 함께 칭호를 표시할 때 사용
class TitleDisplay extends StatefulWidget {
  final String? titleId; // 표시할 칭호 ID (null이면 현재 선택된 칭호 사용)
  final double scale; // 크기 조절 (1.0이 기본 크기)
  final bool showAnimation; // 애니메이션 효과 표시 여부
  final bool showBackground; // 배경 표시 여부

  const TitleDisplay({
    super.key,
    this.titleId,
    this.scale = 1.0,
    this.showAnimation = true,
    this.showBackground = true,
  });

  @override
  State<TitleDisplay> createState() => _TitleDisplayState();
}

class _TitleDisplayState extends State<TitleDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  TitleModel? _title;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 펄스 애니메이션
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    // 글로우 애니메이션
    _glowAnimation = Tween<double>(begin: 0.5, end: 0.8).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    // 애니메이션 시작 (필요한 경우)
    if (widget.showAnimation) {
      _animController.repeat(reverse: true);
    }

    // 타이틀 로드
    _loadTitle();
  }

  // 타이틀 로드
  void _loadTitle() {
    if (widget.titleId != null) {
      _title = TitleHandler().getTitleById(widget.titleId!);
    } else {
      _title = TitleHandler().getCurrentTitle();
    }
  }

  @override
  void didUpdateWidget(TitleDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 위젯 업데이트 시 타이틀 다시 로드
    if (oldWidget.titleId != widget.titleId) {
      _loadTitle();
    }

    // 애니메이션 상태 업데이트
    if (widget.showAnimation && !oldWidget.showAnimation) {
      _animController.repeat(reverse: true);
    } else if (!widget.showAnimation && oldWidget.showAnimation) {
      _animController.stop();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 타이틀이 없는 경우
    if (_title == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.showAnimation
              ? _pulseAnimation.value * widget.scale
              : widget.scale,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * widget.scale,
              vertical: 4 * widget.scale,
            ),
            decoration: widget.showBackground ? BoxDecoration(
              color: _title!.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12 * widget.scale),
              border: Border.all(
                color: _title!.color.withValues(alpha: 0.7),
                width: 1.5 * widget.scale,
              ),
              boxShadow: _title!.hasEffect && widget.showAnimation
                  ? [
                BoxShadow(
                  color: _title!.color.withValues(
                    alpha: _glowAnimation.value * 0.3,
                  ),
                  blurRadius: 8 * widget.scale,
                  spreadRadius: 1 * widget.scale,
                ),
              ]
                  : null,
            ) : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 칭호 이름
                Text(
                  _title!.name,
                  style: TextStyle(
                    fontSize: 14 * widget.scale,
                    fontWeight: FontWeight.bold,
                    color: _title!.color,
                    shadows: _title!.hasEffect && widget.showAnimation
                        ? [
                      Shadow(
                        color: _title!.color.withValues(alpha: 0.7),
                        blurRadius: 4 * widget.scale,
                      ),
                    ]
                        : null,
                  ),
                ),

                // 특수 효과 (전설 등급만)
                if (_title!.hasEffect && _title!.rarity >= 3)
                  SizedBox(width: 4 * widget.scale),

                if (_title!.hasEffect && _title!.rarity >= 3)
                  _buildSpecialEffectIcon(),
              ],
            ),
          ),
        );
      },
    );
  }

  // 특수 효과 아이콘
  Widget _buildSpecialEffectIcon() {
    return SizedBox(
      width: 16 * widget.scale,
      height: 16 * widget.scale,
      child: CustomPaint(
        painter: TitleEffectIconPainter(
          color: _title!.color,
          animValue: _animController.value,
        ),
      ),
    );
  }
}

// 칭호 효과 아이콘 페인터
class TitleEffectIconPainter extends CustomPainter {
  final Color color;
  final double animValue;

  TitleEffectIconPainter({
    required this.color,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 별 그리기
    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final starPath = Path();
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    const pointCount = 5;

    for (int i = 0; i < pointCount * 2; i++) {
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final angle = (i * math.pi) / pointCount;
      final x = center.dx + radius * math.cos(angle - math.pi / 2);
      final y = center.dy + radius * math.sin(angle - math.pi / 2);

      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }

    starPath.close();
    canvas.drawPath(starPath, starPaint);

    // 빛나는 효과
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3 + 0.4 * math.sin(animValue * math.pi * 2))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final glowPath = Path();
    final glowOuterRadius = outerRadius * (0.9 + 0.2 * math.sin(animValue * math.pi * 2));
    final glowInnerRadius = innerRadius * (0.9 + 0.2 * math.sin(animValue * math.pi * 2 + math.pi));

    for (int i = 0; i < pointCount * 2; i++) {
      final radius = i % 2 == 0 ? glowOuterRadius : glowInnerRadius;
      final angle = (i * math.pi) / pointCount;
      final x = center.dx + radius * math.cos(angle - math.pi / 2);
      final y = center.dy + radius * math.sin(angle - math.pi / 2);

      if (i == 0) {
        glowPath.moveTo(x, y);
      } else {
        glowPath.lineTo(x, y);
      }
    }

    glowPath.close();
    canvas.drawPath(glowPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant TitleEffectIconPainter oldDelegate) {
    return oldDelegate.animValue != animValue || oldDelegate.color != color;
  }
}

/// 사용자 이름 위에 칭호를 표시하는 위젯
class UserNameWithTitle extends StatelessWidget {
  final String name;
  final String? titleId;
  final double fontSize;
  final bool showTitleAnimation;

  const UserNameWithTitle({
    super.key,
    required this.name,
    this.titleId,
    this.fontSize = 16.0,
    this.showTitleAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 칭호 표시
        TitleDisplay(
          titleId: titleId,
          scale: fontSize / 16.0 * 0.85, // 이름보다 약간 작게
          showAnimation: showTitleAnimation,
          showBackground: true,
        ),

        const SizedBox(height: 4),

        // 사용자 이름
        Text(
          name,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}