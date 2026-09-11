import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../routes/app_pages.dart';
import 'selfcare_controller.dart';

/// Tab Self-Care & Pemantauan Mandiri Kesehatan Reproduksi.
/// Mengikuti skill antislop-layoutmobile dan flutter-build-responsive-layout:
/// - Responsive constraint (maxWidth: 720px) terpusat.
/// - Kartu pelacak haid & kalkulator IMT yang adaptif dan informatif.
/// - Tap target minimum 48px pada setiap tombol dan kartu navigasi.
/// - 3-State UI lengkap (Loading, Empty, Error) dengan tombol refresh.
class SelfcareTab extends GetView<SelfcareController> {
  const SelfcareTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Self-Care & Pemantauan'),
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      body: Obx(() {
        final summary = controller.summaryData.value;
        final latestPeriod = summary?['latest_period'] ?? summary?['period_tracker']?['latest_period'];
        final latestBmi = summary?['latest_bmi'] ?? summary?['bmi_tracker']?['latest_bmi'];

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          isEmpty: false,
          onRetry: controller.fetchSummary,
          child: RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: controller.fetchSummary,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  children: [
                    // Header Banner
                    _buildIntroBanner(context, isDark),
                    const SizedBox(height: 18),

                    // Siklus Menstruasi (Khusus Mahasiswi)
                    if (controller.isFemale.value) ...[
                      _buildPeriodCard(context, latestPeriod, isDark),
                      const SizedBox(height: 16),
                    ],

                    // Kalkulator IMT
                    _buildBmiCard(context, latestBmi, isDark),
                    const SizedBox(height: 22),

                    // Panduan Edukasi Visual
                    Text(
                      'Panduan Visual Interaktif',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildGuideTile(
                      context,
                      title: 'Panduan Karakteristik Haid',
                      subtitle: 'Kenali indikasi kesehatan reproduksi melalui karakteristik warna darah menstruasi.',
                      icon: Icons.water_drop_rounded,
                      iconBgColor: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                      iconColor: isDark ? AppTheme.primary500 : AppTheme.primary700,
                      isDark: isDark,
                      onTap: () {
                        controller.fetchBloodGuides();
                        Get.toNamed(Routes.SELFCARE_BLOOD_GUIDE);
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildGuideTile(
                      context,
                      title: 'Panduan Higienitas Reproduksi',
                      subtitle: 'Tata cara menjaga kebersihan organ intim dan pencegahan infeksi saluran kemih dan reproduksi.',
                      icon: Icons.sanitizer_rounded,
                      iconBgColor: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                      iconColor: isDark ? AppTheme.primary500 : AppTheme.primary900,
                      isDark: isDark,
                      onTap: () {
                        controller.fetchHygieneGuides();
                        Get.toNamed(Routes.SELFCARE_HYGIENE_GUIDE);
                      },
                    ),
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

  Widget _buildIntroBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
        boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kantong Self-Care & Pemantauan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Pantau siklus bulanan, berat badan ideal, dan pelajari panduan perawatan kebersihan organ reproduksi setiap saat.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppTheme.primary50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(BuildContext context, dynamic latestPeriod, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.pocketSurfaceDark : AppTheme.pocketSurfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: isDark ? AppTheme.primary500 : AppTheme.primary700,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Kantong Siklus Haid',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.primary500 : AppTheme.primary700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(116, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.jagoPillRadius)),
                  elevation: 0,
                ),
                onPressed: () => Get.toNamed(Routes.SELFCARE_PERIOD),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Catat Haid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          if (latestPeriod != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.primary100.withValues(alpha: 0.7),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Mulai Haid',
                      '${latestPeriod['start_date'] ?? '-'}',
                      isDark,
                    ),
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: isDark ? AppTheme.borderDark : AppTheme.primary100,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _buildMetricItem(
                        'Panjang Siklus',
                        '${latestPeriod['cycle_length'] ?? 28} Hari',
                        isDark,
                      ),
                    ),
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: isDark ? AppTheme.borderDark : AppTheme.primary100,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _buildMetricItem(
                        'Nyeri (NRS)',
                        '${latestPeriod['nrs_pain_score'] ?? 0} / 10',
                        isDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Belum ada catatan menstruasi tersimpan. Ketuk tombol Catat Haid untuk mulai mencatat riwayat siklus Anda.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBmiCard(BuildContext context, dynamic latestBmi, bool isDark) {
    String? category = latestBmi?['category'];
    Color categoryBgColor = isDark ? AppTheme.statusSuccess.withValues(alpha: 0.15) : AppTheme.successLight;
    Color categoryTextColor = isDark ? const Color(0xFF34D399) : AppTheme.statusSuccess;

    if (category != null) {
      if (category.toLowerCase().contains('kurang')) {
        categoryBgColor = isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50;
        categoryTextColor = isDark ? AppTheme.primary500 : AppTheme.primary700;
      } else if (category.toLowerCase().contains('lebih') || category.toLowerCase().contains('obes')) {
        categoryBgColor = isDark ? AppTheme.statusError.withValues(alpha: 0.15) : AppTheme.errorLight;
        categoryTextColor = isDark ? const Color(0xFFF87171) : AppTheme.statusError;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.pocketSurfaceDark : AppTheme.pocketSurfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      color: isDark ? AppTheme.primary500 : AppTheme.primary900,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Kantong IMT Ideal',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.primary500 : AppTheme.primary700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(116, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.jagoPillRadius)),
                  elevation: 0,
                ),
                onPressed: () => Get.toNamed(Routes.SELFCARE_BMI),
                icon: const Icon(Icons.speed_rounded, size: 16),
                label: const Text('Hitung IMT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          if (latestBmi != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.primary100.withValues(alpha: 0.7),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Skor IMT Terakhir',
                      '${latestBmi['bmi_score'] ?? '-'} kg/m²',
                      isDark,
                    ),
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: isDark ? AppTheme.borderDark : AppTheme.primary100,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Kategori',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryBgColor,
                              borderRadius: BorderRadius.circular(AppTheme.jagoPillRadius),
                            ),
                            child: Text(
                              category ?? '-',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: categoryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Belum ada hasil perhitungan indeks massa tubuh. Ketuk tombol Hitung IMT untuk memeriksa berat badan ideal Anda.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppTheme.jagoSoftShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_rounded, size: 16, color: isDark ? AppTheme.primary500 : AppTheme.primary700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
