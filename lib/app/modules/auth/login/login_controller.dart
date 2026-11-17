import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
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
      Get.snackbar(
        'Peringatan',
        'Email dan kata sandi wajib diisi.',
        backgroundColor: Colors.amber.shade700,
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
          response.message ?? 'Gagal masuk. Periksa email dan kata sandi.';
      Get.snackbar(
        'Gagal Masuk',
        errorMessage.value,
        backgroundColor: Colors.red.shade700,
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
