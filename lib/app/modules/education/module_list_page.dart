import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../routes/app_pages.dart';
import 'education_controller.dart';
import 'widgets/module_banner.dart';

/// Halaman Daftar Modul Pembelajaran (Route Standalone).
/// Menerapkan antislop-layoutmobile dan flutter-build-responsive-layout:
/// - Tap target minimum 48px pada setiap interaksi.
/// - Responsive constraint (maxWidth: 720px).
/// - Ringkasan statistik modul di bagian atas.
class ModuleListPage extends GetView<EducationController> {
  const ModuleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Modul Edukasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final modules = controller.modules;
        final totalModules = modules.length;
        final completedModules = modules.where((m) => m.progressPercentage >= 100).length;
        final int overallProgress = totalModules > 0
            ? (modules.fold<int>(0, (sum, m) => sum + m.progressPercentage) / totalModules).round()
            : 0;

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          isEmpty: modules.isEmpty,
          emptyMessage: 'Belum ada modul edukasi yang tersedia.',
          emptyIcon: Icons.menu_book_outlined,
          onRetry: controller.fetchModules,
          child: RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => controller.fetchModules(forceRefresh: true),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  children: [
                    // Ringkasan Progres Belajar Keseluruhan
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark ? null : AppTheme.elevatedCardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.school_rounded, color: AppTheme.primary50, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Kemajuan Belajar Anda',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '$overallProgress%',
                                  style: const TextStyle(
                                    color: AppTheme.primary900,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            completedModules == totalModules && totalModules > 0
                                ? 'Luar biasa! Seluruh modul telah berhasil Anda selesaikan.'
                                : 'Telah menyelesaikan $completedModules dari $totalModules modul kesehatan reproduksi.',
                            style: const TextStyle(
                              color: AppTheme.primary50,
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: overallProgress > 0 ? (overallProgress / 100).clamp(0.0, 1.0) : 0.0,
                              backgroundColor: Colors.white.withValues(alpha: 0.22),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary500),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Daftar Modul
                    ...modules.map((module) {
                      final bool isCompleted = module.progressPercentage >= 100;
                      final bool isInProgress = module.progressPercentage > 0 && !isCompleted;

                      Color statusBgColor;
                      Color statusTextColor;
                      String statusText;
                      IconData statusIcon;

                      if (isCompleted) {
                        statusBgColor = isDark ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.successLight;
                        statusTextColor = isDark ? const Color(0xFF34D399) : AppTheme.success;
                        statusText = 'Selesai';
                        statusIcon = Icons.check_circle_rounded;
                      } else if (isInProgress) {
                        statusBgColor = isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50;
                        statusTextColor = isDark ? AppTheme.primary500 : AppTheme.primary700;
                        statusText = '${module.progressPercentage}% Dipelajari';
                        statusIcon = Icons.timelapse_rounded;
                      } else {
                        statusBgColor = isDark ? const Color(0xFF243038) : const Color(0xFFF1F5F9);
                        statusTextColor = isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;
                        statusText = 'Belum Dimulai';
                        statusIcon = Icons.play_circle_outline_rounded;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                            width: 1.0,
                          ),
                          boxShadow: isDark ? null : AppTheme.cardShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            onTap: () {
                              controller.fetchModuleDetail(module.id);
                              Get.toNamed(Routes.EDUCATION_MODULE_DETAIL, arguments: module.id)?.then((_) {
                                controller.fetchModules(forceRefresh: true);
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Banner Visual Modul
                                ModuleBanner(
                                  bannerImage: module.bannerImage,
                                  moduleNumber: module.moduleNumber,
                                  title: module.title,
                                  height: 125,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'MODUL ${module.moduleNumber}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? AppTheme.primary500 : AppTheme.primary900,
                                            fontSize: 11.5,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: statusBgColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(statusIcon, size: 14, color: statusTextColor),
                                            const SizedBox(width: 5),
                                            Text(
                                              statusText,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: statusTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    module.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: module.progressPercentage > 0 ? (module.progressPercentage / 100).clamp(0.0, 1.0) : 0.0,
                                      backgroundColor: isDark ? const Color(0xFF2C3840) : const Color(0xFFF1F5F9),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isCompleted ? AppTheme.success : (isDark ? AppTheme.primary500 : AppTheme.primary700),
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.menu_book_rounded,
                                            size: 16,
                                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${module.completedTopics} dari ${module.totalTopics} Submateri',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            isCompleted ? 'Review Modul' : (isInProgress ? 'Lanjutkan' : 'Buka Modul'),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? AppTheme.primary500 : AppTheme.primary700,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 16,
                                            color: isDark ? AppTheme.primary500 : AppTheme.primary700,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
