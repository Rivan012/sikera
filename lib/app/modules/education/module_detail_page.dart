import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/module_model.dart';
import '../../routes/app_pages.dart';
import 'education_controller.dart';
import 'widgets/global_posttest_card.dart';
import 'widgets/module_banner.dart';

class ModuleDetailPage extends StatefulWidget {
  const ModuleDetailPage({super.key});

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  final EducationController controller = Get.find<EducationController>();
  late int moduleId;

  @override
  void initState() {
    super.initState();
    moduleId = (Get.arguments is int)
        ? Get.arguments as int
        : (Get.arguments is Map ? (Get.arguments['moduleId'] ?? 1) : 1);
    controller.fetchModuleDetail(moduleId);
  }

  void _startPretest(int id) {
    controller.fetchPretest(id);
    Get.toNamed(Routes.EDUCATION_PRETEST, arguments: id)?.then((_) {
      controller.refreshAllProgress(id);
    });
  }

  void _startGlobalPosttest() {
    controller.fetchGlobalPosttest();
    Get.toNamed(
      Routes.EDUCATION_POSTTEST,
      arguments: const {'global': true},
    )?.then((_) {
      controller.refreshAllProgress(moduleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Modul'),
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            controller.refreshAllProgress(moduleId);
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        final module = controller.currentModule.value;

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : null,
          isEmpty: module == null,
          emptyMessage: 'Detail modul tidak ditemukan.',
          emptyIcon: Icons.menu_book_outlined,
          onRetry: () => controller.fetchModuleDetail(moduleId),
          child: module == null
              ? const SizedBox.shrink()
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => controller.refreshAllProgress(moduleId),
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          child: !module.hasPretest
                              ? _buildPretestGate(context, module, isDark)
                              : _buildUnlockedModuleContent(
                                  context,
                                  module,
                                  isDark,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      }),
    );
  }

  Widget _buildPretestGate(
    BuildContext context,
    ModuleDetailModel module,
    bool isDark,
  ) {
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final surfaceColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final accentColor = isDark ? AppTheme.primary200 : AppTheme.primary700;
    final topicCount = module.topics.length;

    return Column(
      key: const ValueKey('pretest-gate-view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Modul ${module.moduleNumber}: ${module.title}',
          image: true,
          excludeSemantics: true,
          child: ModuleBanner(
            moduleId: module.id,
            bannerImage: module.bannerImage,
            moduleNumber: module.moduleNumber,
            title: module.title,
            useModuleFallback: true,
            height: 165,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Modul ${module.moduleNumber}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          module.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: headingColor,
          ),
        ),
        if (module.description != null && module.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            module.description!,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: secondaryColor,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: isDark ? null : AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.softAccentSurfaceDark
                          : AppTheme.primary50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pre-Test Sebelum Mengakses Materi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: headingColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          topicCount > 0
                              ? 'Kerjakan Pre-Test Modul ${module.moduleNumber} terlebih dahulu untuk membuka akses ke $topicCount submateri pada modul ini.'
                              : 'Kerjakan Pre-Test Modul ${module.moduleNumber} terlebih dahulu sebelum mengakses materi pada modul ini.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.elevatedSurfaceDark
                      : AppTheme.pocketSurfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: accentColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Submateri akan langsung terbuka setelah Pre-Test dikumpulkan.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                key: const ValueKey('pretest-gate-start-btn'),
                onPressed: () => _startPretest(module.id),
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: Text(
                  'Mulai Pre-Test Modul ${module.moduleNumber}',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                key: const ValueKey('pretest-gate-back-btn'),
                onPressed: () => Get.back(),
                child: const Text(
                  'Kembali ke Daftar Modul',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildUnlockedModuleContent(
    BuildContext context,
    ModuleDetailModel module,
    bool isDark,
  ) {
    final completedCount = module.topics
        .where((TopicModel t) => t.isCompleted == true)
        .length;
    final posttestStatus = controller.effectivePosttestStatus;
    final now = controller.nowProvider();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildModuleHeader(module, isDark),
        const SizedBox(height: 20),
        _buildStepLabel(
          'Daftar Submateri',
          '$completedCount/${module.topics.length} Selesai',
          isDark,
        ),
        const SizedBox(height: 10),
        _buildTopicsList(context, module, isDark),
        const SizedBox(height: 20),
        _buildStepLabel(
          'Evaluasi Akhir',
          'Post-Test (${posttestStatus.delayDays} Hari Setelah Semua Modul)',
          isDark,
        ),
        const SizedBox(height: 10),
        GlobalPosttestCard(
          status: posttestStatus,
          now: now,
          onStartPosttest: _startGlobalPosttest,
          onViewModules: () => Get.back(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStepLabel(String stepNumber, String title, bool isDark) {
    return Text(
      '$stepNumber · $title',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
      ),
    );
  }

  Widget _buildModuleHeader(ModuleDetailModel module, bool isDark) {
    final completedCount = module.topics
        .where((TopicModel t) => t.isCompleted == true)
        .length;
    final totalCount = module.topics.length;
    final bool isModuleTopicsDone =
        totalCount > 0 && completedCount >= totalCount;
    final statusColor = isDark ? const Color(0xFF4ADE80) : AppTheme.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Modul ${module.moduleNumber}: ${module.title}',
          image: true,
          excludeSemantics: true,
          child: ModuleBanner(
            moduleId: module.id,
            bannerImage: module.bannerImage,
            moduleNumber: module.moduleNumber,
            title: module.title,
            useModuleFallback: true,
            height: 165,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (module.description != null &&
                  module.description!.isNotEmpty) ...[
                Text(
                  module.description!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pre-Test modul tuntas, akses materi terbuka',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 18,
                    color: isDark ? AppTheme.primary500 : AppTheme.primary700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$completedCount dari $totalCount submateri tuntas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.primary900,
                      ),
                    ),
                  ),
                ],
              ),
              if (isModuleTopicsDone) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Semua submateri modul ini selesai',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsList(
    BuildContext context,
    ModuleDetailModel module,
    bool isDark,
  ) {
    if (module.topics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
          boxShadow: isDark ? null : AppTheme.cardShadow,
        ),
        child: Center(
          child: Text(
            'Belum ada submateri yang tersedia pada modul ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    return Column(
      children: module.topics.map<Widget>((topic) {
        final bool isDone = topic.isCompleted;
        final bool isLocked = topic.isLocked;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: isDone
                  ? (isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0))
                  : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
              width: 1.2,
            ),
            boxShadow: isDark ? null : AppTheme.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              onTap: isLocked
                  ? () {
                      Get.snackbar(
                        'Materi Masih Terkunci',
                        'Selesaikan submateri sebelumnya untuk membuka materi ini.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppTheme.warning,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                    }
                  : () {
                      controller.fetchTopic(module.id, topic.id);
                      Get.toNamed(
                        Routes.EDUCATION_TOPIC,
                        arguments: {'moduleId': module.id, 'topicId': topic.id},
                      )?.then((_) {
                        controller.refreshAllProgress(module.id);
                      });
                    },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDone
                            ? (isDark
                                  ? AppTheme.primary500
                                  : AppTheme.primary900)
                            : (isLocked
                                  ? (isDark
                                        ? const Color(0xFF243038)
                                        : const Color(0xFFF1F5F9))
                                  : (isDark
                                        ? AppTheme.softAccentSurfaceDark
                                        : AppTheme.primary50)),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Center(
                        child: Text(
                          topic.topicCode,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: isDone
                                ? Colors.white
                                : (isLocked
                                      ? (isDark
                                            ? AppTheme.textMutedDark
                                            : AppTheme.textMutedLight)
                                      : (isDark
                                            ? AppTheme.primary500
                                            : AppTheme.primary700)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isLocked
                                  ? (isDark
                                        ? AppTheme.textMutedDark
                                        : AppTheme.textMutedLight)
                                  : (isDark
                                        ? AppTheme.textPrimaryDark
                                        : AppTheme.primary900),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Wrap(
                            spacing: 6,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (topic.hasVideo)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline_rounded,
                                      size: 14,
                                      color: isDark
                                          ? AppTheme.primary200
                                          : AppTheme.primary700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Video',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppTheme.primary200
                                            : AppTheme.primary700,
                                      ),
                                    ),
                                  ],
                                ),
                              Text(
                                isDone
                                    ? 'Selesai dipelajari'
                                    : (isLocked
                                          ? 'Terkunci'
                                          : 'Ketuk untuk membaca materi'),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isDone
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isDone
                                      ? (isDark
                                            ? const Color(0xFF4ADE80)
                                            : AppTheme.success)
                                      : (isLocked
                                            ? (isDark
                                                  ? AppTheme.textMutedDark
                                                  : AppTheme.textMutedLight)
                                            : (isDark
                                                  ? AppTheme.primary500
                                                  : AppTheme.primary700)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isDone)
                      Icon(
                        Icons.check_circle_rounded,
                        color: isDark
                            ? const Color(0xFF4ADE80)
                            : AppTheme.success,
                        size: 24,
                      )
                    else if (isLocked)
                      Icon(
                        Icons.lock_rounded,
                        color: isDark
                            ? AppTheme.textMutedDark
                            : AppTheme.textMutedLight,
                        size: 20,
                      )
                    else
                      Icon(
                        Icons.play_circle_fill_rounded,
                        color: isDark
                            ? AppTheme.primary500
                            : AppTheme.primary700,
                        size: 26,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
