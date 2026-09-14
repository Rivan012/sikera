import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../routes/app_pages.dart';
import 'gamification_controller.dart';

/// Halaman Trivia Kaspro Harian.
/// Menerapkan antislop-layoutmobile dan flutter-build-responsive-layout:
/// - Responsive constraint (maxWidth: 720px).
/// - Kartu opsi jawaban dengan tap target > 48px.
/// - Penjelasan edukatif yang ramah dan tidak menghakimi.
class TriviaPage extends GetView<GamificationController> {
  const TriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia Kaspro Harian'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            tooltip: 'Mitos vs Fakta',
            icon: const Icon(Icons.compare_arrows_rounded),
            onPressed: () => Get.toNamed(Routes.MYTH_FACT),
          ),
        ],
      ),
      body: Obx(() {
        final trivia = controller.triviaQuestion.value;

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          isEmpty: trivia == null,
          emptyMessage: 'Soal trivia harian belum tersedia.',
          emptyIcon: Icons.quiz_outlined,
          onRetry: controller.fetchTrivia,
          child: trivia == null
              ? const SizedBox.shrink()
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Banner
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: AppTheme.brandGradient,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary900.withValues(alpha: 0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.quiz_rounded, color: AppTheme.primary50, size: 28),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Uji Pengetahuan Harian',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Jawab kuis singkat kesehatan reproduksi untuk menambah poin dan memperkuat wawasan.',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: AppTheme.primary50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Pertanyaan Trivia
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              border: Border.all(
                                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.primary900.withValues(alpha: 0.4) : AppTheme.primary50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'PERTANYAAN HARI INI',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  trivia.question,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                ...trivia.options.map((opt) {
                                  return Obx(() {
                                    final isSelected = controller.selectedTriviaAnswer.value == opt;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDark ? AppTheme.primary900.withValues(alpha: 0.35) : AppTheme.primary50)
                                            : (isDark ? const Color(0xFF243038) : AppTheme.backgroundLight),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primary700
                                              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                                          width: isSelected ? 1.8 : 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => controller.answerTrivia(opt),
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                                  color: isSelected ? AppTheme.primary700 : AppTheme.textMutedLight,
                                                  size: 22,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    opt,
                                                    style: TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Penjelasan Edukatif
                          if (controller.triviaResultExplanation.value != null) ...[
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.statusSuccess.withValues(alpha: 0.15) : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                border: Border.all(
                                  color: isDark ? AppTheme.statusSuccess.withValues(alpha: 0.3) : const Color(0xFFA7F3D0),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.lightbulb_rounded, color: AppTheme.statusSuccess, size: 22),
                                      SizedBox(width: 8),
                                      Text(
                                        'Penjelasan Ilmiah',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: AppTheme.statusSuccess,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    controller.triviaResultExplanation.value!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.45,
                                      color: isDark ? AppTheme.textPrimaryDark : const Color(0xFF065F46),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
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
