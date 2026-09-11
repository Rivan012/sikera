import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final user = Rxn<UserModel>();

  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkTheme();
    fetchProfile();
  }

  void _checkTheme() {
    final mode = StorageService.getThemeMode();
    isDarkMode.value = mode == 'dark' || Get.isDarkMode;
  }

  void toggleTheme(bool value) async {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    await StorageService.setThemeMode(value ? 'dark' : 'light');
  }

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    if (user.value == null || forceRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.me);

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final target = map['user'] is Map<String, dynamic>
            ? map['user'] as Map<String, dynamic>
            : map;
        user.value = UserModel.fromJson(target);
      }
    } else {
      if (user.value == null) {
        errorMessage.value = response.message ?? 'Gagal memuat profil pengguna.';
      }
    }
  }

  Future<void> logout() async {
    await ApiService.post(ApiConstants.logout);
    await StorageService.clearAuth();
    Get.offAllNamed(Routes.LOGIN);
  }
}
