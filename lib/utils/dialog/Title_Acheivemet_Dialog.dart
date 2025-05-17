import '../../model/Title_Model.dart';
import '../manager/Import_Manager.dart';

class TitleAchievementDialog extends StatefulWidget {
  final TitleModel title;

  const TitleAchievementDialog({
    super.key,
    required this.title,
  });

  @override
  State<TitleAchievementDialog> createState() => _TitleAchievementDialogState();
}

class _TitleAchievementDialogState extends State<TitleAchievementDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut)
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn)
    );

    _controller.forward();

    // 10초 후 자동 닫힘
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.title.color.withValues(alpha: 0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.title.color.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 타이틀 아이콘
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.title.color.withValues(alpha: 0.2),
                      border: Border.all(
                        color: widget.title.color.withValues(alpha: 0.7),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getTitleIcon(),
                        color: widget.title.color,
                        size: 35,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 타이틀
                  Text(
                    '새로운 칭호 획득!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: widget.title.color.withValues(alpha: 0.7),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // 칭호 이름
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.title.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.title.color.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      widget.title.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.title.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 설명
                  Text(
                    widget.title.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // 등급 뱃지
                  _buildRarityBadge(),

                  const SizedBox(height: 20),

                  // 확인 버튼
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.title.color.withValues(alpha: 0.2),
                      foregroundColor: widget.title.color,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: widget.title.color.withValues(alpha: 0.7),
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 등급 뱃지 위젯
  Widget _buildRarityBadge() {
    Color badgeColor;
    String rarityText;

    switch (widget.title.rarity) {
      case 3:
        badgeColor = Colors.orange;
        rarityText = '전설 등급';
        break;
      case 2:
        badgeColor = Colors.purple;
        rarityText = '영웅 등급';
        break;
      case 1:
        badgeColor = Colors.blue;
        rarityText = '희귀 등급';
        break;
      case 0:
      default:
        badgeColor = Colors.green;
        rarityText = '일반 등급';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: Text(
        rarityText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  // 아이콘 선택 함수
  IconData _getTitleIcon() {
    if (widget.title.conditionType.startsWith('level_up')) {
      return BootstrapIcons.arrow_up_circle;
    } else if (widget.title.conditionType.startsWith('mission_complete')) {
      return BootstrapIcons.check2_all;
    } else if (widget.title.conditionType.startsWith('streak')) {
      return BootstrapIcons.calendar2_week;
    } else if (widget.title.conditionType.startsWith('job_mission')) {
      return BootstrapIcons.briefcase;
    } else if (widget.title.conditionType.startsWith('time_mission')) {
      return BootstrapIcons.clock;
    } else if (widget.title.conditionType.startsWith('day_complete')) {
      return BootstrapIcons.trophy;
    } else if (widget.title.conditionType.startsWith('hidden')) {
      return BootstrapIcons.gem;
    } else if (widget.title.conditionType.startsWith('registration')) {
      return BootstrapIcons.person_plus;
    }

    return BootstrapIcons.award;
  }
}
