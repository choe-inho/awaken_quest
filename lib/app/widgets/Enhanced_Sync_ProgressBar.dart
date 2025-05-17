// 개선된 프로그레스 바 위젯
import '../../utils/manager/Import_Manager.dart';

class EnhancedSyncProgressBar extends StatelessWidget {
  final double progress;

  const EnhancedSyncProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          // 발광 효과가 있는 프로그레스
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3A7FFF), Color(0xFF64B5F6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3A7FFF).withValues(alpha: 0.7),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Opacity(
                      opacity: 0.7,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white,
                              Colors.white.withValues(alpha: 0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 추가 반짝임 효과
          if (progress > 0.1)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.15 * progress - 5,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  width: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white,
                        Colors.white.withValues(alpha: 0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}