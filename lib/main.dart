import 'package:awaken_quest/utils/App_Theme.dart';
import 'package:awaken_quest/utils/Notification_Service.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:awaken_quest/utils/manager/Title_Integration.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'app/routes/App_Pages.dart';
import 'app/routes/App_Routes.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 알림 시스템 초기화
  await NotificationService().initialize();

  // AdMob 초기화
  await MobileAds.instance.initialize();

  // 디버그 환경에서는 테스트 광고 활성화
  if (kDebugMode) {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['테스트_기기_ID']),
    );
  }

  await Hive.initFlutter();

  try {
    // 모델 어댑터 등록
    Hive.registerAdapter(MissionAdapter()); //미션 어뎁터 등록
    registerTitleAdapters(); // 칭호 어댑터 등록

    if (!Hive.isBoxOpen('customMissionBox')) {
      await Hive.openBox<Mission>('customMissionBox');
    }
    // 각 박스 오픈 - 이미 열려있는지 확인 후 열기
    if (!Hive.isBoxOpen('customMissionBox')) {
      await Hive.openBox('customMissionBox');
    }

  } catch (e) {
    print('Hive 초기화 오류: $e');
  }

  // 한국어 로케일 데이터 초기화 (여기서 한 번만 실행)
  await initializeDateFormatting('ko_KR');

  runApp(const Awaken());
}

class Awaken extends StatelessWidget {
  const Awaken({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash, // 처음 보여줄 페이지
      getPages: AppPages.routes,
      initialBinding: InitBinding(),
    );
  }
}


class InitBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(AppController());
    Get.put(UserController());
  }
}