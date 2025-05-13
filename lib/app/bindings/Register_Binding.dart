import 'package:awaken_quest/app/controllers/Register_Controller.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';

class RegisterBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>RegisterController());
  }

}