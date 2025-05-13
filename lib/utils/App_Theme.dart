import 'package:flutter/material.dart';

class AppTheme {
  // 헌터 웹툰 스타일을 위한 화려한 색상 팔레트
  static const Color _primaryBlue = Color(0xFF3A7FFF);      // 푸른 오라 메인 색상
  static const Color _accentPurple = Color(0xFF9B4DFF);     // 보라색 강조
  static const Color _energyRed = Color(0xFFFF4D4D);        // 에너지 느낌의 빨간색
  static const Color _magicYellow = Color(0xFFFFD700);      // 마법 느낌의 노란색
  static const Color _darkBackground = Color(0xFF121212);   // 어두운 배경
  static const Color _darkSurface = Color(0xFF1E1E1E);      // 어두운 표면
  static const Color glowingBlue = Color(0xFF64B5F6);      // 빛나는 파란색 효과

  // 그라데이션 배경을 위한 색상들
  static const List<Color> _primaryGradient = [
    _primaryBlue,
    _accentPurple,
  ];

  static const List<Color> _energyGradient = [
    _energyRed,
    _magicYellow,
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      primaryColor: _primaryBlue,

      // 최신 Flutter 버전에서는 colorScheme을 더 폭넓게 활용
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryBlue,
        brightness: Brightness.dark,
        primary: _primaryBlue,
        secondary: _accentPurple,
        tertiary: _magicYellow,
        error: _energyRed,
        surface: _darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.black,
        onError: Colors.white,
        onSurface: Colors.white,
      ),

      // 폰트 설정
      fontFamily: 'pretendard',

      // 텍스트 테마
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.1,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),

      // 버튼 테마 - Material 3 스타일 적용
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return _primaryBlue.withValues(alpha: 0.3);
            }
            return _primaryBlue;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.2);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.1);
            }
            return Colors.transparent;
          }),
          shadowColor: WidgetStateProperty.all(_primaryBlue.withValues(alpha: 0.5)),
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.pressed)) {
              return 2;
            }
            return 4;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          // 화려한 효과를 위한 애니메이션 지속 시간
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),

      // 텍스트 버튼 테마
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(_primaryBlue),
          overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return _primaryBlue.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return _primaryBlue.withValues(alpha: 0.05);
            }
            return Colors.transparent;
          }),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),

      // 아웃라인 버튼 테마
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(_primaryBlue),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return _primaryBlue.withValues(alpha: 0.1);
            }
            return Colors.transparent;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: _primaryBlue, width: 1.5),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),

      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryBlue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _energyRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _energyRed, width: 2),
        ),
        errorStyle: TextStyle(color: _energyRed),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return _primaryBlue;
          }
          return Colors.white.withValues(alpha: 0.7);
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return _primaryBlue;
          }
          return Colors.white.withValues(alpha: 0.7);
        }),
      ),

      // 카드 테마
      cardTheme: CardTheme(
        elevation: 4,
        color: _darkSurface,
        shadowColor: _primaryBlue.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // 앱바 테마
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: _primaryBlue),
      ),

      // 아이콘 테마
      iconTheme: IconThemeData(
        color: _primaryBlue,
        size: 24,
      ),

      // 스낵바 테마
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkSurface,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // 스위치 테마
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryBlue;
          }
          return Colors.white70;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryBlue.withValues(alpha: 0.5);
          }
          return Colors.white30;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // 체크박스 테마
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryBlue;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // 슬라이더 테마
      sliderTheme: SliderThemeData(
        activeTrackColor: _primaryBlue,
        inactiveTrackColor: _primaryBlue.withValues(alpha: 0.3),
        thumbColor: _primaryBlue,
        overlayColor: _primaryBlue.withValues(alpha: 0.2),
        valueIndicatorColor: _darkSurface,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),

      // 프로그레스 인디케이터 테마
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primaryBlue,
        linearTrackColor: _primaryBlue.withValues(alpha: 0.2),
        circularTrackColor: _primaryBlue.withValues(alpha: 0.2),
      ),

      // 탭바 테마
      tabBarTheme: TabBarTheme(
        labelColor: _primaryBlue,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
        indicatorColor: _primaryBlue,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),

      // 다이얼로그 테마
      dialogTheme: DialogTheme(
        backgroundColor: _darkSurface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 디바이더 테마
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),

      // 화면 전환 애니메이션 지속 시간
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // 화려한 그라데이션 배경을 생성하는 헬퍼 메서드
  static BoxDecoration heroGradientBackground({bool reversed = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: reversed ? Alignment.topRight : Alignment.topLeft,
        end: reversed ? Alignment.bottomLeft : Alignment.bottomRight,
        colors: _primaryGradient,
      ),
    );
  }

  // 에너지 느낌의 그라데이션 배경을 생성하는 헬퍼 메서드
  static BoxDecoration energyGradientBackground({bool reversed = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: reversed ? Alignment.topRight : Alignment.topLeft,
        end: reversed ? Alignment.bottomLeft : Alignment.bottomRight,
        colors: _energyGradient,
      ),
    );
  }

  // 특별한 효과를 위한 쉐도우 헬퍼 메서드
  static List<BoxShadow> glowingShadow(Color color, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.6 * intensity),
        blurRadius: 8.0 * intensity,
        spreadRadius: 1.0 * intensity,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.3 * intensity),
        blurRadius: 16.0 * intensity,
        spreadRadius: 2.0 * intensity,
      ),
    ];
  }

  // 헌터 웹툰 스타일의 버튼을 생성하는 헬퍼 메서드
  static ButtonStyle hunterButtonStyle({Color? backgroundColor, Color? textColor}) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return (backgroundColor ?? _primaryBlue).withValues(alpha: 0.3);
        }
        return backgroundColor ?? _primaryBlue;
      }),
      foregroundColor: WidgetStateProperty.all(textColor ?? Colors.white),
      overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.white.withValues(alpha: 0.2);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withValues(alpha: 0.1);
        }
        return Colors.transparent;
      }),
      shadowColor: WidgetStateProperty.all(
          (backgroundColor ?? _primaryBlue).withValues(alpha: 0.5)
      ),
      elevation: WidgetStateProperty.resolveWith<double>((states) {
        if (states.contains(WidgetState.pressed)) {
          return 2;
        }
        return 4;
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      animationDuration: const Duration(milliseconds: 200),
    );
  }
}