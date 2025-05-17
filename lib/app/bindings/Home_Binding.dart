import 'package:awaken_quest/utils/manager/Import_Manager.dart';

class HomeBinding extends Bindings{
  @override
  void dependencies() async{
    Get.put(HomeController());
  }
}