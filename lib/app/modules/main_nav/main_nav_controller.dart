import 'dart:convert';

import 'package:get/get.dart';

import '../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../admin/admin_assessment_controller.dart';
import '../education/education_controller.dart';
import '../home/home_controller.dart';
import '../profile/profile_controller.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;
  final isAdmin = false.obs;

  int get tabCount => isAdmin.value ? 4 : 3;
  int get profileTabIndex => isAdmin.value ? 3 : 2;

  @override
  void onInit() {
    super.onInit();
    syncRoleFromStorage();
  }

  void syncRoleFromStorage() {
    final raw = StorageService.getUserJson();
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        syncUserRole(UserModel.fromJson(decoded));
      }
    } catch (_) {}
  }

  void syncUserRole(UserModel? user) {
    final admin = user?.isAdmin ?? false;
    if (isAdmin.value != admin) {
      isAdmin.value = admin;
      if (currentIndex.value >= tabCount) {
        currentIndex.value = 0;
      }
    }
  }

  void changeTab(int index) {
    final clamped = index.clamp(0, tabCount - 1);
    currentIndex.value = clamped;

    try {
      if (isAdmin.value) {
        if (clamped == 0 && Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchDashboard(forceRefresh: true);
        } else if (clamped == 1 && Get.isRegistered<AdminAssessmentController>()) {
          Get.find<AdminAssessmentController>().loadPretestTab(
            forceRefresh: true,
          );
        } else if (clamped == 2 && Get.isRegistered<AdminAssessmentController>()) {
          Get.find<AdminAssessmentController>().fetchPosttestQuestions(
            forceRefresh: true,
          );
        } else if (clamped == 3 && Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfile(forceRefresh: true);
        }
      } else {
        if (clamped == 0 && Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchDashboard(forceRefresh: true);
        } else if (clamped == 1 && Get.isRegistered<EducationController>()) {
          Get.find<EducationController>().fetchModules(forceRefresh: true);
        } else if (clamped == 2 && Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfile(forceRefresh: true);
        }
      }
    } catch (_) {}
  }
}
