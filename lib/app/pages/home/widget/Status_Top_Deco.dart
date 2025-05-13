import '../../../../utils/manager/Import_Manager.dart';

class StatusTopDeco extends StatelessWidget {
  const StatusTopDeco({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Image.asset('assets/image/widget/status/warrior_status.png', fit: BoxFit.fitWidth,),
    );
  }
}
