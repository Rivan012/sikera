import 'package:get/get.dart';
import '../home/home_controller.dart';
import '../education/education_controller.dart';
import '../profile/profile_controller.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;

    // Refresh tab data in background when switched to keep progress and stats synchronized
    try {
      if (index == 0 && Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchDashboard(forceRefresh: true);
      } else if (index == 1 && Get.isRegistered<EducationController>()) {
        Get.find<EducationController>().fetchModules(forceRefresh: true);
      } else if (index == 2 && Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfile(forceRefresh: true);
      }
    } catch (_) {}
  }
}
