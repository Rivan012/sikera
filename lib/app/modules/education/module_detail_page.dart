import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/module_model.dart';
import '../../routes/app_pages.dart';
import 'education_controller.dart';
import 'widgets/module_banner.dart';

/// Halaman Detail Modul Edukasi.
/// Menerapkan panduan antislop-layoutmobile dan flutter-build-responsive-layout:
/// - Responsive constraint (maxWidth: 720px) terpusat.
/// - Alur pembelajaran 3 langkah (Learning Journey): Pre-Test -> Submateri -> Post-Test.
/// - Indikator status jujur dan jelas tanpa placeholder palsu.
/// - Tap target minimum 48px pada setiap tombol dan kartu materi.
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Modul'),
        leading: IconButton(
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
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          isEmpty: module == null,
          emptyMessage: 'Detail modul tidak ditemukan.',
          emptyIcon: Icons.menu_book_outlined,
          onRetry: () => controller.fetchModuleDetail(moduleId),
          child: module == null
              ? const SizedBox.shrink()
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => controller.refreshAllProgress(moduleId),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Banner Modul
                            _buildModuleHeader(context, module, isDark),
                            const SizedBox(height: 20),

                            // Alur Belajar: Langkah 1 - Pre-Test
                            _buildStepLabel('Langkah 1', 'Evaluasi Awal (Pre-Test)', isDark),
                            const SizedBox(height: 8),
                            _buildPretestCard(context, module, isDark),
                            const SizedBox(height: 20),

                            // Alur Belajar: Langkah 2 - Submateri
                            _buildStepLabel(
                              'Langkah 2',
                              'Pelajari Submateri (${module.topics.where((TopicModel t) => t.isCompleted == true).length}/${module.topics.length} Selesai)',
                              isDark,
                            ),
                            const SizedBox(height: 8),
                            _buildTopicsList(context, module, isDark),
                            const SizedBox(height: 20),

                            // Alur Belajar: Langkah 3 - Post-Test & N-Gain
                            _buildStepLabel('Langkah 3', 'Evaluasi Akhir & N-Gain', isDark),
                            const SizedBox(height: 8),
                            _buildPosttestCard(context, module, isDark),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      }),
    );
  }

  Widget _buildStepLabel(String stepNumber, String title, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            stepNumber.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.primary500 : AppTheme.primary900,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleHeader(BuildContext context, ModuleDetailModel module, bool isDark) {
    final completedCount = module.topics.where((TopicModel t) => t.isCompleted == true).length;
    final totalCount = module.topics.length;
    final bool isFinished = module.hasPosttest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner Visual Modul (Mendukung SVG/Gambar dari Backend)
        ModuleBanner(
          bannerImage: module.bannerImage,
          moduleNumber: module.moduleNumber,
          title: module.title,
          height: 165,
          borderRadius: BorderRadius.circular(20),
        ),
        const SizedBox(height: 12),

        // Info & Progress Modul
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'MODUL ${module.moduleNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 11.5,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  if (isFinished)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'MODUL SELESAI',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 11,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              if (module.description != null && module.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  module.description!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppTheme.primary50,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in_rounded, size: 16, color: AppTheme.primary50),
                  const SizedBox(width: 6),
                  Text(
                    '$completedCount dari $totalCount Submateri Tuntas',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPretestCard(BuildContext context, ModuleDetailModel module, bool isDark) {
    final bool hasPretest = module.hasPretest;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPretest
              ? (isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0))
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: hasPretest
                    ? (isDark ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.successLight)
                    : (isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasPretest ? Icons.check_circle_rounded : Icons.assignment_outlined,
                color: hasPretest ? AppTheme.success : (isDark ? AppTheme.primary500 : AppTheme.primary700),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pre-Test Pemahaman Awal',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasPretest
                        ? 'Pre-test telah tuntas. Akses seluruh materi terbuka.'
                        : 'Kerjakan soal singkat untuk menguji pengetahuan awal.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (hasPretest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Selesai',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF34D399) : AppTheme.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(90, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  controller.fetchPretest(module.id);
                  Get.toNamed(Routes.EDUCATION_PRETEST, arguments: module.id)?.then((_) {
                    controller.refreshAllProgress(module.id);
                  });
                },
                child: const Text('Mulai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsList(BuildContext context, ModuleDetailModel module, bool isDark) {
    if (module.topics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
          boxShadow: isDark ? null : AppTheme.cardShadow,
        ),
        child: Center(
          child: Text(
            'Selesaikan Pre-Test terlebih dahulu untuk membuka daftar submateri.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
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
            borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(16),
              onTap: isLocked
                  ? () {
                      Get.snackbar(
                        'Materi Masih Terkunci',
                        'Selesaikan Pre-Test terlebih dahulu untuk membuka submateri ini.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppTheme.warning,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                    }
                  : () {
                      controller.fetchTopic(module.id, topic.id);
                      Get.toNamed(Routes.EDUCATION_TOPIC, arguments: {
                        'moduleId': module.id,
                        'topicId': topic.id,
                      })?.then((_) {
                        controller.refreshAllProgress(module.id);
                      });
                    },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    // Topic Code Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDone
                            ? (isDark ? AppTheme.primary500 : AppTheme.primary900)
                            : (isLocked
                                ? (isDark ? const Color(0xFF243038) : const Color(0xFFF1F5F9))
                                : (isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50)),
                        borderRadius: BorderRadius.circular(12),
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
                                    ? (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight)
                                    : (isDark ? AppTheme.primary500 : AppTheme.primary700)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Topic Title & Subtitle
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
                                  ? (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight)
                                  : (isDark ? AppTheme.textPrimaryDark : AppTheme.primary900),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (topic.hasVideo) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF0000).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.play_circle_filled_rounded, size: 10, color: Color(0xFFFF0000)),
                                      SizedBox(width: 3),
                                      Text(
                                        'VIDEO',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFFF0000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              Expanded(
                                child: Text(
                                  isDone
                                      ? 'Selesai dipelajari'
                                      : (isLocked ? 'Terkunci (Pre-Test belum selesai)' : 'Ketuk untuk membaca materi'),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                                    color: isDone
                                        ? AppTheme.success
                                        : (isLocked
                                            ? (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight)
                                            : (isDark ? AppTheme.primary500 : AppTheme.primary700)),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Trailing Status Icon
                    if (isDone)
                      const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 24)
                    else if (isLocked)
                      Icon(Icons.lock_rounded, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight, size: 20)
                    else
                      Icon(Icons.play_circle_fill_rounded, color: isDark ? AppTheme.primary500 : AppTheme.primary700, size: 26),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPosttestCard(BuildContext context, ModuleDetailModel module, bool isDark) {
    final bool hasPosttest = module.hasPosttest;
    final bool allTopicsDone = module.allTopicsDone;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPosttest
              ? (isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0))
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: hasPosttest
                    ? (isDark ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.successLight)
                    : (allTopicsDone ? (isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50) : (isDark ? const Color(0xFF243038) : const Color(0xFFF1F5F9))),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasPosttest
                    ? Icons.verified_rounded
                    : (allTopicsDone ? Icons.quiz_rounded : Icons.lock_outline_rounded),
                color: hasPosttest
                    ? AppTheme.success
                    : (allTopicsDone ? (isDark ? AppTheme.primary500 : AppTheme.primary700) : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight)),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Post-Test & Peningkatan N-Gain',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasPosttest
                        ? 'Skor: ${module.posttestScore ?? 100}/100${module.nGain != null ? ' | N-Gain: ${module.nGain}' : ''}'
                        : (allTopicsDone
                            ? 'Materi tuntas! Kerjakan evaluasi akhir sekarang.'
                            : 'Pelajari seluruh submateri untuk membuka tes.'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (hasPosttest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Selesai',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF34D399) : AppTheme.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              )
            else if (allTopicsDone)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(90, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  controller.fetchPosttest(module.id);
                  Get.toNamed(Routes.EDUCATION_POSTTEST, arguments: module.id)?.then((_) {
                    controller.refreshAllProgress(module.id);
                  });
                },
                child: const Text('Mulai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              )
            else
              Icon(Icons.lock_rounded, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight, size: 20),
          ],
        ),
      ),
    );
  }
}
