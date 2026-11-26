import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/admin_assessment_model.dart';
import '../../routes/app_pages.dart';
import 'admin_assessment_controller.dart';
import 'widgets/admin_question_card.dart';

class AdminPosttestPage extends StatefulWidget {
  const AdminPosttestPage({super.key, this.standalone = false});

  final bool standalone;

  @override
  State<AdminPosttestPage> createState() => _AdminPosttestPageState();
}

class _AdminPosttestPageState extends State<AdminPosttestPage> {
  late final AdminAssessmentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AdminAssessmentController>()
        ? Get.find<AdminAssessmentController>()
        : Get.put(AdminAssessmentController());
    if (controller.posttestQuestions.isEmpty &&
        !controller.isLoadingPosttests.value &&
        controller.posttestError.value.isEmpty) {
      controller.fetchPosttestQuestions();
    }
  }

  void _openForm({AdminQuestionModel? question}) {
    controller.formErrorMessage.value = '';
    Get.toNamed(
      Routes.ADMIN_QUESTION_FORM,
      arguments: {
        'kind': AssessmentKind.posttest,
        'question': question,
      },
    );
  }

  void _confirmDelete(BuildContext context, AdminQuestionModel question) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus soal Post-Test?'),
        content: const Text(
          'Soal yang dihapus tidak lagi muncul pada Post-Test Akhir mahasiswa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 44),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Get.back();
              controller.deleteQuestion(question);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final accentColor = isDark ? AppTheme.primary200 : AppTheme.primary700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Post-Test'),
        automaticallyImplyLeading: widget.standalone,
      ),
      body: Obx(() {
        final questions = controller.posttestQuestions;
        final delayDays = controller.posttestDelayDays.value;

        return RefreshIndicator(
          color: AppTheme.primary700,
          onRefresh: () => controller.fetchPosttestQuestions(forceRefresh: true),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.softAccentSurfaceDark
                          : AppTheme.primary50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.borderDark
                            : AppTheme.strongBorderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(
                                  alpha: isDark ? 0.18 : 0.12,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                              ),
                              child: Icon(
                                Icons.quiz_outlined,
                                color: accentColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Post-Test Akhir (Seluruh Modul)',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      height: 1.3,
                                      color: headingColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Post-Test ini muncul otomatis $delayDays hari setelah mahasiswa menyelesaikan seluruh modul pembelajaran.',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.45,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          key: const ValueKey('add-posttest-question-btn'),
                          onPressed: () => _openForm(),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text(
                            'Tambah Soal Post-Test',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Daftar Soal Post-Test',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: headingColor,
                        ),
                      ),
                      Text(
                        '${questions.length} soal',
                        style: TextStyle(fontSize: 13, color: secondaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (controller.isLoadingPosttests.value)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Memuat soal Post-Test...'),
                          ],
                        ),
                      ),
                    )
                  else if (controller.posttestError.value.isNotEmpty)
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 36,
                              color: isDark
                                  ? const Color(0xFFFFB4AB)
                                  : AppTheme.error,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              controller.posttestError.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: () => controller.fetchPosttestQuestions(
                                forceRefresh: true,
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (questions.isEmpty)
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 40,
                              color: isDark
                                  ? AppTheme.textMutedDark
                                  : AppTheme.textMutedLight,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada soal Post-Test Akhir.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: headingColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tambahkan soal Post-Test untuk mengevaluasi pemahaman mahasiswa setelah menyelesaikan seluruh modul.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.45,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => _openForm(),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Tambah Soal Pertama'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < questions.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          AdminQuestionCard(
                            index: i,
                            question: questions[i],
                            isDeleting:
                                controller.deletingQuestionId.value ==
                                questions[i].id,
                            onEdit: () => _openForm(question: questions[i]),
                            onDelete: () =>
                                _confirmDelete(context, questions[i]),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
