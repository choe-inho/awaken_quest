import 'package:awaken_quest/app/controllers/Quest_Controller.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';

class QuestBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(QuestController());
  }
}