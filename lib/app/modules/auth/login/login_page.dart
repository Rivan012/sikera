import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              constraints.maxWidth >= 900 &&
              MediaQuery.textScalerOf(context).scale(16) <= 22;
          final padding = EdgeInsets.symmetric(
            horizontal: wide
                ? 32
                : constraints.maxWidth < 360
                ? 16
                : 24,
            vertical: 24,
          );
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(
                  0,
                  constraints.maxHeight - padding.vertical,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? 1080 : 440),
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: _buildBrandPanel(context)),
                            const SizedBox(width: 64),
                            Expanded(
                              child: _buildForm(context, showBrand: false),
                            ),
                          ],
                        )
                      : _buildForm(context, showBrand: true),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _buildBrandPanel(BuildContext context) => Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: AppTheme.primary900,
      borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SIKERA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Image.asset(
            'assets/logo/sikera_logo_putih.png',
            width: 260,
            height: 260,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Kenali tubuhmu.\nTambah wawasanmu.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Edukasi kesehatan reproduksi dan pendampingan mahasiswa.',
          style: TextStyle(
            color: AppTheme.primary50,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    ),
  );

  Widget _buildBrandHeader(BuildContext context) => Row(
    children: [
      Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary900,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Image.asset(
          'assets/logo/sikera_logo_putih.png',
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SIKERA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kesehatan reproduksi mahasiswa',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildForm(BuildContext context, {required bool showBrand}) {
    final colors = Theme.of(context).colorScheme;
    return Obx(() {
      final loading = controller.isLoading.value;
      final error = controller.errorMessage.value;
      return AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBrand) ...[
              _buildBrandHeader(context),
              const SizedBox(height: 40),
            ],
            const Text(
              'Masuk ke akunmu',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Lanjutkan belajar dan pantau kesehatan reproduksimu.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Email',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Email',
              child: TextField(
                key: const ValueKey('login-email'),
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                autocorrect: false,
                readOnly: loading,
                onChanged: (_) => controller.errorMessage.value = '',
                decoration: InputDecoration(
                  hintText: 'nama@kampus.ac.id',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide(color: colors.outline),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kata sandi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Kata sandi',
              child: TextField(
                key: const ValueKey('login-password'),
                controller: controller.passwordController,
                obscureText: controller.isPasswordHidden.value,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                autocorrect: false,
                enableSuggestions: false,
                readOnly: loading,
                onChanged: (_) => controller.errorMessage.value = '',
                onSubmitted: (_) {
                  if (!controller.isLoading.value) {
                    controller.login();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide(color: colors.outline),
                  ),
                  suffixIcon: IconButton(
                    tooltip: controller.isPasswordHidden.value
                        ? 'Tampilkan kata sandi'
                        : 'Sembunyikan kata sandi',
                    onPressed: controller.togglePasswordVisibility,
                    icon: Icon(
                      controller.isPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
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
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: loading ? null : controller.login,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: colors.surfaceContainerHigh,
                disabledForegroundColor: colors.onSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              child: loading
                  ? Row(
                      children: [
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            semanticsLabel: 'Sedang masuk ke akun...',
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: ExcludeSemantics(
                            child: Text(
                              'Sedang masuk...',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Text('Masuk', textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Belum punya akun?',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () => Get.toNamed(Routes.REGISTER),
                  child: const Text('Daftar Mahasiswa'),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
