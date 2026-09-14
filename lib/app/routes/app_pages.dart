// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_page.dart';
import '../modules/auth/register/register_binding.dart';
import '../modules/auth/register/register_page.dart';
import '../modules/cases/case_detail_page.dart';
import '../modules/cases/case_list_page.dart';
import '../modules/cases/cases_binding.dart';
import '../modules/education/education_binding.dart';
import '../modules/education/module_detail_page.dart';
import '../modules/education/module_list_page.dart';
import '../modules/education/posttest_page.dart';
import '../modules/education/pretest_page.dart';
import '../modules/education/result_page.dart';
import '../modules/education/topic_page.dart';
import '../modules/forum/forum_binding.dart';
import '../modules/forum/forum_create_page.dart';
import '../modules/forum/forum_detail_page.dart';
import '../modules/forum/forum_list_page.dart';
import '../modules/gamification/gamification_binding.dart';
import '../modules/gamification/myth_fact_page.dart';
import '../modules/gamification/trivia_page.dart';
import '../modules/main_nav/main_nav_binding.dart';
import '../modules/main_nav/main_nav_page.dart';
import '../modules/posters/poster_detail_page.dart';
import '../modules/posters/poster_list_page.dart';
import '../modules/posters/posters_binding.dart';
import '../modules/splash/splash_page.dart';
import '../modules/selfcare/blood_guide_page.dart';
import '../modules/selfcare/bmi_page.dart';
import '../modules/selfcare/hygiene_guide_page.dart';
import '../modules/selfcare/period_page.dart';
import '../modules/selfcare/selfcare_binding.dart';
import '../modules/selfcare/selfcare_tab.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const MainNavPage(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION_MODULE_LIST,
      page: () => const ModuleListPage(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION_MODULE_DETAIL,
      page: () => const ModuleDetailPage(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION_PRETEST,
      page: () => const PretestPage(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION_TOPIC,
      page: () => const TopicPage(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION_POSTTEST,
      page: () => const PosttestPage(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION_RESULT,
      page: () => const ResultPage(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.SELFCARE,
      page: () => const SelfcareTab(),
      binding: SelfcareBinding(),
    ),
    GetPage(
      name: _Paths.SELFCARE_PERIOD,
      page: () => const PeriodPage(),
      binding: SelfcareBinding(),
    ),
    GetPage(
      name: _Paths.SELFCARE_BMI,
      page: () => const BmiPage(),
      binding: SelfcareBinding(),
    ),
    GetPage(
      name: _Paths.SELFCARE_BLOOD_GUIDE,
      page: () => const BloodGuidePage(),
      binding: SelfcareBinding(),
    ),
    GetPage(
      name: _Paths.SELFCARE_HYGIENE_GUIDE,
      page: () => const HygieneGuidePage(),
      binding: SelfcareBinding(),
    ),
    GetPage(
      name: _Paths.POSTERS,
      page: () => const PosterListPage(),
      binding: PostersBinding(),
    ),
    GetPage(
      name: _Paths.POSTER_DETAIL,
      page: () => const PosterDetailPage(),
      binding: PostersBinding(),
    ),
    GetPage(
      name: _Paths.CASES,
      page: () => const CaseListPage(),
      binding: CasesBinding(),
    ),
    GetPage(
      name: _Paths.CASE_DETAIL,
      page: () => const CaseDetailPage(),
      binding: CasesBinding(),
    ),
    GetPage(
      name: _Paths.FORUM,
      page: () => const ForumListPage(),
      binding: ForumBinding(),
    ),
    GetPage(
      name: _Paths.FORUM_DETAIL,
      page: () => const ForumDetailPage(),
      binding: ForumBinding(),
    ),
    GetPage(
      name: _Paths.FORUM_CREATE,
      page: () => const ForumCreatePage(),
      binding: ForumBinding(),
    ),
    GetPage(
      name: _Paths.TRIVIA,
      page: () => const TriviaPage(),
      binding: GamificationBinding(),
    ),
    GetPage(
      name: _Paths.MYTH_FACT,
      page: () => const MythFactPage(),
      binding: GamificationBinding(),
    ),
  ];
}
