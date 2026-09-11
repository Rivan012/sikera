import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
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
  final isPasswordHidden = true.obs;

  final agamaList = ['Islam', 'Kristen Protestan', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'];
  final pendidikanList = ['SMA/SMK/MA/Sederajat', 'Diploma (D3/D4)', 'Sarjana (S1)'];

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final passwordConfirm = passwordConfirmController.text;
    final nim = nimController.text.trim();
    final usia = int.tryParse(usiaController.text.trim());

    if (name.isEmpty || email.isEmpty || password.isEmpty || nim.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Nama, NIM, Email, dan Kata Sandi wajib diisi.',
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (password != passwordConfirm) {
      Get.snackbar(
        'Peringatan',
        'Konfirmasi kata sandi tidak cocok.',
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;

    final requestBody = {
      'name': name,
      'initials': initialsController.text.trim().isNotEmpty
          ? initialsController.text.trim()
          : name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
      'usia': usia ?? 18,
      'gender': selectedGender.value,
      'agama': selectedAgama.value,
      'prodi': prodiController.text.trim().isNotEmpty ? prodiController.text.trim() : 'Pendidikan',
      'fakultas': fakultasController.text.trim().isNotEmpty ? fakultasController.text.trim() : 'FKIP',
      'pendidikan_terakhir': selectedPendidikan.value,
      'nim': nim,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirm,
    };

    final response = await ApiService.post(
      ApiConstants.register,
      body: requestBody,
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

      Get.offAllNamed(Routes.HOME);
      Get.snackbar(
        'Registrasi Berhasil',
        'Selamat datang di aplikasi SIKERA.',
        backgroundColor: Colors.teal.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } else {
      String errorText = response.message ?? 'Terjadi kesalahan saat mendaftar.';
      if (errorText.contains('users.nim') || errorText.contains('NIM ini sudah terdaftar')) {
        errorText = 'NIM "$nim" sudah terdaftar di sistem. Silakan gunakan NIM Anda yang benar atau masuk ke akun Anda.';
      } else if (errorText.contains('users.email') || errorText.contains('Email ini sudah terdaftar')) {
        errorText = 'Email "$email" sudah terdaftar. Silakan gunakan menu Masuk/Login.';
      }

      Get.snackbar(
        'Pendaftaran Gagal',
        errorText,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    }
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
