import 'package:awaken_quest/utils/dialog/Basic_Dialog.dart';
import 'package:awaken_quest/utils/dialog/Error_Dialog.dart';
import 'package:awaken_quest/utils/dialog/Update_Dialog.dart';
import 'package:get/get.dart';

import '../manager/Import_Manager.dart';

class DialogFrame{

  // 다이얼로그 호출 유틸리티 함수
  Future<bool?> showHunterDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    bool showEffects = true,
  }) async {
    // 효과음 재생 또는 진동 기능 추가 가능

    return await Get.dialog(
        barrierDismissible: barrierDismissible,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        BasicDialog(
        mainTitle: title,
        text: message,
        confirmButtonText: confirmText,
        cancelButtonText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showEffects: showEffects,
      ));
  }


  static Future showUpdateDialog() async{
    await Get.dialog(UpdateDialog(), barrierDismissible: false);
  }

  static void errorHandler(String error){
    Get.dialog(ErrorDialog(error: error,));
  }


}