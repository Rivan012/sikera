import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../routes/app_pages.dart';
import 'selfcare_controller.dart';
import 'period_widgets.dart';

class SelfcareTab extends GetView<SelfcareController> {
  const SelfcareTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Self-Care & Pemantauan'),
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      body: Obx(() {
        final summary = controller.summaryData.value;
        final latestPeriod =
            summary?['latest_period'] ??
            summary?['period_tracker']?['latest_period'] ??
            summary?['period_tracker']?['latest_record'] ??
            (controller.periodHistory.isNotEmpty
                ? controller.periodHistory.first.toJson()
                : null);
        final latestBmi =
            summary?['latest_bmi'] ?? summary?['bmi_tracker']?['latest_bmi'];

        return StateView(
          isLoading: controller.isLoading.value,
          loadingMessage: 'Memuat catatan kesehatan...',
          errorMessage: controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : null,
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
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  children: [
                    Text(
                      'Pantau kesehatanmu',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Simpan catatan tubuh dan baca panduan perawatan kesehatan reproduksi.',
                      style: TextStyle(
                        color: periodSecondary(context),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (controller.isFemale.value)
                      _buildPeriodCard(context, latestPeriod),
                    _buildBmiCard(context, latestBmi),
                    const SizedBox(height: 16),
                    Text(
                      'Panduan perawatan',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildGuideTile(
                      context,
                      title: 'Karakteristik haid',
                      subtitle: 'Pelajari warna darah dan karakteristik haid.',
                      onTap: () {
                        controller.fetchBloodGuides();
                        Get.toNamed(Routes.SELFCARE_BLOOD_GUIDE);
                      },
                    ),
                    const Divider(height: 1),
                    _buildGuideTile(
                      context,
                      title: 'Kebersihan reproduksi',
                      subtitle:
                          'Baca langkah perawatan kebersihan sehari-hari.',
                      onTap: () {
                        controller.fetchHygieneGuides();
                        Get.toNamed(Routes.SELFCARE_HYGIENE_GUIDE);
                      },
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

  Widget _buildPeriodCard(BuildContext context, dynamic latestPeriod) {
    final prediction = controller.periodPredictions.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PeriodSection(
          title: 'Pemantauan siklus haid',
          description: latestPeriod == null
              ? 'Mulai dari catatan hari pertama haidmu.'
              : 'Catatan terakhir: ${periodDate(latestPeriod['start_date']?.toString())}',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => Get.toNamed(Routes.SELFCARE_PERIOD),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Catat haid'),
              ),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () =>
                    Get.toNamed(Routes.SELFCARE_PERIOD, arguments: {'tab': 2}),
                child: const Text('Riwayat'),
              ),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () =>
                    Get.toNamed(Routes.SELFCARE_PERIOD, arguments: {'tab': 3}),
                child: const Text('Simulasi'),
              ),
            ],
          ),
        ),
        if (controller.isPredictionLoading.value)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: LinearProgressIndicator(
              semanticsLabel: 'Memuat perkiraan siklus haid',
            ),
          ),
        if (controller.predictionError.value.isNotEmpty)
          PeriodNotice(
            message: controller.predictionError.value,
            error: true,
            onRetry: controller.fetchPeriodPrediction,
          ),
        if (prediction != null) PeriodPredictionCard(prediction: prediction),
      ],
    );
  }

  Widget _buildBmiCard(BuildContext context, dynamic latestBmi) {
    final bmiValue = latestBmi?['bmi_value'] ?? latestBmi?['bmi_score'];
    final String? category = latestBmi?['category'];
    final String? advice =
        latestBmi?['advice'] ?? controller.bmiResult.value?.advice;

    return PeriodSection(
      title: 'Indeks massa tubuh (IMT)',
      description: latestBmi == null
          ? 'Belum ada hasil IMT. Masukkan tinggi dan berat badan untuk mulai mencatat.'
          : 'Hasil perhitungan terakhir',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (latestBmi != null) ...[
            Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${bmiValue ?? '-'} kg/m²',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (category != null && category.isNotEmpty)
                  Text(
                    category,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
              ],
            ),
            if (advice != null && advice.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                advice,
                style: TextStyle(
                  color: periodSecondary(context),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
          OutlinedButton(
            onPressed: () => Get.toNamed(Routes.SELFCARE_BMI),
            child: const Text('Hitung IMT'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: periodSecondary(context),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.chevron_right, color: periodSecondary(context)),
            ],
          ),
        ),
      ),
    );
  }
}
