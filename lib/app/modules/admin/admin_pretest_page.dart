import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/admin_assessment_model.dart';
import '../../data/models/dashboard_model.dart';
import '../../routes/app_pages.dart';
import 'admin_assessment_controller.dart';
import 'widgets/admin_question_card.dart';

class AdminPretestPage extends StatefulWidget {
  const AdminPretestPage({super.key, this.standalone = false});

  final bool standalone;

  @override
  State<AdminPretestPage> createState() => _AdminPretestPageState();
}

class _AdminPretestPageState extends State<AdminPretestPage> {
  late final AdminAssessmentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AdminAssessmentController>()
        ? Get.find<AdminAssessmentController>()
        : Get.put(AdminAssessmentController());
    if (controller.modules.isEmpty && !controller.isLoadingModules.value) {
      controller.loadPretestTab();
    } else if (controller.selectedModule != null &&
        controller.pretestQuestions.isEmpty &&
        !controller.isLoadingPretests.value &&
        controller.pretestError.value.isEmpty) {
      controller.fetchPretestQuestions(controller.selectedModule!.id);
    }
  }

  void _openForm({required DashboardModuleModel module, AdminQuestionModel? question}) {
    controller.formErrorMessage.value = '';
    Get.toNamed(
      Routes.ADMIN_QUESTION_FORM,
      arguments: {
        'kind': AssessmentKind.pretest,
        'moduleId': module.id,
        'question': question,
      },
    );
  }

  void _confirmDelete(BuildContext context, AdminQuestionModel question) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus soal Pre-Test?'),
        content: const Text(
          'Soal yang dihapus tidak lagi muncul pada Pre-Test modul ini.',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pre-Test'),
        automaticallyImplyLeading: widget.standalone,
      ),
      body: Obx(() {
        final modules = controller.modules;
        final selected = controller.selectedModule;

        return StateView(
          isLoading: controller.isLoadingModules.value && modules.isEmpty,
          loadingMessage: 'Memuat daftar modul...',
          errorMessage: controller.modulesError.value.isNotEmpty
              ? controller.modulesError.value
              : null,
          isEmpty: modules.isEmpty,
          emptyIcon: Icons.library_books_outlined,
          emptyMessage:
              'Belum ada modul tersedia. Tambahkan modul terlebih dahulu untuk mengelola soal Pre-Test.',
          onRetry: () => controller.loadPretestTab(forceRefresh: true),
          child: selected == null
              ? const SizedBox.shrink()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final useTwoPane =
                        constraints.maxWidth >= 760 &&
                        MediaQuery.textScalerOf(context).scale(14) <= 18;
                    if (useTwoPane) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 280,
                            child: _buildModuleSidebar(
                              modules: modules,
                              selected: selected,
                              isDark: isDark,
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            color: isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight,
                          ),
                          Expanded(
                            child: _buildQuestionsPane(
                              context,
                              module: selected,
                              isDark: isDark,
                              showMobileModuleSelector: false,
                              modules: modules,
                            ),
                          ),
                        ],
                      );
                    }

                    return _buildQuestionsPane(
                      context,
                      module: selected,
                      isDark: isDark,
                      showMobileModuleSelector: true,
                      modules: modules,
                    );
                  },
                ),
        );
      }),
    );
  }

  Widget _buildModuleSidebar({
    required List<DashboardModuleModel> modules,
    required DashboardModuleModel selected,
    required bool isDark,
  }) {
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;

    return ColoredBox(
      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Pilih Modul (${modules.length})',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (final module in modules) ...[
            Builder(
              builder: (context) {
                final isSelected = module.id == selected.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected
                        ? (isDark
                              ? AppTheme.softAccentSurfaceDark
                              : AppTheme.primary50)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: ValueKey('admin-pretest-module-${module.id}'),
                      onTap: () => controller.selectModule(module.id),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 52),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? (isDark
                                      ? AppTheme.primary500
                                      : AppTheme.primary700)
                                : (isDark
                                      ? AppTheme.borderDark
                                      : AppTheme.borderLight),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modul ${module.moduleNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? (isDark
                                          ? AppTheme.primary200
                                          : AppTheme.primary700)
                                    : secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              module.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                height: 1.3,
                                color: headingColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionsPane(
    BuildContext context, {
    required DashboardModuleModel module,
    required bool isDark,
    required bool showMobileModuleSelector,
    required List<DashboardModuleModel> modules,
  }) {
    final questions = controller.pretestQuestions;
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;

    return RefreshIndicator(
      color: AppTheme.primary700,
      onRefresh: () =>
          controller.fetchPretestQuestions(module.id, forceRefresh: true),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              if (showMobileModuleSelector) ...[
                _buildMobileModuleSelector(
                  modules: modules,
                  selected: module,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
              ],
              _buildSelectedModuleHeader(
                context,
                module: module,
                questionCount: questions.length,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    'Daftar Soal Pre-Test',
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
              if (controller.isLoadingPretests.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Memuat soal Pre-Test...'),
                      ],
                    ),
                  ),
                )
              else if (controller.pretestError.value.isNotEmpty)
                _buildInlineErrorState(
                  message: controller.pretestError.value,
                  onRetry: () => controller.fetchPretestQuestions(
                    module.id,
                    forceRefresh: true,
                  ),
                  isDark: isDark,
                )
              else if (questions.isEmpty)
                _buildEmptyQuestionsState(
                  module: module,
                  isDark: isDark,
                  onAdd: () => _openForm(module: module),
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
                        onEdit: () =>
                            _openForm(module: module, question: questions[i]),
                        onDelete: () => _confirmDelete(context, questions[i]),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileModuleSelector({
    required List<DashboardModuleModel> modules,
    required DashboardModuleModel selected,
    required bool isDark,
  }) {
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.primary500 : AppTheme.primary700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              'Pilih Modul',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: headingColor,
              ),
            ),
            Text(
              '${modules.length} modul',
              style: TextStyle(fontSize: 13, color: secondaryColor),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final module in modules)
              Builder(
                builder: (context) {
                  final isSelected = module.id == selected.id;
                  return ChoiceChip(
                    key: ValueKey('admin-pretest-module-${module.id}'),
                    label: Text('Modul ${module.moduleNumber}'),
                    selected: isSelected,
                    onSelected: (_) => controller.selectModule(module.id),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    visualDensity: VisualDensity.standard,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    selectedColor: isDark
                        ? AppTheme.softAccentSurfaceDark
                        : AppTheme.primary50,
                    backgroundColor: isDark
                        ? AppTheme.surfaceDark
                        : AppTheme.surfaceLight,
                    side: BorderSide(
                      color: isSelected
                          ? accent
                          : (isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight),
                    ),
                    labelStyle: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? (isDark
                                ? AppTheme.primary200
                                : AppTheme.primary900)
                          : secondaryColor,
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedModuleHeader(
    BuildContext context, {
    required DashboardModuleModel module,
    required int questionCount,
    required bool isDark,
  }) {
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final accentColor = isDark ? AppTheme.primary200 : AppTheme.primary700;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.strongBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Modul ${module.moduleNumber}',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            module.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pre-Test ini wajib dikerjakan mahasiswa sebelum mengakses submateri Modul ${module.moduleNumber}.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            key: const ValueKey('add-pretest-question-btn'),
            onPressed: () => _openForm(module: module),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'Tambah Soal Pre-Test',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineErrorState({
    required String message,
    required VoidCallback onRetry,
    required bool isDark,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: isDark ? const Color(0xFFFFB4AB) : AppTheme.error,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyQuestionsState({
    required DashboardModuleModel module,
    required bool isDark,
    required VoidCallback onAdd,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 40,
              color: isDark
                  ? AppTheme.textMutedDark
                  : AppTheme.textMutedLight,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada soal Pre-Test untuk Modul ${module.moduleNumber}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.primary900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambahkan soal Pre-Test agar mahasiswa dapat mengerjakan evaluasi awal sebelum membaca materi modul ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah Soal Pertama'),
            ),
          ],
        ),
      ),
    );
  }
}
