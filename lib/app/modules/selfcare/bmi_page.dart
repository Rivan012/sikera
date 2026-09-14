import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/selfcare_model.dart';
import 'selfcare_controller.dart';

class BmiPage extends GetView<SelfcareController> {
  const BmiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Indeks Massa Tubuh'),
        actions: [
          IconButton(
            onPressed: () => controller.fetchBmiHistory(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Riwayat',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Masukkan Data Pengukuran',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Perhitungan IMT otomatis tersimpan dan menghasilkan rekomendasi medis bagi kesehatan reproduksi Anda.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controller.weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Berat Badan (kg)',
                            hintText: 'Contoh: 54.0',
                            prefixIcon: Icon(Icons.monitor_weight_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller.heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Tinggi Badan (cm)',
                            hintText: 'Contoh: 162.0',
                            prefixIcon: Icon(Icons.height_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.calculateBmi,
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Hitung & Simpan Status Gizi (IMT)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Calculation Result Card
                Obx(() {
                  final result = controller.bmiResult.value;
                  if (result == null) return const SizedBox.shrink();

                  final category = result.category ?? 'Normal';
                  Color badgeColor = Colors.teal.shade700;
                  Color badgeBg = Colors.teal.withValues(alpha: 0.15);

                  final lowerCat = category.toLowerCase();
                  if (lowerCat.contains('kurang')) {
                    badgeColor = Colors.amber.shade900;
                    badgeBg = Colors.amber.withValues(alpha: 0.18);
                  } else if (lowerCat.contains('lebih') ||
                      lowerCat.contains('overweight') ||
                      lowerCat.contains('obes')) {
                    badgeColor = AppTheme.statusError;
                    badgeBg = AppTheme.statusError.withValues(alpha: 0.15);
                  }

                  return Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.borderDark
                            : AppTheme.primary200,
                        width: 1.2,
                      ),
                      boxShadow: isDark ? null : AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.softAccentSurfaceDark
                                    : AppTheme.primary50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.health_and_safety_rounded,
                                color: isDark
                                    ? AppTheme.primary500
                                    : AppTheme.primary700,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hasil Analisis Status Gizi',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppTheme.textPrimaryDark
                                          : AppTheme.primary900,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        'IMT: ${result.bmiScore?.toStringAsFixed(1) ?? '-'} kg/m²',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppTheme.primary200
                                              : AppTheme.primary700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: badgeBg,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: badgeColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 14),

                        // Medical Advice Box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.elevatedSurfaceDark
                                : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.borderDark
                                  : const Color(0xFFBBF7D0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.medical_information_rounded,
                                    size: 18,
                                    color: isDark
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF16A34A),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rekomendasi Medis Terkait Gizi & Reproduksi:',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                result.advice != null &&
                                        result.advice!.isNotEmpty
                                    ? result.advice!
                                    : 'Pertahankan pola hidup sehat, asupan gizi seimbang, dan hidrasi yang cukup untuk mendukung kestabilan siklus menstruasi dan fungsi organ reproduksi.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: isDark
                                      ? AppTheme.textPrimaryDark
                                      : const Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Pengukuran IMT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.primary900,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${controller.bmiHistory.length} Catatan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Obx(() {
                  if (controller.isBmiHistoryLoading.value &&
                      controller.bmiHistory.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                          color: AppTheme.primary700,
                        ),
                      ),
                    );
                  }

                  final history = controller.bmiHistory;
                  if (history.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.surfaceDark
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.borderDark
                              : AppTheme.borderLight,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.monitor_weight_outlined,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada riwayat pengukuran IMT.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _buildBmiHistoryTile(context, item, isDark);
                    },
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBmiHistoryTile(
    BuildContext context,
    BmiRecordModel item,
    bool isDark,
  ) {
    final cat = item.category ?? 'Normal';
    Color catColor = Colors.teal.shade700;
    Color catBg = Colors.teal.withValues(alpha: 0.15);

    final lower = cat.toLowerCase();
    if (lower.contains('kurang')) {
      catColor = Colors.amber.shade900;
      catBg = Colors.amber.withValues(alpha: 0.18);
    } else if (lower.contains('lebih') ||
        lower.contains('overweight') ||
        lower.contains('obes')) {
      catColor = AppTheme.statusError;
      catBg = AppTheme.statusError.withValues(alpha: 0.15);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'IMT: ${item.bmiScore?.toStringAsFixed(1) ?? '-'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: catBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: catColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.createdAt != null)
                Text(
                  item.createdAt!.split('T').first,
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'BB: ${item.weightKg.toStringAsFixed(1)} kg • TB: ${item.heightCm.toStringAsFixed(0)} cm',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          if (item.advice != null && item.advice!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Saran: ${item.advice}',
              style: TextStyle(
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? const Color(0xFF6EE7B7)
                    : const Color(0xFF15803D),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
