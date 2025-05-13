import '../../../../../utils/manager/Import_Manager.dart';

class JobImage extends StatelessWidget {
  const JobImage({super.key, required this.job});
  final String job;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      job == '전사' ? 'assets/image/job/warrior.png' :
      job == '마법사' ? 'assets/image/job/magic.png' :
      job == '힐러' ? 'assets/image/job/healer.png' :
      job == '대장장이' ? 'assets/image/job/smith.png' : 'assets/image/job/explorer.png' ,fit: BoxFit.cover, height: 300, width: 300,);
  }
}
