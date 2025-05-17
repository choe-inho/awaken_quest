import 'dart:ui';
import '../manager/Import_Manager.dart';

class AwakeningSuccessDialog extends StatefulWidget {
  const AwakeningSuccessDialog({
    super.key,
    required this.nickname,
    this.onComplete,
  });

  final String nickname;
  final VoidCallback? onComplete;

  @override
  State<AwakeningSuccessDialog> createState() => _AwakeningSuccessDialogState();
}

class _AwakeningSuccessDialogState extends State<AwakeningSuccessDialog> {
  late int _countdown = 3;

  @override
  void initState() {
    super.initState();
    // 카운트다운 타이머
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: PopScope(
        canPop: false,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              border: Border.all(
                color: Colors.cyanAccent.withValues(alpha: 0.6),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타이틀
                Text(
                  '각성에 성공하였습니다',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.8),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // 본문 텍스트
                Text(
                  '${widget.nickname} 님에게 적합한 루트를 탐색합니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // 카운트다운 타이머
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.5),
                    border: Border.all(
                      color: Colors.cyanAccent.withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  '잠시만 기다려주세요...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}