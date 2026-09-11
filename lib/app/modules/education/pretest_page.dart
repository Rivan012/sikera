import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import 'education_controller.dart';

class PretestPage extends GetView<EducationController> {
  const PretestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final int moduleId = (Get.arguments is int) ? Get.arguments as int : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Test Modul'),
      ),
      body: Obx(() => StateView(
            isLoading: controller.isLoading.value,
            errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
            isEmpty: controller.questions.isEmpty,
            emptyMessage: 'Soal Pre-Test belum tersedia.',
            onRetry: () => controller.fetchPretest(moduleId),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: AppTheme.accentLight,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.accent, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pilihlah salah satu jawaban yang paling tepat.',
                              style: TextStyle(fontSize: 12, color: AppTheme.accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...controller.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final q = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${q.questionText}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            ...q.options.map((opt) {
                              return Obx(() {
                                final isSelected = controller.answers[q.id.toString()] == opt.label;
                                return InkWell(
                                  onTap: () {
                                    controller.answers[q.id.toString()] = opt.label;
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppTheme.primaryLight : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected ? AppTheme.primary : AppTheme.borderLight,
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: isSelected ? AppTheme.primary : Colors.grey.shade200,
                                          child: Text(
                                            opt.label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            opt.text,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            }),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isSubmitting.value ? null : () => controller.submitPretest(moduleId),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Kirim Jawaban Pre-Test'),
                      )),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          )),
    );
  }
}
