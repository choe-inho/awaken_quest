
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/User_Model.dart';

class UserController extends GetxController{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxInt progress = 0.obs;
  RxBool firebaseConnected = false.obs;
  Rxn<UserModel> user = Rxn<UserModel>();

  Future<void> userControllerInit() async{
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      firebaseConnected.value = false;
      fetchUserData();
    });
  }

  Future<void> fetchUserData() async {
    progress.value = 0;
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.offAllNamed('/login'); // 다음 페이지 이동
      }else{
        final doc = await _firestore.collection('users').doc(currentUser.uid).get();

        if (!doc.exists) {
          Get.offAllNamed('/register'); // 다음 페이지 이동
        }else{
          user.value = UserModel.fromMap(doc.data()!);
          progress.value += 50;
          firebaseConnected.value = true;
          await setFirstLogin();

          if(Get.arguments == null){
            Get.offAllNamed('/home');
          }else{
            Get.offAllNamed('/awakening'); //첫 진입시에는 애니메이션
          }
        }
      }

    } on FirebaseException catch (e) {
      print("유저 정보 로딩 실패: $e");
      FirebaseExceptionHandler.firebaseGeneralExceptionHandler(e.code);
      rethrow;
    }
  }

  //피로도 측정
  final loginKey = "iconoding.awaken.first.loginKey";
  DateTime? firstLogin;

  Future setFirstLogin() async{
    final prefs = await SharedPreferences.getInstance();

    //최초 로그인 (완전처음)
    final value = prefs.getString(loginKey);
    if(value == null){
      final now = DateTime.now();
      firstLogin = now;
      prefs.setString(loginKey, now.toIso8601String());
    }else{
      final memory = DateTime.parse(value).toLocal();
      final now = DateTime.now();

      final memoryDate = DateTime(memory.year, memory.month, memory.day);
      final todayDate = DateTime(now.year, now.month, now.day);

      if (memoryDate != todayDate) {
       prefs.setString(loginKey, now.toIso8601String());
       firstLogin = now;
      }
    }
  }


  //커스텀 목록 불러오기
  final customTodoKey = "iconoding.awaken.custom.todoKey";

  List<Mission> customTodoList = [];


}