import 'package:awaken_quest/utils/manager/Import_Manager.dart';

import '../../utils/dialog/Title_Acheivemet_Dialog.dart';
import '../../utils/handler/Title_Handler.dart';
import '../../utils/manager/Title_Integration.dart';

class HomeController extends GetxController {
   final TextStyle labelStyle = const TextStyle(color: Color(0xfff1f1f1), fontSize: 16, fontWeight: FontWeight.w700);
   final TextStyle valueStyle = const TextStyle(color: Color(0xfff1f1f1), fontSize: 16, fontWeight: FontWeight.w700);
   RxInt currentTab = 0.obs;

   @override
  void onInit() {
     final titleHandler = TitleHandler();
     titleHandler.onTitleAcquired.listen((title) {
       // 현재 컨텍스트에 관계없이 다이얼로그 표시
       Get.dialog(TitleAchievementDialog(title: title));
     });
    super.onInit();
  }

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
