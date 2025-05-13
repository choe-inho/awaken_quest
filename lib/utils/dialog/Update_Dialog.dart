import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';

import '../manager/Import_Manager.dart';
import 'package:awaken_quest/app/pages/home/widget/Neon_Divider.dart';
import 'package:awaken_quest/utils/dialog/Basic_Dialog.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _scanAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 메인 컨테이너
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.cyanAccent.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: _glowAnimation.value),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 상단 아이콘
                  FadeIn(
                    child: _buildWarningIcon(),
                  ),

                  const SizedBox(height: 12),

                  // 제목
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: const [
                          Color(0xFF00FFFF),
                          Colors.white,
                          Color(0xFF00FFFF),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        transform: GradientRotation(_controller.value * math.pi),
                      ).createShader(bounds);
                    },
                    child: Text(
                      '상태창 손상 감지',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.9),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 커스텀 네온 디바이더
                  Flash(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 1500),
                    child: _buildEnhancedDivider(),
                  ),

                  const SizedBox(height: 20),

                  // 메시지 텍스트
                  FadeInUp(
                    from: 20,
                    delay: const Duration(milliseconds: 300),
                    child: Stack(
                      children: [
                        // 텍스트
                        Text(
                          '지속적인 임무 수행이 불가능합니다.\n시스템을 최신 상태로 패치해야 합니다.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            height: 1.4,
                            shadows: [
                              Shadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.7),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // 스캔 효과
                        AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (context, _) {
                            return Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
                                      colors: [
                                        Colors.transparent,
                                        Colors.transparent,
                                        Colors.cyanAccent.withValues(alpha: 0.3),
                                        Colors.transparent,
                                        Colors.transparent,
                                      ],
                                      transform: GradientRotation(0.5 * math.pi),
                                    ),
                                    backgroundBlendMode: BlendMode.screen,
                                  ),
                                  transform: Matrix4.translationValues(
                                    0,
                                    _scanAnimation.value * 120,
                                    0,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 버튼 행
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 업데이트 버튼
                      _buildUpdateButton(),

                      // 앱 종료 버튼
                      _buildExitButton(),
                    ],
                  ),
                ],
              ),
            ),

            // 디지털 회로 효과
            Positioned.fill(
              child: IgnorePointer(
                child: _buildCircuitEffect(),
              ),
            ),

            // 경고 오버레이 효과
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: WarningOverlayPainter(
                        opacity: 0.05 + 0.05 * math.sin(_controller.value * math.pi * 2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.5),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.warning_amber_rounded,
          color: Colors.red.withValues(alpha: 0.9),
          size: 36,
        ),
      ),
    );
  }

  Widget _buildEnhancedDivider() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.cyanAccent.withValues(alpha: 0.8),
            Colors.white.withValues(alpha: 0.9),
            Colors.cyanAccent.withValues(alpha: 0.8),
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.8),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 500),
      from: 30,
      child: HunterButtonEnhanced(
        text: '업데이트',
        icon: Icons.system_update,
        onTap: () {
          // 스토어 이동
        },
      ),
    );
  }

  Widget _buildExitButton() {
    return FadeInRight(
      delay: const Duration(milliseconds: 500),
      from: 30,
      child: HunterButtonEnhanced(
        text: '앱 종료',
        icon: Icons.power_settings_new,
        color: Colors.red,
        onTap: () {
          Get.back();
          if (Platform.isAndroid) {
            SystemNavigator.pop(); // 앱 종료
          } else {
            exit(0);
          }
        },
      ),
    );
  }

  Widget _buildCircuitEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: CircuitPainter(
            animationValue: _controller.value,
            glowIntensity: _glowAnimation.value,
          ),
        );
      },
    );
  }
}

// 향상된 헌터 버튼
class HunterButtonEnhanced extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HunterButtonEnhanced({
    super.key,
    required this.text,
    required this.onTap,
    this.icon = Icons.arrow_forward,
    this.color = const Color(0xFF00CFFF),
  });

  @override
  State<HunterButtonEnhanced> createState() => _HunterButtonEnhancedState();
}

class _HunterButtonEnhancedState extends State<HunterButtonEnhanced>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.reverse(from: 1.2).then((_) {
          _controller.forward().then((_) {
            widget.onTap();
          });
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.7),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: _glowAnimation.value),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.color.withValues(alpha: 0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: widget.color.withValues(alpha: 0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 회로 페인터
class CircuitPainter extends CustomPainter {
  final double animationValue;
  final double glowIntensity;

  CircuitPainter({
    required this.animationValue,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // 회로 패턴이 일관되게 유지되도록 고정된 시드
    final lineCount = 8;

    for (int i = 0; i < lineCount; i++) {
      final isHorizontal = random.nextBool();
      final length = 30.0 + random.nextDouble() * 100.0;
      final thickness = 1.0 + random.nextDouble();

      // 회로가 켜지고 꺼지는 효과
      final circuitPhase = (animationValue * 5 + i / lineCount) % 1.0;
      final isOn = circuitPhase > 0.5;

      if (!isOn) continue;

      final paint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.4 * glowIntensity)
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (isHorizontal) {
        final y = size.height * (0.1 + 0.8 * i / lineCount);
        canvas.drawLine(
          Offset(size.width * 0.1, y),
          Offset(size.width * 0.1 + length, y),
          paint,
        );

        // 회로 정션 노드
        if (random.nextBool()) {
          canvas.drawCircle(
            Offset(size.width * 0.1, y),
            2.0,
            Paint()
              ..color = Colors.cyanAccent.withValues(alpha: 0.6 * glowIntensity)
              ..style = PaintingStyle.fill,
          );
        }
      } else {
        final x = size.width * (0.2 + 0.6 * i / lineCount);
        canvas.drawLine(
          Offset(x, size.height * 0.1),
          Offset(x, size.height * 0.1 + length),
          paint,
        );

        // 회로 정션 노드
        if (random.nextBool()) {
          canvas.drawCircle(
            Offset(x, size.height * 0.1 + length),
            2.0,
            Paint()
              ..color = Colors.cyanAccent.withValues(alpha: 0.6 * glowIntensity)
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) => true;
}

// 경고 오버레이 페인터
class WarningOverlayPainter extends CustomPainter {
  final double opacity;

  WarningOverlayPainter({
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 경고 패턴 (대각선 줄무늬)
    const stripeWidth = 20.0;
    const stripeSpacing = 40.0;

    final paint = Paint()
      ..color = Colors.red.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stripeWidth;

    for (double i = -size.width; i < size.width + size.height; i += stripeSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WarningOverlayPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

// 다이얼로그 표시 유틸리티 함수
Future<void> showUpdateRequiredDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (BuildContext context) {
      return const UpdateDialog();
    },
  );
}