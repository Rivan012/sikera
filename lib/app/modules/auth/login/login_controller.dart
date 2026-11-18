import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final errorMessage = ''.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      const message =
          'Email dan kata sandi wajib diisi untuk masuk ke akun Anda.';
      errorMessage.value = message;
      Get.snackbar(
        'Data Belum Lengkap',
        message,
        backgroundColor: AppTheme.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (!email.contains('@') || email.startsWith('@') || email.endsWith('@')) {
      const message = 'Email belum valid. Gunakan format nama@kampus.ac.id.';
      errorMessage.value = message;
      Get.snackbar(
        'Format Email',
        message,
        backgroundColor: AppTheme.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final response = await ApiService.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
      auth: false,
    );

    isLoading.value = false;

    if (response.success && response.data != null) {
      final token = response.data['token']?.toString();
      final user = response.data['user'];

      if (token != null) {
        await StorageService.setToken(token);
      }
      if (user != null) {
        await StorageService.setUserJson(jsonEncode(user));
      }

      Get.offAllNamed(
        StorageService.termsPrivacyAccepted
            ? Routes.HOME
            : Routes.TERMS_PRIVACY_CONSENT,
      );
    } else {
      errorMessage.value =
          response.message ??
          'Gagal masuk. Periksa kembali email dan kata sandi Anda.';
      Get.snackbar(
        'Gagal Masuk',
        errorMessage.value,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
