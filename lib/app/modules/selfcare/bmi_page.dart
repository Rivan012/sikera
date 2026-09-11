import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'selfcare_controller.dart';

class BmiPage extends GetView<SelfcareController> {
  const BmiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Indeks Massa Tubuh'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masukkan Ukuran Tubuh',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Berat Badan (kg)',
                        hintText: 'Contoh: 54.0',
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Tinggi Badan (cm)',
                        hintText: 'Contoh: 162.0',
                        prefixIcon: Icon(Icons.height_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.calculateBmi,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Hitung Status Gizi (IMT)'),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final result = controller.bmiResult.value;
              if (result == null) return const SizedBox.shrink();

              final isDark = Theme.of(context).brightness == Brightness.dark;

              return Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primary900.withValues(alpha: 0.35) : AppTheme.primary50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.primary700.withValues(alpha: 0.4) : AppTheme.primary200,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.health_and_safety_rounded, color: isDark ? AppTheme.primary200 : AppTheme.primary700, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Skor IMT Anda: ${result.bmiScore ?? '-'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.primary200 : AppTheme.primary900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kategori: ${result.category ?? 'Normal'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gizi seimbang dan berat badan ideal sangat memengaruhi keteraturan siklus hormon dan kesehatan reproduksi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.primary900,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
