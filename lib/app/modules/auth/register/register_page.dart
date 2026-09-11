import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import 'register_controller.dart';

/// Halaman Pendaftaran Akun Mahasiswa.
/// Menerapkan antislop-layoutmobile dan flutter-build-responsive-layout:
/// - Responsive constraint (maxWidth: 540px).
/// - Tap target minimum 50px untuk tombol dan input field.
/// - Validasi input yang jelas dan pesan error yang ter-sanitasi.
class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran Mahasiswa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
              child: Container(
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    width: 1.2,
                  ),
                  boxShadow: isDark ? null : AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Data Pribadi
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 20, color: isDark ? AppTheme.primary500 : AppTheme.primary700),
                        const SizedBox(width: 8),
                        Text(
                          'Data Pribadi Mahasiswa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.initialsController,
                            decoration: const InputDecoration(
                              labelText: 'Inisial (Opsional)',
                              hintText: 'Contoh: AP',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller.usiaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Usia (Tahun)',
                              hintText: '20',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Jenis Kelamin:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Perempuan', style: TextStyle(fontSize: 13.5)),
                                value: 'P',
                                activeColor: isDark ? AppTheme.primary500 : AppTheme.primary700,
                                groupValue: controller.selectedGender.value,
                                onChanged: (val) {
                                  if (val != null) controller.selectedGender.value = val;
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Laki-laki', style: TextStyle(fontSize: 13.5)),
                                value: 'L',
                                activeColor: isDark ? AppTheme.primary500 : AppTheme.primary700,
                                groupValue: controller.selectedGender.value,
                                onChanged: (val) {
                                  if (val != null) controller.selectedGender.value = val;
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(height: 10),
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedAgama.value,
                          decoration: const InputDecoration(
                            labelText: 'Agama',
                          ),
                          items: controller.agamaList
                              .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedAgama.value = val;
                          },
                        )),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Section 2: Data Akademik & Akun
                    Row(
                      children: [
                        Icon(Icons.school_outlined, size: 20, color: isDark ? AppTheme.primary500 : AppTheme.primary700),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Akademik & Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.nimController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Induk Mahasiswa (NIM)',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.prodiController,
                      decoration: const InputDecoration(
                        labelText: 'Program Studi',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.fakultasController,
                      decoration: const InputDecoration(
                        labelText: 'Fakultas',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Aktif',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => TextField(
                          controller: controller.passwordController,
                          obscureText: controller.isPasswordHidden.value,
                          decoration: InputDecoration(
                            labelText: 'Kata Sandi',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          ),
                        )),
                    const SizedBox(height: 12),
                    Obx(() => TextField(
                          controller: controller.passwordConfirmController,
                          obscureText: controller.isPasswordHidden.value,
                          decoration: const InputDecoration(
                            labelText: 'Konfirmasi Kata Sandi',
                            prefixIcon: Icon(Icons.lock_reset_outlined),
                          ),
                        )),
                    const SizedBox(height: 26),

                    // Submit Button
                    Obx(() => SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppTheme.primary500 : AppTheme.primary700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: controller.isLoading.value ? null : controller.register,
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Daftar Akun Sekarang',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
