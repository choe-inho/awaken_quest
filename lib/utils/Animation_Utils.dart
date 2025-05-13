// 애니메이션 사용을 위한 유틸리티 클래스
import 'package:flutter/scheduler.dart';

import 'App_Theme.dart';
import 'manager/Import_Manager.dart';

class AnimationUtils {
  // 페이드 인 애니메이션
  static Widget fadeIn(Widget child, {Duration duration = const Duration(milliseconds: 300)}) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: AnimationController(
          vsync: _dummyTickerProvider,
          duration: duration,
        )..forward(),
        curve: Curves.easeIn,
      ),
      child: child,
    );
  }

  // 슬라이드 애니메이션
  static Widget slideIn(
      Widget child, {
        Duration duration = const Duration(milliseconds: 400),
        Offset beginOffset = const Offset(0, 0.1),
      }) {
    final controller = AnimationController(
      vsync: _dummyTickerProvider,
      duration: duration,
    )..forward();

    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutQuint,
      )),
      child: child,
    );
  }

  // 펄스 애니메이션
  static Widget pulse(
      Widget child, {
        Duration duration = const Duration(milliseconds: 1500),
        double minScale = 0.97,
        double maxScale = 1.03,
      }) {
    final controller = AnimationController(
      vsync: _dummyTickerProvider,
      duration: duration,
    )..repeat(reverse: true);

    return ScaleTransition(
      scale: Tween<double>(
        begin: minScale,
        end: maxScale,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  // 더미 TickerProvider (실제 구현에서는 State<StatefulWidget>을 사용)
  static final _dummyTickerProvider = _DummyTickerProvider();
}

// 더미 TickerProvider 클래스 (예시용)
class _DummyTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

// 특별한 효과를 위한 커스텀 위젯
class GlowingContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GlowingContainer({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF3A7FFF),
    this.intensity = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color:  Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppTheme.glowingShadow(glowColor, intensity: intensity),
      ),
      child: child,
    );
  }
}

// 헌터 웹툰 스타일의 버튼
class HunterButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool glow;
  final double glowIntensity;

  const HunterButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.glow = true,
    this.glowIntensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: AppTheme.hunterButtonStyle(
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
      child: Text(text),
    );

    if (!glow) return button;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.glowingShadow(
          backgroundColor ?? const Color(0xFF3A7FFF),
          intensity: glowIntensity,
        ),
      ),
      child: button,
    );
  }
}

// 그라데이션 텍스트
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  const GradientText(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.gradient = const LinearGradient(
          colors: [Color(0xFF3A7FFF), Color(0xFF9B4DFF)],
        ),
      });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}