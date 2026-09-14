class TriviaQuestionModel {
  final int id;
  final String question;
  final List<String> options;
  final String? explanation;

  TriviaQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    this.explanation,
  });

  factory TriviaQuestionModel.fromJson(Map<String, dynamic> json) {
    final q = json['question'] is Map<String, dynamic> ? json['question'] as Map<String, dynamic> : json;
    List<String> parsedOptions = [];
    final rawOptions = q['options'] ?? q['choices'] ?? json['options'] ?? json['choices'];
    if (rawOptions is List) {
      parsedOptions = rawOptions.map((e) => e.toString()).toList();
    }
    return TriviaQuestionModel(
      id: q['id'] is int ? q['id'] : int.tryParse(q['id']?.toString() ?? '0') ?? 0,
      question: q['question']?.toString() ?? '',
      options: parsedOptions,
      explanation: q['explanation']?.toString() ?? json['explanation']?.toString(),
    );
  }
}

class MythFactCardModel {
  final int id;
  final String statement;
  final String category;
  final String correctAnswer; // 'fact' or 'myth'
  final String explanation;

  MythFactCardModel({
    required this.id,
    required this.statement,
    required this.category,
    required this.correctAnswer,
    required this.explanation,
  });

  factory MythFactCardModel.fromJson(Map<String, dynamic> json) {
    final c = json['card'] is Map<String, dynamic> ? json['card'] as Map<String, dynamic> : json;
    return MythFactCardModel(
      id: c['id'] is int ? c['id'] : int.tryParse(c['id']?.toString() ?? '0') ?? 0,
      statement: c['statement']?.toString() ?? '',
      category: c['category']?.toString() ?? 'Umum',
      correctAnswer: c['correct_answer']?.toString() ?? 'fact',
      explanation: c['explanation']?.toString() ?? '',
    );
  }
}
