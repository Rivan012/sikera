import 'module_model.dart';

enum AssessmentKind { pretest, posttest }

class AdminQuestionModel {
  final int id;
  final int? moduleId;
  final AssessmentKind kind;
  final String questionText;
  final List<QuestionOption> options;
  final String correctAnswer;
  final int? sortOrder;

  const AdminQuestionModel({
    required this.id,
    this.moduleId,
    required this.kind,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.sortOrder,
  });

  factory AdminQuestionModel.fromJson(
    Map<String, dynamic> json, {
    required AssessmentKind defaultKind,
    int? fallbackModuleId,
  }) {
    final parsedOptions = _parseOptions(json);
    final rawType = json['type']?.toString().trim().toLowerCase() ?? '';
    final resolvedKind = rawType == 'posttest'
        ? AssessmentKind.posttest
        : rawType == 'pretest'
        ? AssessmentKind.pretest
        : defaultKind;

    final rawCorrect =
        (json['correct_answer'] ??
                json['correct_option'] ??
                json['answer_key'] ??
                '')
            .toString()
            .trim()
            .toUpperCase();

    final rawModuleId = json['module_id'];
    final parsedModuleId = rawModuleId is int
        ? rawModuleId
        : int.tryParse(rawModuleId?.toString() ?? '') ?? fallbackModuleId;

    return AdminQuestionModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      moduleId: resolvedKind == AssessmentKind.pretest ? parsedModuleId : null,
      kind: resolvedKind,
      questionText: (json['question_text'] ?? json['question'] ?? '')
          .toString()
          .trim(),
      options: parsedOptions,
      correctAnswer: rawCorrect,
      sortOrder: json['order'] is int
          ? json['order'] as int
          : int.tryParse(json['order']?.toString() ?? ''),
    );
  }

  static List<QuestionOption> _parseOptions(Map<String, dynamic> json) {
    final raw = json['options'];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(QuestionOption.fromJson)
          .where((o) => o.label.trim().isNotEmpty)
          .toList();
    }
    if (raw is Map) {
      return raw.entries
          .map(
            (entry) => QuestionOption(
              label: entry.key.toString().trim().toUpperCase(),
              text: entry.value?.toString().trim() ?? '',
            ),
          )
          .where((o) => o.label.isNotEmpty)
          .toList();
    }

    const keys = [('A', 'option_a'), ('B', 'option_b'), ('C', 'option_c'), ('D', 'option_d')];
    final flat = <QuestionOption>[];
    for (final (label, key) in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        flat.add(QuestionOption(label: label, text: value));
      }
    }
    return flat;
  }

  Map<String, dynamic> toPayload() {
    return {
      if (moduleId != null) 'module_id': moduleId,
      'type': kind == AssessmentKind.pretest ? 'pretest' : 'posttest',
      'question_text': questionText.trim(),
      'options': options
          .map(
            (o) => {
              'label': o.label.trim().toUpperCase(),
              'text': o.text.trim(),
            },
          )
          .toList(),
      'correct_answer': correctAnswer.trim().toUpperCase(),
    };
  }
}
