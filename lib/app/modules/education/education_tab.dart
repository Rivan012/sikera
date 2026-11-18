import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/dashboard_model.dart';
import '../../routes/app_pages.dart';
import 'education_controller.dart';
import 'widgets/module_banner.dart';

class EducationTab extends GetView<EducationController> {
  const EducationTab({super.key, this.standalone = false});

  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi'),
        automaticallyImplyLeading: standalone,
      ),
      body: Obx(() {
        final modules = controller.modules;
        final completed = modules
            .where((m) => m.progressPercentage >= 100)
            .length;
        final progress = modules.isEmpty
            ? 0
            : (modules.fold<int>(0, (sum, m) => sum + m.progressPercentage) /
                      modules.length)
                  .round();

        return StateView(
          isLoading: controller.isLoading.value,
          loadingMessage: 'Memuat materi edukasi...',
          errorMessage: controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : null,
          isEmpty: modules.isEmpty,
          emptyMessage: 'Belum ada materi yang tersedia.',
          emptyIcon: Icons.menu_book_outlined,
          onRetry: controller.fetchModules,
          child: RefreshIndicator(
            color: AppTheme.primary700,
            onRefresh: () => controller.fetchModules(forceRefresh: true),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _progressSummary(
                      completed,
                      modules.length,
                      progress,
                      isDark,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pilih materi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.primary900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${modules.length} modul',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (
                          var index = 0;
                          index < modules.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(height: 12),
                          _moduleCard(modules[index], isDark),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _progressSummary(int completed, int total, int progress, bool isDark) {
    final textColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.textPrimaryLight;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.softAccentSurfaceDark
            : AppTheme.softSurfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.strongBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kemajuan belajar',
            style: TextStyle(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '$completed dari $total modul selesai',
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$progress%',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (progress / 100).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: isDark
                  ? AppTheme.borderDark
                  : AppTheme.borderLight,
              valueColor: AlwaysStoppedAnimation(
                isDark ? AppTheme.primary500 : AppTheme.primary700,
              ),
              semanticsLabel: 'Rata-rata kemajuan belajar',
              semanticsValue: '$progress%',
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(DashboardModuleModel module, bool isDark) {
    return Material(
      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: _moduleRow(module, isDark),
      ),
    );
  }

  Widget _moduleRow(DashboardModuleModel module, bool isDark) {
    final progress = module.progressPercentage.clamp(0, 100);
    final completed = progress == 100;
    final started = progress > 0 && !completed;
    final status = completed
        ? 'Selesai'
        : started
        ? 'Sedang dipelajari'
        : 'Belum dimulai';
    final action = completed
        ? 'Baca lagi'
        : started
        ? 'Lanjutkan'
        : 'Buka materi';
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final statusColor = completed
        ? (isDark ? const Color(0xFF4ADE80) : AppTheme.success)
        : secondaryColor;

    return Semantics(
      button: true,
      child: InkWell(
        key: ValueKey('education-module-${module.id}'),
        focusColor: (isDark ? AppTheme.primary200 : AppTheme.primary700)
            .withValues(alpha: 0.16),
        onTap: () {
          controller.fetchModuleDetail(module.id);
          Get.toNamed(
            Routes.EDUCATION_MODULE_DETAIL,
            arguments: module.id,
          )?.then((_) {
            controller.fetchModules(forceRefresh: true);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showBanner =
                  constraints.maxWidth >= 560 &&
                  MediaQuery.textScalerOf(context).scale(14) <= 20 &&
                  module.bannerImage?.trim().isNotEmpty == true;
              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modul ${module.moduleNumber}',
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.title,
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.primary900,
                      fontSize: 18,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${module.completedTopics} dari ${module.totalTopics} submateri',
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (started) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 4,
                        backgroundColor: isDark
                            ? AppTheme.borderDark
                            : AppTheme.borderLight,
                        valueColor: AlwaysStoppedAnimation(
                          isDark ? AppTheme.primary500 : AppTheme.primary700,
                        ),
                        semanticsLabel: 'Kemajuan ${module.title}',
                        semanticsValue: '$progress%',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        action,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.primary200
                              : AppTheme.primary700,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              );
              if (!showBanner) return content;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 24),
                  ExcludeSemantics(
                    child: ModuleBanner(
                      bannerImage: module.bannerImage,
                      moduleNumber: module.moduleNumber,
                      width: 160,
                      height: 90,
                      fit: BoxFit.contain,
                      useModuleFallback: true,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
