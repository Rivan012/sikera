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
  final int? menarcheAge;
  final bool? isRegular;
  final String? bloodConsistency;
  final bool? hasDysmenorrhea;
  final int? waliddTotalScore;
  final String? waliddCategory;
  final int? pbacScore;
  final String? volumeCategory;
  final Map<String, dynamic>? pbacDetails;

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
    this.menarcheAge,
    this.isRegular,
    this.bloodConsistency,
    this.hasDysmenorrhea,
    this.waliddTotalScore,
    this.waliddCategory,
    this.pbacScore,
    this.volumeCategory,
    this.pbacDetails,
  });

  factory PeriodRecordModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedSymptoms = [];
    if (json['symptoms'] is List) {
      parsedSymptoms = (json['symptoms'] as List)
          .map((e) => e.toString())
          .toList();
    }
    return PeriodRecordModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString(),
      cycleLength: json['cycle_length'] is int
          ? json['cycle_length']
          : int.tryParse(json['cycle_length']?.toString() ?? '28') ?? 28,
      periodDuration: json['period_duration'] is int
          ? json['period_duration']
          : int.tryParse(json['period_duration']?.toString() ?? '5') ?? 5,
      flowLevel: json['flow_level']?.toString() ?? 'sedang',
      flowColor: json['flow_color']?.toString() ?? 'Merah Terang',
      nrsPainScore: json['nrs_pain_score'] is int
          ? json['nrs_pain_score']
          : int.tryParse(json['nrs_pain_score']?.toString() ?? '0') ?? 0,
      symptoms: parsedSymptoms,
      notes: json['notes']?.toString(),
      menarcheAge: int.tryParse('${json['menarche_age']}'),
      isRegular: json['is_regular'] == null
          ? null
          : (json['is_regular'] == true || json['is_regular'] == 1),
      bloodConsistency: json['blood_consistency']?.toString(),
      hasDysmenorrhea: json['has_dysmenorrhea'] == null
          ? null
          : (json['has_dysmenorrhea'] == true || json['has_dysmenorrhea'] == 1),
      waliddTotalScore: int.tryParse(
        '${json['walidd_total_score'] ?? (json['walidd'] is Map ? json['walidd']['total_score'] : null)}',
      ),
      waliddCategory:
          (json['walidd_category'] ??
                  (json['walidd'] is Map ? json['walidd']['category'] : null))
              ?.toString(),
      pbacScore: int.tryParse('${json['pbac_score']}'),
      volumeCategory: json['volume_category']?.toString(),
      pbacDetails: json['pbac_details'] is Map<String, dynamic>
          ? json['pbac_details']
          : null,
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
      if (menarcheAge != null) 'menarche_age': menarcheAge,
      if (isRegular != null) 'is_regular': isRegular,
      if (bloodConsistency != null) 'blood_consistency': bloodConsistency,
      if (hasDysmenorrhea != null) 'has_dysmenorrhea': hasDysmenorrhea,
    };
  }
}

class BmiRecordModel {
  final int? id;
  final double weightKg;
  final double heightCm;
  final double? bmiScore;
  final String? category;
  final String? advice;
  final String? createdAt;

  BmiRecordModel({
    this.id,
    required this.weightKg,
    required this.heightCm,
    this.bmiScore,
    this.category,
    this.advice,
    this.createdAt,
  });

  factory BmiRecordModel.fromJson(Map<String, dynamic> json) {
    final score = json['bmi_value'] ?? json['bmi_score'];
    return BmiRecordModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      weightKg: (json['weight_kg'] is num)
          ? (json['weight_kg'] as num).toDouble()
          : double.tryParse(json['weight_kg']?.toString() ?? '0') ?? 0.0,
      heightCm: (json['height_cm'] is num)
          ? (json['height_cm'] as num).toDouble()
          : double.tryParse(json['height_cm']?.toString() ?? '0') ?? 0.0,
      bmiScore: (score is num)
          ? score.toDouble()
          : double.tryParse(score?.toString() ?? ''),
      category: json['category']?.toString(),
      advice: json['advice']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'weight_kg': weightKg, 'height_cm': heightCm};
  }
}

class PeriodPredictionModel {
  final String nextPeriodDate;
  final String? nextPeriodEndDate;
  final List<PeriodCycleProjection> upcomingCycles;
  final String ovulationDate;
  final String fertileWindowStart;
  final String fertileWindowEnd;

  // Scientific metrics & current status
  final int? cycleDay;
  final String? currentPhase;
  final String? phaseDescription;
  final int? daysUntilNextPeriod;
  final String? fertilityStatus;
  final int? movingAverageLength;
  final bool? isRegular;
  final String? statusLabel;
  final String? oginoKnausRange;
  final String? clinicalDisclaimer;
  final List<String> scientificReferences;

  // Rich API texts & narratives
  final String? countdownText;
  final String? summaryNarrative;
  final String? hormoneContext;
  final String? nextPeriodFormatted;
  final String? nextPeriodFormula;
  final String? nextPeriodNarrative;
  final String? ovulationFormatted;
  final String? ovulationFormula;
  final String? ovulationNarrative;
  final String? fertileWindowFormatted;
  final String? fertileWindowFormula;
  final String? fertileWindowNarrative;
  final String? oginoKnausFormatted;
  final String? oginoKnausFormula;
  final String? oginoKnausNarrative;
  final String? cycleCategoryDescription;
  final String? regularityStatus;

  PeriodPredictionModel({
    required this.nextPeriodDate,
    this.nextPeriodEndDate,
    this.upcomingCycles = const [],
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    this.cycleDay,
    this.currentPhase,
    this.phaseDescription,
    this.daysUntilNextPeriod,
    this.fertilityStatus,
    this.movingAverageLength,
    this.isRegular,
    this.statusLabel,
    this.oginoKnausRange,
    this.clinicalDisclaimer,
    this.scientificReferences = const [],
    this.countdownText,
    this.summaryNarrative,
    this.hormoneContext,
    this.nextPeriodFormatted,
    this.nextPeriodFormula,
    this.nextPeriodNarrative,
    this.ovulationFormatted,
    this.ovulationFormula,
    this.ovulationNarrative,
    this.fertileWindowFormatted,
    this.fertileWindowFormula,
    this.fertileWindowNarrative,
    this.oginoKnausFormatted,
    this.oginoKnausFormula,
    this.oginoKnausNarrative,
    this.cycleCategoryDescription,
    this.regularityStatus,
  });

  factory PeriodPredictionModel.fromJson(Map<String, dynamic> json) {
    if (json['details'] is Map<String, dynamic> &&
        json['predictions'] == null) {
      json = {...json, 'predictions': json['details']};
    }
    final preds = (json['predictions'] is Map<String, dynamic>)
        ? json['predictions'] as Map<String, dynamic>
        : ((json['prediction'] is Map<String, dynamic>)
              ? json['prediction'] as Map<String, dynamic>
              : json);

    final metrics = (json['cycle_metrics'] is Map<String, dynamic>)
        ? json['cycle_metrics'] as Map<String, dynamic>
        : (preds['cycle_metrics'] is Map<String, dynamic>
              ? preds['cycle_metrics'] as Map<String, dynamic>
              : null);

    final status = (json['current_status'] is Map<String, dynamic>)
        ? json['current_status'] as Map<String, dynamic>
        : (preds['current_status'] is Map<String, dynamic>
              ? preds['current_status'] as Map<String, dynamic>
              : null);

    List<String> references = [];
    final rawRefs =
        json['scientific_references'] ?? preds['scientific_references'];
    if (rawRefs is List) {
      references = rawRefs
          .map((e) {
            if (e is Map) {
              final author = e['author'] ?? e['name'] ?? e['component'] ?? '';
              final formula = e['formula'] != null ? ': ${e['formula']}' : '';
              final citation = e['citation'] != null
                  ? ' (${e['citation']})'
                  : '';
              final year = e['year'] != null ? ' (${e['year']})' : '';
              final title = e['title'] != null ? ': ${e['title']}' : '';
              return "$author$year$title$formula$citation".trim();
            }
            return e.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    String? oginoRange;
    final ogino =
        preds['ogino_knaus_window'] ??
        preds['ogino_knaus'] ??
        json['ogino_knaus'];
    if (ogino is Map) {
      final s = ogino['cycle_day_start'] ?? ogino['start_day'];
      final e = ogino['cycle_day_end'] ?? ogino['end_day'];
      if (s != null && e != null) {
        oginoRange = "Hari ke-$s s/d $e";
      }
    } else if (ogino is String) {
      oginoRange = ogino;
    }

    // Extract next period details
    String nextDate = '';
    String? nextFmt;
    String? nextFormula;
    String? nextNarrative;
    if (preds['next_period'] is Map) {
      final m = preds['next_period'] as Map;
      nextDate = m['start_date']?.toString() ?? '';
      nextFmt = m['start_formatted']?.toString();
      nextFormula = m['formula_applied']?.toString();
      nextNarrative = m['narrative']?.toString();
    } else if (preds['next_period_date'] != null) {
      nextDate = preds['next_period_date'].toString();
    } else if (json['next_period_date'] != null) {
      nextDate = json['next_period_date'].toString();
    }

    // Extract ovulation details
    String ovDate = '';
    String? ovFmt;
    String? ovFormula;
    String? ovNarrative;
    if (preds['ovulation'] is Map) {
      final m = preds['ovulation'] as Map;
      ovDate = m['date']?.toString() ?? '';
      ovFmt = m['formatted']?.toString();
      ovFormula = m['formula_applied']?.toString();
      ovNarrative = m['narrative']?.toString();
    } else if (preds['ovulation_date'] != null) {
      ovDate = preds['ovulation_date'].toString();
    } else if (json['ovulation_date'] != null) {
      ovDate = json['ovulation_date'].toString();
    }

    // Extract fertile window details
    String fStart = '';
    String fEnd = '';
    String? fFmt;
    String? fFormula;
    String? fNarrative;
    if (preds['fertile_window'] is Map) {
      final m = preds['fertile_window'] as Map;
      fStart = m['start_date']?.toString() ?? '';
      fEnd = m['end_date']?.toString() ?? '';
      fFmt = m['formatted']?.toString();
      fFormula = m['formula_applied']?.toString();
      fNarrative = m['narrative']?.toString();
    } else {
      fStart =
          preds['fertile_window_start']?.toString() ??
          json['fertile_window_start']?.toString() ??
          '';
      fEnd =
          preds['fertile_window_end']?.toString() ??
          json['fertile_window_end']?.toString() ??
          '';
    }

    // Extract ogino-knaus details
    String? oginoFmt;
    String? oginoFormula;
    String? oginoNarrative;
    if (ogino is Map) {
      oginoFmt = ogino['formatted']?.toString();
      oginoFormula = ogino['formula_applied']?.toString();
      oginoNarrative = ogino['narrative']?.toString();
    }

    final countdown =
        status?['countdown_text']?.toString() ??
        preds['countdown_text']?.toString() ??
        json['countdown_text']?.toString();
    final narrative =
        status?['summary_narrative']?.toString() ??
        preds['summary_narrative']?.toString() ??
        json['summary_narrative']?.toString();
    final hormone =
        status?['hormone_context']?.toString() ??
        preds['hormone_context']?.toString();

    return PeriodPredictionModel(
      nextPeriodDate: nextDate,
      nextPeriodEndDate: preds['next_period'] is Map
          ? preds['next_period']['end_date']?.toString()
          : null,
      upcomingCycles: json['upcoming_cycles'] is List
          ? (json['upcoming_cycles'] as List)
                .whereType<Map<String, dynamic>>()
                .map(PeriodCycleProjection.fromJson)
                .toList()
          : const [],
      ovulationDate: ovDate,
      fertileWindowStart: fStart,
      fertileWindowEnd: fEnd,
      cycleDay: status?['cycle_day'] is int
          ? status!['cycle_day']
          : int.tryParse(status?['cycle_day']?.toString() ?? ''),
      currentPhase:
          status?['phase_name']?.toString() ?? status?['phase']?.toString(),
      phaseDescription: status?['phase_description']?.toString(),
      daysUntilNextPeriod: status?['days_until_next_period'] is int
          ? status!['days_until_next_period']
          : int.tryParse(status?['days_until_next_period']?.toString() ?? ''),
      fertilityStatus:
          status?['fertility_status']?.toString() ??
          status?['fertility_badge']?.toString(),
      movingAverageLength: metrics?['average_cycle_length'] is int
          ? metrics!['average_cycle_length']
          : (metrics?['moving_average_length'] is int
                ? metrics!['moving_average_length']
                : int.tryParse(
                    metrics?['average_cycle_length']?.toString() ??
                        metrics?['moving_average_length']?.toString() ??
                        '',
                  )),
      isRegular: metrics?['is_regular'] == true,
      statusLabel:
          metrics?['cycle_category']?.toString() ??
          metrics?['status_label']?.toString(),
      oginoKnausRange: oginoRange,
      clinicalDisclaimer:
          json['clinical_disclaimer']?.toString() ??
          preds['clinical_disclaimer']?.toString(),
      scientificReferences: references,
      countdownText: countdown,
      summaryNarrative: narrative,
      hormoneContext: hormone,
      nextPeriodFormatted: nextFmt,
      nextPeriodFormula: nextFormula,
      nextPeriodNarrative: nextNarrative,
      ovulationFormatted: ovFmt,
      ovulationFormula: ovFormula,
      ovulationNarrative: ovNarrative,
      fertileWindowFormatted: fFmt,
      fertileWindowFormula: fFormula,
      fertileWindowNarrative: fNarrative,
      oginoKnausFormatted: oginoFmt,
      oginoKnausFormula: oginoFormula,
      oginoKnausNarrative: oginoNarrative,
      cycleCategoryDescription: metrics?['cycle_category_description']
          ?.toString(),
      regularityStatus: metrics?['regularity_status']?.toString(),
    );
  }
}

class PeriodCycleProjection {
  final String periodStart;
  final String? periodEnd;
  final String? ovulationDate;
  final String? fertileStart;
  final String? fertileEnd;

  const PeriodCycleProjection({
    required this.periodStart,
    this.periodEnd,
    this.ovulationDate,
    this.fertileStart,
    this.fertileEnd,
  });

  factory PeriodCycleProjection.fromJson(Map<String, dynamic> json) =>
      PeriodCycleProjection(
        periodStart: json['period_start']?.toString() ?? '',
        periodEnd: json['period_end']?.toString(),
        ovulationDate: json['ovulation_date']?.toString(),
        fertileStart: json['fertile_window_start']?.toString(),
        fertileEnd: json['fertile_window_end']?.toString(),
      );
}

class BloodGuideModel {
  final String colorName;
  final String hexColor;
  final String status;
  final String description;

  BloodGuideModel({
    required this.colorName,
    required this.hexColor,
    required this.status,
    required this.description,
  });

  factory BloodGuideModel.fromJson(Map<String, dynamic> json) {
    return BloodGuideModel(
      colorName:
          json['color_name']?.toString() ??
          json['title']?.toString() ??
          'Warna Darah',
      hexColor: json['hex_color']?.toString() ?? '#ef4444',
      status:
          json['status']?.toString() ??
          json['subtitle']?.toString() ??
          'Keterangan Medis',
      description:
          json['description']?.toString() ?? json['desc']?.toString() ?? '',
    );
  }
}

class HygieneGuideModel {
  final int step;
  final String title;
  final String description;

  HygieneGuideModel({
    required this.step,
    required this.title,
    required this.description,
  });

  factory HygieneGuideModel.fromJson(Map<String, dynamic> json) {
    return HygieneGuideModel(
      step: json['step'] is int
          ? json['step']
          : int.tryParse(json['step']?.toString() ?? '1') ?? 1,
      title: json['title']?.toString() ?? '',
      description:
          json['description']?.toString() ?? json['desc']?.toString() ?? '',
    );
  }
}
