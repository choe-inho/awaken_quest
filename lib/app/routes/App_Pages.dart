import 'package:awaken_quest/app/bindings/Home_Binding.dart';
import 'package:awaken_quest/app/bindings/Quest_Binding.dart';
import 'package:awaken_quest/app/bindings/Register_Binding.dart';
import 'package:awaken_quest/app/controllers/Awakening_Animation_Controller.dart';
import 'package:awaken_quest/app/pages/loading/Loading.dart';
import 'package:awaken_quest/app/pages/splash/Splash.dart';

import '../../utils/manager/Import_Manager.dart';
import '../pages/home/Home.dart';
import '../pages/quests/Quest.dart';
import '../pages/setting/Setting.dart';
import '../pages/signing/awakening/Awakening.dart';
import '../pages/signing/awakening/Job_Result.dart';
import '../pages/signing/login/Login.dart';
import '../pages/signing/register/Register.dart';
import 'App_Routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const Splash(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const Login(), //로그인
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const Register(), //회원가입
      transition: Transition.fadeIn,
      binding: RegisterBinding()
    ),
    GetPage(
      name: AppRoutes.awakening,
      page: () => const Awakening(), //첫가입 후 환영
      transition: Transition.rightToLeft,
      binding: AwakeningAnimationBindings()
    ),
    GetPage(
      name: AppRoutes.jobResult,
      page: () => const JobResult(), //첫가입 후 직업 결과
      transition: Transition.zoom,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const Home(), //홈
      transition: Transition.fade,
      bindings: [
        HomeBinding(),
        QuestBinding()
      ]
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const Setting(), //기타 설정
    ),
    GetPage(
        name: AppRoutes.loading,
        page: ()=> const Loading()
    )
  ];
}