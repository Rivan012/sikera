import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import 'cases_controller.dart';

class CaseDetailPage extends GetView<CasesController> {
  const CaseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final int caseId = (Get.arguments is int) ? Get.arguments as int : 1;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Studi Kasus'),
      ),
      body: Obx(() {
        final item = controller.selectedCase.value;

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          isEmpty: item == null,
          emptyMessage: 'Studi kasus tidak ditemukan.',
          onRetry: () => controller.fetchCaseDetail(caseId),
          child: item == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.category.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi Kasus
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kronologi / Situasi Kasus',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Divider(height: 16),
                              Text(
                                item.content.isNotEmpty ? item.content : item.summary,
                                style: const TextStyle(fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tinjauan Medis
                      if (item.medicalAspect != null && item.medicalAspect!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.primary900.withValues(alpha: 0.35) : AppTheme.primary50,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(
                              color: isDark ? AppTheme.primary700.withValues(alpha: 0.4) : AppTheme.primary200,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.medical_services_outlined, color: isDark ? AppTheme.primary200 : AppTheme.primary700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Tinjauan Medis & Kesehatan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.primary200 : AppTheme.primary900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.medicalAspect!,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Tinjauan Hukum / UU TPKS
                      if (item.legalAspect != null && item.legalAspect!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.gavel_rounded, color: isDark ? AppTheme.primary500 : AppTheme.primary700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Aspek Hukum (UU TPKS / Regulasi Kampus)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.legalAspect!,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      }),
    );
  }
}
