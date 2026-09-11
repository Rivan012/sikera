import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'selfcare_controller.dart';

class PeriodPage extends GetView<SelfcareController> {
  const PeriodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Siklus Haid'),
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
                      'Waktu Siklus',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              controller.startDate.value = picked;
                            }
                          },
                          icon: const Icon(Icons.calendar_today_outlined, size: 18),
                          label: Text(
                            controller.startDate.value != null
                                ? 'Mulai: ${DateFormat('yyyy-MM-dd').format(controller.startDate.value!)}'
                                : 'Pilih Tanggal Mulai Haid',
                          ),
                        )),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.cycleLengthController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Panjang Siklus (Hari)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller.periodDurationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Durasi Haid (Hari)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Karakteristik Aliran',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.flowLevel.value,
                          decoration: const InputDecoration(labelText: 'Volume Darah'),
                          items: const [
                            DropdownMenuItem(value: 'sedikit', child: Text('Sedikit / Flek')),
                            DropdownMenuItem(value: 'sedang', child: Text('Sedang / Normal')),
                            DropdownMenuItem(value: 'banyak', child: Text('Banyak')),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.flowLevel.value = val;
                          },
                        )),
                    const SizedBox(height: 12),
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.flowColor.value,
                          decoration: const InputDecoration(labelText: 'Warna Darah'),
                          items: const [
                            DropdownMenuItem(value: 'Merah Terang', child: Text('Merah Terang (Segar/Sehat)')),
                            DropdownMenuItem(value: 'Merah Tua / Coklat', child: Text('Merah Tua / Coklat')),
                            DropdownMenuItem(value: 'Merah Muda', child: Text('Merah Muda')),
                            DropdownMenuItem(value: 'Oranye / Abu-abu', child: Text('Oranye / Abu-abu (Perlu Diwaspadai)')),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.flowColor.value = val;
                          },
                        )),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tingkat Nyeri (NRS):',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Obx(() => Text(
                              '${controller.painScore.value} / 10',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: controller.painScore.value >= 7
                                    ? AppTheme.statusError
                                    : (controller.painScore.value >= 4 ? AppTheme.statusWarning : AppTheme.primary700),
                              ),
                            )),
                      ],
                    ),
                    Obx(() => Slider(
                          value: controller.painScore.value.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          activeColor: controller.painScore.value >= 7
                              ? AppTheme.statusError
                              : (controller.painScore.value >= 4 ? AppTheme.statusWarning : AppTheme.primary700),
                          label: controller.painScore.value.toString(),
                          onChanged: (val) {
                            controller.painScore.value = val.toInt();
                          },
                        )),
                    const SizedBox(height: 16),
                    Text(
                      'Gejala yang Dialami',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: controller.availableSymptoms.map((symptom) {
                        return Obx(() {
                          final isSelected = controller.selectedSymptoms.contains(symptom);
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return FilterChip(
                            label: Text(symptom, style: const TextStyle(fontSize: 12)),
                            selected: isSelected,
                            selectedColor: isDark ? AppTheme.primary900.withValues(alpha: 0.4) : AppTheme.primary50,
                            checkmarkColor: AppTheme.primary700,
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedSymptoms.add(symptom);
                              } else {
                                controller.selectedSymptoms.remove(symptom);
                              }
                            },
                          );
                        });
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Tambahan (Opsional)',
                        hintText: 'Keluhan khusus atau obat yang diminum...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.submitPeriod,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Simpan Catatan Haid'),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
