class PeriodRecordModel {
  final int? id;
  final String startDate;
  final String? endDate;
  final int cycleLength;
  final int periodDuration;
  final String flowLevel;
  final String flowColor;
  final int nrsPainScore;
  final List<String> symptoms;
  final String? notes;

  PeriodRecordModel({
    this.id,
    required this.startDate,
    this.endDate,
    required this.cycleLength,
    required this.periodDuration,
    required this.flowLevel,
    required this.flowColor,
    required this.nrsPainScore,
    required this.symptoms,
    this.notes,
  });

  factory PeriodRecordModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedSymptoms = [];
    if (json['symptoms'] is List) {
      parsedSymptoms = (json['symptoms'] as List).map((e) => e.toString()).toList();
    }
    return PeriodRecordModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString(),
      cycleLength: json['cycle_length'] is int ? json['cycle_length'] : int.tryParse(json['cycle_length']?.toString() ?? '28') ?? 28,
      periodDuration: json['period_duration'] is int ? json['period_duration'] : int.tryParse(json['period_duration']?.toString() ?? '5') ?? 5,
      flowLevel: json['flow_level']?.toString() ?? 'sedang',
      flowColor: json['flow_color']?.toString() ?? 'Merah Terang',
      nrsPainScore: json['nrs_pain_score'] is int ? json['nrs_pain_score'] : int.tryParse(json['nrs_pain_score']?.toString() ?? '0') ?? 0,
      symptoms: parsedSymptoms,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'cycle_length': cycleLength,
      'period_duration': periodDuration,
      'flow_level': flowLevel,
      'flow_color': flowColor,
      'nrs_pain_score': nrsPainScore,
      'symptoms': symptoms,
      if (notes != null) 'notes': notes,
    };
  }
}

class BmiRecordModel {
  final int? id;
  final double weightKg;
  final double heightCm;
  final double? bmiScore;
  final String? category;
  final String? createdAt;

  BmiRecordModel({
    this.id,
    required this.weightKg,
    required this.heightCm,
    this.bmiScore,
    this.category,
    this.createdAt,
  });

  factory BmiRecordModel.fromJson(Map<String, dynamic> json) {
    return BmiRecordModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      weightKg: (json['weight_kg'] is num) ? (json['weight_kg'] as num).toDouble() : double.tryParse(json['weight_kg']?.toString() ?? '0') ?? 0.0,
      heightCm: (json['height_cm'] is num) ? (json['height_cm'] as num).toDouble() : double.tryParse(json['height_cm']?.toString() ?? '0') ?? 0.0,
      bmiScore: (json['bmi_score'] is num) ? (json['bmi_score'] as num).toDouble() : double.tryParse(json['bmi_score']?.toString() ?? ''),
      category: json['category']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight_kg': weightKg,
      'height_cm': heightCm,
    };
  }
}
