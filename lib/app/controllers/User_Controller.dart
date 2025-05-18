
import 'package:awaken_quest/model/Mission_Cleared.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/User_Model.dart';
import '../../utils/handler/Hive_Handler.dart';
import '../../utils/handler/Login_Streak_Handler.dart';
import '../../utils/manager/Title_Integration.dart';

class UserController extends GetxController{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxInt progress = 0.obs;
  RxBool firebaseConnected = false.obs;
  Rxn<UserModel> user = Rxn<UserModel>();
  Rxn<MissionCleared> cleared = Rxn<MissionCleared>();

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

          //클리어한 미션 들고오가
          final missionDoc = await _firestore.collection('users').doc(currentUser.uid).collection('cleared').doc('job').get();

          if(!missionDoc.exists){ //존재하지 않는 다면 만들기
            final map = _createClearedMode();
            await _firestore.collection('users').doc(currentUser.uid).collection('cleared').doc('job').set(map);
            cleared.value = MissionCleared.fromJson(map);
          }else{
            cleared.value = MissionCleared.fromJson(missionDoc.data()!);
          }

          progress.value += 50;
          firebaseConnected.value = true;

          await setFirstLogin();

          //커스텀 박스 로드
          await loadCustomTodoList();

          // 칭호 시스템과 통합
          await TitleIntegration().integrateWithUserProfile(this);

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

  //미션 클리어한 갯수 기록 만들기
  Map<String, dynamic> _createClearedMode(){
    return {
      'warrior': 0,
      'magic': 0,
      'healer': 0,
      'smith': 0,
      'explorer': 0
    };
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

  final _streakHandler = LoginStreakHandler();

  // 사용자 로그인 후 또는 앱 시작 시
  Future<void> onUserLogin() async {
    // 로그인 스트릭 계산
    final currentStreak = await _streakHandler.calculateLoginStreak();
    // 칭호 시스템과 통합
    await TitleIntegration().integrateWithLoginStreak(currentStreak);
  }


  updateUser({int? level, int? exp, int? mp, int? hp, int? health, int? mana, int? stamina, int? blackMana, int? agility, int? strength, int? extraStat, List<String>? goal, String? nickname, String? job}){
    user.value = user.value!.copyWith(
      level: level,
      exp: exp,
      mp : mp,
      hp : hp,
      extraStat: extraStat,
      health: health,
      stamina: stamina,
      mana: mana,
      agility: agility,
      blackMana: blackMana,
      goal: goal,
      job: job,
      nickname: nickname,
      strength: strength,
    );

    //수동 업데이트
    user.refresh();
    update();
  }

  Future<void> updateCleared() async {
    final job = user.value!.job;

    // 현재 직업 필드 가져오기
    final fieldName = job == '전사' ? 'warrior' : job == '마법사' ? 'magic' : job ==
        '힐러' ? 'healer' : job == '대장장이' ? 'smith' : job == '탐험가'
        ? 'explorer'
        : 'warrior'; // '전사', '마법사', '힐러', '대장장이', '탐험가'

    // 현재 값에 1 증가
    final currentValue = cleared.value!.toMap()[fieldName] ?? 0;
    final newValue = currentValue + 1;

    // 로컬 상태 업데이트
    cleared.value = cleared.value!.copyWith(
      warrior: job == '전사' ? newValue : null,
      magic: job == '마법사' ? newValue : null,
      healer: job == '힐러' ? newValue : null,
      smith: job == '대장장이' ? newValue : null,
      explorer: job == '탐험가' ? newValue : null,
    );

    // Firestore 업데이트
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cleared')
        .doc('job')
        .update({fieldName: newValue});

    cleared.refresh();
    update();
  }

  //커스텀 투두리스트
  List<Mission> customTodoList = <Mission>[];

  // 커스텀 투두리스트 불러오기 메서드 추가
  Future<void> loadCustomTodoList() async {
    try {
      // Hive 박스에서 불러오기
      customTodoList = HiveHandler.allQuest;
      update();
    } catch (e) {
      print("커스텀 투두리스트 로딩 오류: $e");
    }
  }

  updateStat(Map<String, dynamic> map){
    try{
      _firestore.collection('users').doc(_auth.currentUser!.uid).update(
          map
      );
    }catch(err){
      print(err);
    }
  }
}