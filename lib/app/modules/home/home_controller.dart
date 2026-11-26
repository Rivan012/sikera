import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/services/google_auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_pages.dart';
import '../education/education_controller.dart';
import '../main_nav/main_nav_controller.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final dashboardData = Rxn<DashboardDataModel>();
  final currentUser = Rxn<UserModel>();

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocalUser();
    fetchDashboard();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadLocalUser() {
    final userJson = StorageService.getUserJson();
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(userJson);
        if (decoded is Map<String, dynamic>) {
          currentUser.value = UserModel.fromJson(decoded);
          if (Get.isRegistered<MainNavController>()) {
            Get.find<MainNavController>().syncUserRole(currentUser.value);
          }
        }
      } catch (_) {}
    }
  }

  Future<void> fetchDashboard({bool forceRefresh = false}) async {
    if (!StorageService.hasToken) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    if (dashboardData.value == null || forceRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.dashboard);

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        dashboardData.value = DashboardDataModel.fromJson(response.data);
        if (dashboardData.value?.user != null) {
          currentUser.value = dashboardData.value!.user;
          if (Get.isRegistered<MainNavController>()) {
            Get.find<MainNavController>().syncUserRole(currentUser.value);
          }
        }
        if (dashboardData.value?.posttestStatus != null &&
            Get.isRegistered<EducationController>()) {
          Get.find<EducationController>().posttestStatus.value =
              dashboardData.value!.posttestStatus;
        }
      }
    } else {
      if (dashboardData.value == null) {
        errorMessage.value = response.message ?? 'Gagal memuat ringkasan beranda.';
      }
    }
  }

  Future<void> logout() async {
    await ApiService.post(ApiConstants.logout);
    await GoogleAuthService.signOut();
    await StorageService.clearAuth();
    Get.offAllNamed(Routes.LOGIN);
  }
}
