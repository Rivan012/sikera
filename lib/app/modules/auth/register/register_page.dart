import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../legal/widgets/legal_links.dart';
import 'register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran Mahasiswa'),
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Obx(() {
              final loading = controller.isLoading.value;
              final error = controller.errorMessage.value;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Data Pribadi Mahasiswa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.primary900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field(
                        context,
                        key: 'register-name',
                        label: 'Nama Lengkap',
                        hint: 'Nama sesuai KTM',
                        controller: controller.nameController,
                        loading: loading,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        context,
                        key: 'register-initials',
                        label: 'Inisial (Opsional)',
                        hint: 'Contoh: AP',
                        controller: controller.initialsController,
                        loading: loading,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        context,
                        key: 'register-age',
                        label: 'Usia (Tahun)',
                        hint: 'Contoh: 20',
                        controller: controller.usiaController,
                        loading: loading,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Jenis Kelamin',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RadioGroup<String>(
                        groupValue: controller.selectedGender.value,
                        onChanged: (val) {
                          if (val != null && !loading) {
                            controller.selectedGender.value = val;
                          }
                        },
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: const Text('Perempuan'),
                              value: 'P',
                              enabled: !loading,
                              activeColor: isDark
                                  ? AppTheme.primary500
                                  : AppTheme.primary700,
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile<String>(
                              title: const Text('Laki-laki'),
                              value: 'L',
                              enabled: !loading,
                              activeColor: isDark
                                  ? AppTheme.primary500
                                  : AppTheme.primary700,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Agama',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        itemHeight: null,
                        initialValue: controller.selectedAgama.value,
                        items: controller.agamaList
                            .map(
                              (a) => DropdownMenuItem(value: a, child: Text(a)),
                            )
                            .toList(),
                        onChanged: loading
                            ? null
                            : (val) {
                                if (val != null) {
                                  controller.selectedAgama.value = val;
                                }
                              },
                      ),
                      const SizedBox(height: 28),
                      const Divider(height: 1),
                      const SizedBox(height: 24),
                      Text(
                        'Informasi Akademik & Akun',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.primary900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field(
                        context,
                        key: 'register-nim',
                        label: 'Nomor Induk Mahasiswa (NIM)',
                        hint: 'Masukkan NIM',
                        controller: controller.nimController,
                        loading: loading,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        context,
                        key: 'register-program',
                        label: 'Program Studi',
                        hint: 'Contoh: Sistem Informasi',
                        controller: controller.prodiController,
                        loading: loading,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        context,
                        key: 'register-faculty',
                        label: 'Fakultas',
                        hint: 'Contoh: Teknik',
                        controller: controller.fakultasController,
                        loading: loading,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        context,
                        key: 'register-email',
                        label: 'Email Aktif',
                        hint: 'nama@kampus.ac.id',
                        controller: controller.emailController,
                        loading: loading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kata Sandi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const ValueKey('register-password'),
                        controller: controller.passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        readOnly: loading,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => controller.errorMessage.value = '',
                        decoration: InputDecoration(
                          hintText: 'Minimal 6 karakter',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            borderSide: BorderSide(color: colors.outline),
                          ),
                          suffixIcon: IconButton(
                            tooltip: controller.isPasswordHidden.value
                                ? 'Tampilkan kata sandi'
                                : 'Sembunyikan kata sandi',
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Konfirmasi Kata Sandi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const ValueKey('register-password-confirm'),
                        controller: controller.passwordConfirmController,
                        obscureText: controller.isPasswordHidden.value,
                        readOnly: loading,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => controller.errorMessage.value = '',
                        onSubmitted: (_) {
                          if (!controller.isLoading.value) {
                            controller.register();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Ulangi kata sandi',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            borderSide: BorderSide(color: colors.outline),
                          ),
                        ),
                      ),
                      if (error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            error,
                            style: TextStyle(
                              color: colors.error,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const LegalLinks(),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: colors.surfaceContainerHigh,
                          disabledForegroundColor: colors.onSurface,
                          minimumSize: const Size(double.infinity, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onPressed: loading ? null : controller.register,
                        child: loading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  semanticsLabel: 'Mendaftarkan akun...',
                                  color: colors.onSurface,
                                ),
                              )
                            : const Text(
                                'Daftar Akun Sekarang',
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context, {
    required String key,
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool loading,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: label,
          child: TextField(
            key: ValueKey(key),
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            readOnly: loading,
            onChanged: (_) => this.controller.errorMessage.value = '',
            decoration: InputDecoration(
              hintText: hint,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(color: colors.outline),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
