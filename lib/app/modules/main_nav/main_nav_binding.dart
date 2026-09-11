import 'package:get/get.dart';
import 'main_nav_controller.dart';
import '../home/home_controller.dart';
import '../education/education_controller.dart';
import '../forum/forum_controller.dart';
import '../selfcare/selfcare_controller.dart';
import '../profile/profile_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavController>(() => MainNavController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<EducationController>(() => EducationController(), fenix: true);
    Get.lazyPut<ForumController>(() => ForumController(), fenix: true);
    Get.lazyPut<SelfcareController>(() => SelfcareController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
