import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_pages.dart';

/// Halaman pembuka SIKERA sebelum mengarahkan pengguna ke onboarding,
/// halaman masuk, persetujuan dokumen, atau beranda aktif.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  bool _motionConfigured = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleIn = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _navigateAfterDelay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_motionConfigured) {
      _motionConfigured = true;
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1.0;
      } else {
        _controller.forward();
      }
    }
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final destination = StorageService.hasToken
        ? (StorageService.termsPrivacyAccepted
              ? Routes.HOME
              : Routes.TERMS_PRIVACY_CONSENT)
        : StorageService.onboardingCompleted
        ? Routes.LOGIN
        : Routes.ONBOARDING;
    Get.offAllNamed(destination);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimaryDark : AppTheme.primary900;
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final accentColor = isDark ? AppTheme.primary500 : AppTheme.primary700;
    final haloSurface = isDark
        ? AppTheme.softAccentSurfaceDark
        : AppTheme.primary50;
    final haloBorder = isDark
        ? AppTheme.borderDark
        : AppTheme.strongBorderLight;
    final emblemSurface = isDark
        ? AppTheme.pocketSurfaceLight
        : AppTheme.surfaceLight;

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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: bgColor),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 620;
                final emblemSize = math.min(
                  compact ? 140.0 : 184.0,
                  math.max(112.0, constraints.maxWidth * 0.48),
                );
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: compact ? 16 : 28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(
                        0,
                        constraints.maxHeight - (compact ? 32 : 56),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: ScaleTransition(
                        scale: _scaleIn,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Edukasi & Kesehatan Kampus',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryColor,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 28,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusPill,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: compact ? 20 : 32,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 340,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: haloSurface,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: haloBorder,
                                          width: 1,
                                        ),
                                      ),
                                      child: Container(
                                        width: emblemSize,
                                        height: emblemSize,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: emblemSurface,
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radius2Xl,
                                          ),
                                          boxShadow: isDark
                                              ? null
                                              : AppTheme.cardShadow,
                                        ),
                                        child: Image.asset(
                                          'assets/logo/sikera_logo_putih.png',
                                          fit: BoxFit.contain,
                                          semanticLabel: 'Logo SIKERA',
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: compact ? 20 : 28),
                                    Text(
                                      'Sistem Informasi\nKesehatan Remaja',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                        height: 1.28,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Ruang belajar kesehatan reproduksi yang aman, terpercaya, dan ramah mahasiswa.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: secondaryColor,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Semantics(
                              liveRegion: true,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 136,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusPill,
                                      ),
                                      child: LinearProgressIndicator(
                                        value: 1.0,
                                        minHeight: 4,
                                        backgroundColor: haloSurface,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              accentColor,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Menyiapkan ruang belajar...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
