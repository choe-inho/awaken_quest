import 'package:awaken_quest/app/controllers/Journal_Controller.dart';

import '../../utils/manager/Import_Manager.dart';

class JournalBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(JournalController());
  }
}