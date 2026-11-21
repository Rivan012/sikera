import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';
import '../../legal/widgets/legal_links.dart';
import '../widgets/google_auth_button.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scaledBase = MediaQuery.textScalerOf(context).scale(16);
              final wide = constraints.maxWidth >= 900 && scaledBase <= 22;
              final compact = constraints.maxWidth < 360 || scaledBase > 22;
              final padding = EdgeInsets.symmetric(
                horizontal: wide
                    ? 32
                    : constraints.maxWidth < 360
                    ? 16
                    : 20,
                vertical: wide ? 32 : 20,
              );

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                      constraints: BoxConstraints(maxWidth: wide ? 1040 : 460),
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 11,
                                    child: _buildBrandPanel(context, isDark),
                                  ),
                                  const SizedBox(width: 40),
                                  Expanded(
                                    flex: 10,
                                    child: _buildFormColumn(
                                      context,
                                      isDark: isDark,
                                      showMobileHeader: false,
                                      compact: compact,
                                    ),
                                  ),
                                ],
                              )
                            : _buildFormColumn(
                                context,
                                isDark: isDark,
                                showMobileHeader: true,
                                compact: compact,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrandPanel(BuildContext context, bool isDark) {
    final panelTextPrimary = isDark ? AppTheme.textPrimaryDark : Colors.white;
    final panelTextSecondary = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.primary50;
    final featureBg = isDark
        ? AppTheme.elevatedSurfaceDark
        : const Color(0x24FFFFFF);
    final featureIconColor = isDark ? AppTheme.primary200 : AppTheme.primary50;

    const capabilities = [
      (
        icon: Icons.menu_book_outlined,
        text: 'Modul edukasi kesehatan reproduksi terstruktur',
      ),
      (
        icon: Icons.calendar_month_outlined,
        text: 'Kalkulator IMT dan pencatatan siklus haid mandiri',
      ),
      (
        icon: Icons.forum_outlined,
        text: 'Ruang diskusi aman bersama konselor kampus',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.softAccentSurfaceDark : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary900,
                  Color(0xFF023E7D),
                  Color(0xFF005082),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
        borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
        border: isDark
            ? Border.all(color: AppTheme.borderDark, width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SIKERA',
                  style: TextStyle(
                    color: panelTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              Text(
                'Kesehatan Kampus',
                style: TextStyle(
                  color: panelTextSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Container(
              width: 176,
              height: 176,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.pocketSurfaceLight
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
              ),
              child: Image.asset(
                'assets/logo/sikera_logo_putih.png',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Kenali tubuhmu.\nPahami kesehatanmu.',
            style: TextStyle(
              color: panelTextPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.22,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pendamping belajar kesehatan reproduksi yang ramah, kredibel, dan menjaga privasi mahasiswa.',
            style: TextStyle(
              color: panelTextSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...capabilities.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: featureBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(item.icon, size: 18, color: featureIconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        item.text,
                        style: TextStyle(
                          color: panelTextPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBanner(
    BuildContext context, {
    required bool isDark,
    required bool compact,
  }) {
    final bannerBg = isDark
        ? AppTheme.softAccentSurfaceDark
        : AppTheme.primary50;
    final bannerBorder = isDark
        ? AppTheme.borderDark
        : AppTheme.strongBorderLight;
    final headingColor = isDark ? AppTheme.textPrimaryDark : AppTheme.primary900;
    final bodyColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final logoTileBg = isDark
        ? AppTheme.pocketSurfaceLight
        : AppTheme.surfaceLight;

    final logoTile = Container(
      width: compact ? 68 : 76,
      height: compact ? 68 : 76,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: logoTileBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Image.asset(
        'assets/logo/sikera_logo_putih.png',
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat datang di SIKERA',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: headingColor,
            height: 1.25,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Edukasi kesehatan reproduksi dan pendampingan mahasiswa.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.45,
            color: bodyColor,
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: bannerBorder, width: 1),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                logoTile,
                const SizedBox(height: 12),
                textColumn,
              ],
            )
          : Row(
              children: [
                logoTile,
                const SizedBox(width: 16),
                Expanded(child: textColumn),
              ],
            ),
    );
  }

  Widget _buildFormColumn(
    BuildContext context, {
    required bool isDark,
    required bool showMobileHeader,
    required bool compact,
  }) {
    final colors = Theme.of(context).colorScheme;
    final cardBg = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final cardBorder = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final headingColor = isDark ? AppTheme.textPrimaryDark : AppTheme.primary900;

    return Obx(() {
      final loading = controller.isLoading.value;
      final googleLoading = controller.isGoogleLoading.value;
      final busy = loading || googleLoading;
      final error = controller.errorMessage.value;

      return AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showMobileHeader) ...[
              _buildMobileBanner(
                context,
                isDark: isDark,
                compact: compact,
              ),
              const SizedBox(height: 20),
            ],
            Container(
              padding: EdgeInsets.all(compact ? 18 : 24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(color: cardBorder, width: 1),
                boxShadow: isDark ? null : AppTheme.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Masuk ke akunmu',
                    style: TextStyle(
                      fontSize: compact ? 24 : 28,
                      fontWeight: FontWeight.w700,
                      color: headingColor,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lanjutkan belajar dan pantau catatan kesehatan reproduksimu.',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: headingColor,
                    ),
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
                      readOnly: busy,
                      onChanged: (_) => controller.errorMessage.value = '',
                      decoration: InputDecoration(
                        hintText: 'nama@kampus.ac.id',
                        prefixIcon: compact
                            ? null
                            : Icon(
                                Icons.alternate_email_rounded,
                                size: 20,
                                color: colors.onSurfaceVariant,
                              ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          borderSide: BorderSide(color: colors.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Kata sandi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: headingColor,
                    ),
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
                      readOnly: busy,
                      onChanged: (_) => controller.errorMessage.value = '',
                      onSubmitted: (_) {
                        if (!controller.isBusy) {
                          controller.login();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Masukkan kata sandi',
                        prefixIcon: compact
                            ? null
                            : Icon(
                                Icons.lock_outline_rounded,
                                size: 20,
                                color: colors.onSurfaceVariant,
                              ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          borderSide: BorderSide(color: colors.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: colors.error, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 20,
                            color: colors.onErrorContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                error,
                                style: TextStyle(
                                  color: colors.onErrorContainer,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: busy ? null : controller.login,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: colors.surfaceContainerHigh,
                      disabledForegroundColor: colors.onSurface,
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
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
                  const SizedBox(height: 16),
                  const AuthDivider(label: 'atau'),
                  const SizedBox(height: 16),
                  GoogleAuthButton(
                    key: const ValueKey('google-login-button'),
                    label: 'Masuk dengan Google',
                    isLoading: googleLoading,
                    disabled: loading,
                    compact: compact,
                    onPressed: controller.loginWithGoogle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  'Belum punya akun?',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () => Get.toNamed(Routes.REGISTER),
                  child: const Text(
                    'Daftar Mahasiswa',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const LegalLinks(),
          ],
        ),
      );
    });
  }
}
