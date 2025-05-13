import 'package:awaken_quest/model/User_Model.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';

class RegisterController extends GetxController{
  final keywords = JobInfo.jobKeywordWeights.values
      .expand((keywordMap) => keywordMap.keys)
      .toSet()
      .toList();

  PageController pageController = PageController();
  RxString nickName = ''.obs;
  RxString selectedGender = ''.obs;
  RxInt currentPage = 0.obs;
  RxList<String> currentTag = <String>[].obs;

  RxBool loading = false.obs;

  void createUser() async{
    bool pageMove = false;
    try{
      loading.value = true;
      final job = JobInfo().getRecommendedJob(currentTag);
      final UserModel createUser = UserModel.firstCreate(nickname: nickName.value, gender: selectedGender.value, goal: currentTag, job: job);

      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set(createUser.toMap());
      pageMove = true;
    }on FirebaseException catch(error){
      FirebaseExceptionHandler.firebaseGeneralExceptionHandler(error.code);
    }finally{
      loading.value = false;
      if(pageMove){
        Get.offAllNamed('/splash', arguments: {'firstRoute': true});
      }
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}