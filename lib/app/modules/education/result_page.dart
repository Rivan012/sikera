import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_pages.dart';
import '../main_nav/main_nav_controller.dart';
import 'education_controller.dart';

class ResultPage extends GetView<EducationController> {
  const ResultPage({super.key});

  void _returnToHome() {
    Get.find<MainNavController>().changeTab(0);
    Get.until((route) => route.settings.name == Routes.HOME);
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is Map ? Get.arguments as Map : {};
    final bool isPretest = args['isPretest'] == true;
    final data = args['data'] is Map ? args['data'] as Map : {};

    final score = data['score'] ?? data['posttest_score'] ?? 0;
    final pretestScore = data['pretest_score'];
    final posttestScore = data['posttest_score'];
    final nGain = data['n_gain_score'];
    final category = data['effectiveness_category']?.toString();
    final pointsEarned = data['points_earned'] ?? 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final pointsColor = isDark
        ? const Color(0xFF4ADE80)
        : AppTheme.statusSuccess;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPretest ? 'Hasil Pre-Test' : 'Hasil Evaluasi Post-Test'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.softAccentSurfaceDark
                          : AppTheme.primary50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isPretest ? 'Skor Pre-Test' : 'Skor Evaluasi Akhir',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppTheme.primary200
                                : AppTheme.primary700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$score / 100',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.primary900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isPretest
                              ? 'Pre-Test Selesai'
                              : 'Modul Telah Diselesaikan',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.primary900,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isPretest
                              ? 'Akses submateri telah dibuka. Silakan pelajari materi yang tersedia.'
                              : 'Anda telah menyelesaikan seluruh materi dan post-test modul ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Detail Nilai Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Nilai Diperoleh',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '$score / 100',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          if (!isPretest && pretestScore != null) ...[
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Nilai Pre-Test',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '$pretestScore / 100',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Nilai Post-Test',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '$posttestScore / 100',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            if (nGain != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Skor N-Gain',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '$nGain (${category ?? '-'})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppTheme.primary200
                                          : AppTheme.primary700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Poin Kaspro Didapat',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '+$pointsEarned Poin',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: pointsColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),

                  ElevatedButton.icon(
                    icon: Icon(
                      isPretest ? Icons.menu_book_rounded : Icons.home_rounded,
                    ),
                    onPressed: () {
                      final int moduleId = args['moduleId'] is int
                          ? args['moduleId'] as int
                          : (int.tryParse(args['moduleId']?.toString() ?? '') ??
                                0);
                      controller.refreshAllProgress(
                        moduleId > 0 ? moduleId : null,
                      );
                      if (isPretest && moduleId > 0) {
                        controller.fetchModuleDetail(moduleId);
                        Get.offNamed(
                          Routes.EDUCATION_MODULE_DETAIL,
                          arguments: moduleId,
                        );
                      } else {
                        _returnToHome();
                      }
                    },
                    label: Text(
                      isPretest
                          ? 'Lanjut ke Materi Modul'
                          : 'Kembali ke Beranda',
                    ),
                  ),
                  if (isPretest) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        controller.refreshAllProgress();
                        _returnToHome();
                      },
                      child: const Text('Kembali ke Beranda'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
