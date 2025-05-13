import 'package:awaken_quest/app/controllers/Awakening_Animation_Controller.dart';
import 'package:awaken_quest/app/pages/signing/awakening/widget/Awakening_Gender_Effect.dart';
import '../../../../utils/manager/Import_Manager.dart';

class Awakening extends GetView<AwakeningAnimationController> {
  const Awakening({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: AwakeningGenderEffect(gender: controller.userController.user.value?.gender ?? '남자',)
      ),
    );
  }
}
