class PeriodAssessmentResult {
  final int totalScore;
  final int? maxScore;
  final String category;
  final String? interpretation;
  final String? advice;
  final String? formula;
  final String? estimatedVolume;
  final bool? isHmb;

  const PeriodAssessmentResult({
    required this.totalScore,
    required this.category,
    this.maxScore,
    this.interpretation,
    this.advice,
    this.formula,
    this.estimatedVolume,
    this.isHmb,
  });

  factory PeriodAssessmentResult.fromJson(Map<String, dynamic> json) {
    final score = int.tryParse('${json['total_score']}');
    if (score == null || json['category'] is! String) {
      throw const FormatException('Hasil evaluasi tidak lengkap.');
    }
    return PeriodAssessmentResult(
      totalScore: score,
      maxScore: int.tryParse('${json['max_score']}'),
      category: json['category'] as String,
      interpretation: json['interpretation']?.toString(),
      advice: json['action_advice']?.toString(),
      formula: json['formula']?.toString(),
      estimatedVolume: json['estimated_volume']?.toString(),
      isHmb: json['is_hmb'] as bool?,
    );
  }
}
