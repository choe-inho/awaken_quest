import 'package:awaken_quest/utils/App_Theme.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
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

  await Hive.initFlutter();

  Hive.registerAdapter(MissionAdapter());

  await Hive.openBox<Mission>('customMissionBox');

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