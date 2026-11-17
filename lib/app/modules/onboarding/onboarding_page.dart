import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'onboarding_controller.dart';
import 'onboarding_data.dart';
import 'widgets/onboarding_item.dart';
import 'widgets/page_indicator.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme.copyWith(
      primary: dark ? AppTheme.primary200 : AppTheme.primary700,
      onPrimary: dark ? AppTheme.primary900 : Colors.white,
      surface: dark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      onSurface: dark ? AppTheme.textPrimaryDark : AppTheme.primary900,
      onSurfaceVariant: dark
          ? AppTheme.textSecondaryDark
          : AppTheme.textSecondaryLight,
      primaryContainer: dark
          ? AppTheme.softAccentSurfaceDark
          : AppTheme.primary50,
      outline: dark ? AppTheme.borderDark : AppTheme.borderLight,
    );
    return Theme(
      data: Theme.of(context).copyWith(colorScheme: colors),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: colors.surface,
            ),
        child: Scaffold(
          backgroundColor: colors.surface,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Obx(
                          () => Visibility(
                            visible: !controller.isLastPage,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: colors.primary,
                                minimumSize: const Size(64, 48),
                              ),
                              onPressed: controller.isSaving.value
                                  ? null
                                  : controller.complete,
                              child: const Text('Lewati'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: controller.pageController,
                        onPageChanged: (index) =>
                            controller.currentPage.value = index,
                        itemCount: onboardingPages.length,
                        itemBuilder: (_, index) =>
                            OnboardingItem(data: onboardingPages[index]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Obx(
                        () => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PageIndicator(
                              count: onboardingPages.length,
                              activeIndex: controller.currentPage.value,
                            ),
                            const SizedBox(height: 24),
                            if (controller.errorMessage.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.sizeOf(context).height * .18,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Semantics(
                                      liveRegion: true,
                                      child: Text(
                                        controller.errorMessage.value,
                                        style: TextStyle(
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                minimumSize: const Size(double.infinity, 52),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                ),
                              ),
                              onPressed: controller.isSaving.value
                                  ? null
                                  : () => controller.next(
                                      reduceMotion:
                                          MediaQuery.disableAnimationsOf(
                                            context,
                                          ),
                                    ),
                              child: Text(
                                controller.isSaving.value
                                    ? 'Menyimpan…'
                                    : controller.isLastPage
                                    ? 'Masuk ke Aplikasi'
                                    : 'Selanjutnya',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
