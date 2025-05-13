import '../../../../utils/manager/Import_Manager.dart';

class NeonDivider extends StatelessWidget {
  const NeonDivider({super.key,  this.color = Colors.cyanAccent});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              color.withValues(alpha: 0.7),
              color,
              color.withValues(alpha: 0.7),
              Colors.transparent,
            ],
            stops: [0.0, 0.4, 0.5, 0.6, 1.0],
          ),
        ),
      ),
    );
  }
}
