import 'dart:ui';
import 'dart:math' as math;
import '../animation/Simmer_Text.dart';
import '../manager/Import_Manager.dart';

class ErrorDialog extends StatefulWidget {
  const ErrorDialog({super.key, required this.error});
  final String error;

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );

    _rotateAnimation = Tween<double>(begin: -0.01, end: 0.01).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // 랜덤 글리치 효과를 위한 오프셋
            final random = math.Random();
            final shouldGlitch = random.nextDouble() < 0.05;
            final glitchOffsetX = shouldGlitch ? (random.nextDouble() * 4 - 2) : 0.0;
            final glitchOffsetY = shouldGlitch ? (random.nextDouble() * 4 - 2) : 0.0;

            return Transform.translate(
              offset: Offset(glitchOffsetX, glitchOffsetY),
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Stack(
                    children: [
                      // 메인 컨테이너
                      Container(
                        width: 320,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFB71C1C).withValues(alpha: 0.7),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.3 + 0.2 * math.sin(_controller.value * math.pi)),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: child,
                      ),

                      // 글리치 효과 (간헐적으로 나타남)
                      if (shouldGlitch)
                        Positioned(
                          left: random.nextDouble() * 10 - 5,
                          right: random.nextDouble() * 10 - 5,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 경고 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    BootstrapIcons.exclamation_triangle_fill,
                    color: Colors.redAccent.withValues(alpha: 0.9),
                    size: 30,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 에러 타이틀
              ShimmerText(
                text: '시스템 에러',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),

              const SizedBox(height: 16),

              // 에러 메시지
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.error,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // 확인 버튼
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
