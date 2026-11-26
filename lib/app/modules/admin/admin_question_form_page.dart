import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/admin_assessment_model.dart';
import '../../data/models/module_model.dart';
import 'admin_assessment_controller.dart';

class AdminQuestionFormPage extends StatefulWidget {
  const AdminQuestionFormPage({super.key});

  @override
  State<AdminQuestionFormPage> createState() => _AdminQuestionFormPageState();
}

class _AdminQuestionFormPageState extends State<AdminQuestionFormPage> {
  static const List<String> _optionLabels = ['A', 'B', 'C', 'D', 'E'];

  final _formKey = GlobalKey<FormState>();
  late final AdminAssessmentController controller;
  late final AssessmentKind kind;
  AdminQuestionModel? editingQuestion;

  int? _selectedModuleId;
  late final TextEditingController _questionController;
  final List<TextEditingController> _optionControllers = [];
  String _correctAnswer = 'A';
  String? _correctAnswerError;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AdminAssessmentController>()
        ? Get.find<AdminAssessmentController>()
        : Get.put(AdminAssessmentController());

    final args = Get.arguments is Map ? Get.arguments as Map : {};
    kind = args['kind'] is AssessmentKind
        ? args['kind'] as AssessmentKind
        : AssessmentKind.pretest;
    editingQuestion = args['question'] is AdminQuestionModel
        ? args['question'] as AdminQuestionModel
        : null;

    _selectedModuleId =
        args['moduleId'] as int? ??
        editingQuestion?.moduleId ??
        controller.selectedModule?.id;

    _questionController = TextEditingController(
      text: editingQuestion?.questionText ?? '',
    );

    final initialOptions = editingQuestion?.options ?? const [];
    if (initialOptions.length >= 2) {
      for (final opt in initialOptions) {
        _optionControllers.add(TextEditingController(text: opt.text));
      }
      _correctAnswer = editingQuestion!.correctAnswer.isNotEmpty
          ? editingQuestion!.correctAnswer.toUpperCase()
          : _optionLabels.first;
    } else {
      for (var i = 0; i < 4; i++) {
        _optionControllers.add(TextEditingController());
      }
      _correctAnswer = 'A';
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length >= _optionLabels.length) return;
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      final removedLabel = _optionLabels[index];
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      final validLabels = _optionLabels.take(_optionControllers.length).toList();
      if (!validLabels.contains(_correctAnswer) ||
          _correctAnswer == removedLabel) {
        _correctAnswer = validLabels.first;
      }
    });
  }

  Future<void> _submit() async {
    controller.formErrorMessage.value = '';
    setState(() => _correctAnswerError = null);

    final validForm = _formKey.currentState?.validate() ?? false;
    final validLabels = _optionLabels.take(_optionControllers.length).toList();
    if (!validLabels.contains(_correctAnswer)) {
      setState(() {
        _correctAnswerError = 'Pilih satu kunci jawaban yang benar.';
      });
      return;
    }
    if (!validForm) return;

    final options = <QuestionOption>[];
    for (var i = 0; i < _optionControllers.length; i++) {
      options.add(
        QuestionOption(
          label: _optionLabels[i],
          text: _optionControllers[i].text.trim(),
        ),
      );
    }

    final saved = await controller.saveQuestion(
      kind: kind,
      moduleId: kind == AssessmentKind.pretest ? _selectedModuleId : null,
      editingId: editingQuestion?.id,
      questionText: _questionController.text.trim(),
      options: options,
      correctAnswer: _correctAnswer,
    );

    if (saved && mounted) {
      Get.back(result: true);
      Get.snackbar(
        editingQuestion == null ? 'Soal Ditambahkan' : 'Soal Diperbarui',
        kind == AssessmentKind.pretest
            ? 'Soal Pre-Test berhasil disimpan.'
            : 'Soal Post-Test berhasil disimpan.',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
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
    final isEditing = editingQuestion != null;
    final title = kind == AssessmentKind.pretest
        ? (isEditing ? 'Edit Soal Pre-Test' : 'Tambah Soal Pre-Test')
        : (isEditing ? 'Edit Soal Post-Test' : 'Tambah Soal Post-Test');

    return Obx(() {
      final isSaving = controller.isSaving.value;
      final apiError = controller.formErrorMessage.value;
      final modules = controller.modules;

      return PopScope(
        canPop: !isSaving,
        child: Scaffold(
          appBar: AppBar(title: Text(title)),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (apiError.isNotEmpty) ...[
                                Semantics(
                                  liveRegion: true,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusMd,
                                      ),
                                    ),
                                    child: Text(
                                      apiError,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                        fontSize: 13.5,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (kind == AssessmentKind.pretest) ...[
                                Text(
                                  'Modul Pre-Test',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: headingColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<int>(
                                  key: const ValueKey('form-module-dropdown'),
                                  initialValue:
                                      modules.any(
                                            (m) => m.id == _selectedModuleId,
                                          )
                                          ? _selectedModuleId
                                          : null,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Pilih modul untuk Pre-Test',
                                  ),
                                  items: modules
                                      .map(
                                        (m) => DropdownMenuItem<int>(
                                          value: m.id,
                                          child: Text(
                                            'Modul ${m.moduleNumber}: ${m.title}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: isSaving
                                      ? null
                                      : (value) => setState(
                                            () => _selectedModuleId = value,
                                          ),
                                  validator: (value) => value == null
                                      ? 'Pilih modul terlebih dahulu.'
                                      : null,
                                ),
                                const SizedBox(height: 18),
                              ],
                              Text(
                                'Pertanyaan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: headingColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                key: const ValueKey('form-question-input'),
                                controller: _questionController,
                                enabled: !isSaving,
                                minLines: 3,
                                maxLines: 6,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Tulis pertanyaan secara jelas dan mudah dipahami mahasiswa',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Pertanyaan wajib diisi.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  Text(
                                    'Pilihan Jawaban & Kunci',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: headingColor,
                                    ),
                                  ),
                                  if (_optionControllers.length <
                                      _optionLabels.length)
                                    TextButton.icon(
                                      onPressed: isSaving ? null : _addOption,
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Tambah Opsi'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pilih huruf jawaban yang benar pada tombol pilihan di sebelah kiri.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              RadioGroup<String>(
                                groupValue: _correctAnswer,
                                onChanged: (value) {
                                  if (value != null && !isSaving) {
                                    setState(() {
                                      _correctAnswer = value;
                                      _correctAnswerError = null;
                                    });
                                  }
                                },
                                child: Column(
                                  children: [
                                    for (
                                      var i = 0;
                                      i < _optionControllers.length;
                                      i++
                                    )
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Tooltip(
                                              message:
                                                  'Tandai ${_optionLabels[i]} sebagai kunci jawaban',
                                              child: SizedBox(
                                                width: 44,
                                                height: 48,
                                                child: Radio<String>(
                                                  key: ValueKey(
                                                    'form-correct-${_optionLabels[i]}',
                                                  ),
                                                  value: _optionLabels[i],
                                                  enabled: !isSaving,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: TextFormField(
                                                key: ValueKey(
                                                  'form-option-${_optionLabels[i]}',
                                                ),
                                                controller:
                                                    _optionControllers[i],
                                                enabled: !isSaving,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Pilihan ${_optionLabels[i]}',
                                                  hintText:
                                                      'Masukkan teks pilihan ${_optionLabels[i]}',
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Pilihan ${_optionLabels[i]} wajib diisi.';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            if (_optionControllers.length >
                                                2) ...[
                                              const SizedBox(width: 4),
                                              IconButton(
                                                tooltip:
                                                    'Hapus pilihan ${_optionLabels[i]}',
                                                onPressed: isSaving
                                                    ? null
                                                    : () => _removeOption(i),
                                                style: IconButton.styleFrom(
                                                  minimumSize: const Size(
                                                    44,
                                                    48,
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.close_rounded,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_correctAnswerError != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _correctAnswerError!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.elevatedSurfaceDark
                                      : AppTheme.pocketSurfaceLight,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                ),
                                child: Text(
                                  'Kunci jawaban terpilih: $_correctAnswer',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: headingColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving ? null : () => Get.back(),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              key: const ValueKey('form-save-question-btn'),
                              onPressed: isSaving ? null : _submit,
                              icon: isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined, size: 20),
                              label: Text(
                                isSaving ? 'Menyimpan...' : 'Simpan Soal',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
