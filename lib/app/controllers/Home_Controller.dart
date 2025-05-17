import 'package:awaken_quest/utils/manager/Import_Manager.dart';

import '../../utils/manager/Title_Integration.dart';

class HomeController extends GetxController {
   final TextStyle labelStyle = const TextStyle(color: Color(0xfff1f1f1), fontSize: 16, fontWeight: FontWeight.w700);
   final TextStyle valueStyle = const TextStyle(color: Color(0xfff1f1f1), fontSize: 16, fontWeight: FontWeight.w700);
   RxInt currentTab = 0.obs;


   @override
  void onReady() {
    init();
    super.onReady();
  }

  Future<void> init() async{
     await initializeTitleSystem();
     Get.find<UserController>().onUserLogin();
  }
}
