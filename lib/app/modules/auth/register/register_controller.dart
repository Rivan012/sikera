import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final initialsController = TextEditingController();
  final usiaController = TextEditingController();
  final prodiController = TextEditingController();
  final fakultasController = TextEditingController();
  final nimController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  final selectedGender = 'P'.obs;
  final selectedAgama = 'Islam'.obs;
  final selectedPendidikan = 'SMA/SMK/MA/Sederajat'.obs;

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isPasswordHidden = true.obs;
  final errorMessage = ''.obs;
  final googleErrorMessage = ''.obs;
  final fieldErrors = Rx<Map<String, String>>({});

  bool get isBusy => isLoading.value || isGoogleLoading.value;

  final agamaList = [
    'Islam',
    'Kristen Protestan',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];
  final pendidikanList = [
    'SMA/SMK/MA/Sederajat',
    'Diploma (D3/D4)',
    'Sarjana (S1)',
  ];

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void fieldChanged(String field) {
    errorMessage.value = '';
    googleErrorMessage.value = '';
    if (fieldErrors.value.containsKey(field)) {
      fieldErrors.value = {...fieldErrors.value}..remove(field);
    }
  }

  Future<void> register() async {
    if (isBusy) return;
    errorMessage.value = '';
    googleErrorMessage.value = '';
    fieldErrors.value = {};
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final passwordConfirm = passwordConfirmController.text;
    final nim = nimController.text.trim();
    final prodi = prodiController.text.trim();
    final fakultas = fakultasController.text.trim();
    final usia = int.tryParse(usiaController.text.trim());

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        prodi.isEmpty ||
        usiaController.text.trim().isEmpty) {
      const message =
          'Nama, usia, program studi, email, dan kata sandi wajib diisi.';
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

    if (usia == null || usia < 15 || usia > 40) {
      errorMessage.value = 'Masukkan usia antara 15 dan 40 tahun.';
      fieldErrors.value = {'usia': errorMessage.value};
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

    if (password.length < 6) {
      const message = 'Kata sandi minimal terdiri dari 6 karakter.';
      errorMessage.value = message;
      Get.snackbar(
        'Kata Sandi Terlalu Pendek',
        message,
        backgroundColor: AppTheme.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (password != passwordConfirm) {
      const message =
          'Konfirmasi kata sandi tidak cocok. Ketik ulang kata sandi yang sama.';
      errorMessage.value = message;
      Get.snackbar(
        'Konfirmasi Tidak Cocok',
        message,
        backgroundColor: AppTheme.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;

    final requestBody = {
      'name': name,
      if (initialsController.text.trim().isNotEmpty)
        'initials': initialsController.text.trim(),
      'usia': usia,
      'gender': selectedGender.value,
      'agama': selectedAgama.value,
      'prodi': prodi,
      if (fakultas.isNotEmpty) 'fakultas': fakultas,
      'pendidikan_terakhir': selectedPendidikan.value,
      if (nim.isNotEmpty) 'nim': nim,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirm,
    };

    final response = await ApiService.post(
      ApiConstants.register,
      body: requestBody,
      auth: false,
    );

    if (response.success) {
      final data = response.data;
      final token = data is Map ? data['token'] : null;
      final user = data is Map ? data['user'] : null;
      if (token is! String ||
          token.trim().isEmpty ||
          user is! Map ||
          (int.tryParse('${user['id']}') ?? 0) <= 0) {
        isLoading.value = false;
        errorMessage.value =
            'Sesi pendaftaran belum tersedia. Coba masuk dengan email dan kata sandi Anda.';
        return;
      }
      try {
        await StorageService.setToken(token);
        await StorageService.setUserJson(jsonEncode(user));
      } catch (_) {
        await StorageService.clearAuth();
        errorMessage.value = 'Sesi gagal disimpan. Coba masuk kembali.';
        return;
      } finally {
        isLoading.value = false;
      }

      Get.offAllNamed(Routes.TERMS_PRIVACY_CONSENT);
      Get.snackbar(
        'Registrasi Berhasil',
        'Selamat datang di aplikasi SIKERA.',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } else {
      isLoading.value = false;
      final data = response.data;
      final errors = data is Map ? data['errors'] : null;
      if (response.statusCode == 422 && errors is Map) {
        fieldErrors.value = {
          for (final entry in errors.entries)
            entry.key.toString(): entry.value is List
                ? (entry.value as List).join('\n')
                : entry.value.toString(),
        };
      }
      String errorText =
          response.message ?? 'Terjadi kesalahan saat mendaftar.';
      if (errorText.contains('users.nim') ||
          errorText.contains('NIM ini sudah terdaftar')) {
        errorText =
            'NIM "$nim" sudah terdaftar di sistem. Silakan gunakan NIM Anda yang benar atau masuk ke akun Anda.';
      } else if (errorText.contains('users.email') ||
          errorText.contains('Email ini sudah terdaftar')) {
        errorText =
            'Email "$email" sudah terdaftar. Silakan gunakan halaman Masuk.';
      }

      errorMessage.value = errorText;
      Get.snackbar(
        'Pendaftaran Gagal',
        errorText,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> registerWithGoogle() async {
    if (isBusy) return;
    isGoogleLoading.value = true;
    googleErrorMessage.value = '';
    errorMessage.value = '';

    final result = await GoogleAuthService.signIn();

    if (result.canceled) {
      isGoogleLoading.value = false;
      return;
    }

    if (result.success && result.token != null && result.user != null) {
      try {
        await StorageService.setToken(result.token!);
        await StorageService.setUserJson(jsonEncode(result.user));
      } catch (_) {
        await StorageService.clearAuth();
        isGoogleLoading.value = false;
        const message = 'Sesi pendaftaran gagal disimpan. Coba masuk kembali.';
        googleErrorMessage.value = message;
        Get.snackbar(
          'Pendaftaran Gagal',
          message,
          backgroundColor: AppTheme.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      } finally {
        isGoogleLoading.value = false;
      }

      Get.offAllNamed(
        StorageService.termsPrivacyAccepted
            ? Routes.HOME
            : Routes.TERMS_PRIVACY_CONSENT,
      );
      Get.snackbar(
        'Berhasil Masuk',
        'Selamat datang di aplikasi SIKERA.',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isGoogleLoading.value = false;
    googleErrorMessage.value =
        result.message ??
        'Gagal melanjutkan dengan Google. Periksa koneksi internet lalu coba lagi.';
    Get.snackbar(
      'Gagal Daftar dengan Google',
      googleErrorMessage.value,
      backgroundColor: AppTheme.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    initialsController.dispose();
    usiaController.dispose();
    prodiController.dispose();
    fakultasController.dispose();
    nimController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.onClose();
  }
}
