import 'package:awaken_quest/app/widgets/Day_Countdown_Timer.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';

class DayCountdownTimerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DayCountdownTimerController());
  }
}
