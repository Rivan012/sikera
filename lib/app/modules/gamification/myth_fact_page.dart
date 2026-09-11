import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import 'gamification_controller.dart';

/// Halaman Mitos vs Fakta Kesehatan Reproduksi.
/// Menerapkan antislop-layoutmobile dan flutter-build-responsive-layout:
/// - Responsive constraint (maxWidth: 720px).
/// - Kartu pernyataan dengan tipografi kontras dan terpusat.
/// - Tombol pilihan FAKTA vs MITOS dengan tap target > 48px.
class MythFactPage extends GetView<GamificationController> {
  const MythFactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mitos vs Fakta Kaspro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final card = controller.mythFactCard.value;

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          isEmpty: card == null,
          emptyMessage: 'Kartu mitos vs fakta belum tersedia.',
          emptyIcon: Icons.compare_arrows_rounded,
          onRetry: controller.fetchMythFact,
          child: card == null
              ? const SizedBox.shrink()
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Kartu Pernyataan
                          Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
                              border: Border.all(
                                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                width: 1.2,
                              ),
                              boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                                    borderRadius: BorderRadius.circular(AppTheme.jagoPillRadius),
                                  ),
                                  child: Text(
                                    card.category.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      color: isDark ? AppTheme.primary500 : AppTheme.primary700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.help_outline_rounded, color: isDark ? AppTheme.primary500 : AppTheme.primary700, size: 30),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  '"${card.statement}"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    height: 1.45,
                                    letterSpacing: -0.2,
                                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 52,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDark ? AppTheme.primary500 : AppTheme.primary700,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.jagoPillRadius)),
                                            elevation: 0,
                                          ),
                                          onPressed: () => controller.answerMythFact('fact'),
                                          child: const Text('FAKTA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: SizedBox(
                                        height: 52,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.statusError,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.jagoPillRadius)),
                                            elevation: 0,
                                          ),
                                          onPressed: () => controller.answerMythFact('myth'),
                                          child: const Text('MITOS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Hasil Penjelasan
                          if (controller.mythFactExplanation.value != null) ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.statusSuccess.withValues(alpha: 0.15) : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
                                border: Border.all(
                                  color: isDark ? AppTheme.statusSuccess.withValues(alpha: 0.3) : const Color(0xFFA7F3D0),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.verified_rounded, color: AppTheme.statusSuccess, size: 22),
                                      SizedBox(width: 8),
                                      Text(
                                        'Fakta Sebenarnya',
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
                                    controller.mythFactExplanation.value!,
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
