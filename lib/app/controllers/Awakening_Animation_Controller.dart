import 'dart:ui';

import 'package:awaken_quest/utils/dialog/Awakening_Success_Dialog.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';

class AwakeningAnimationController extends GetxController{
  final userController = Get.find<UserController>();

  @override
  void onReady() {
    startAnimation();
    super.onReady();
  }

  void startAnimation() async{
    Future.delayed(const Duration(microseconds: 500));
    _firstDialog();
  }


  void _firstDialog() async {
    Get.dialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      AwakeningSuccessDialog(
          onComplete: (){
            Get.back(); // 다이얼로그 닫고
            Get.offAllNamed('/job_result');
          },
          nickname: userController.user.value?.nickname ?? '(알수없음)'),
    );
  }

}

class AwakeningAnimationBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=> AwakeningAnimationController());
  }
}