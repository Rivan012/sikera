import 'package:flutter_test/flutter_test.dart';
import 'package:sikera/app/data/models/selfcare_model.dart';

void main() {
  group('SelfCare Model Tests', () {
    test('PeriodRecordModel serializes and deserializes accurately with backend payload', () {
      final jsonPayload = {
        "id": 1,
        "start_date": "2026-09-01",
        "end_date": "2026-09-06",
        "cycle_length": 28,
        "period_duration": 5,
        "flow_level": "sedang",
        "flow_color": "Merah Terang",
        "nrs_pain_score": 3,
        "symptoms": ["Kram Perut", "Lelah"],
        "notes": "Keluhan ringan pada hari pertama."
      };

      final model = PeriodRecordModel.fromJson(jsonPayload);
      expect(model.id, 1);
      expect(model.startDate, '2026-09-01');
      expect(model.endDate, '2026-09-06');
      expect(model.cycleLength, 28);
      expect(model.periodDuration, 5);
      expect(model.flowLevel, 'sedang');
      expect(model.flowColor, 'Merah Terang');
      expect(model.nrsPainScore, 3);
      expect(model.symptoms, ['Kram Perut', 'Lelah']);
      expect(model.notes, 'Keluhan ringan pada hari pertama.');

      final serialized = model.toJson();
      expect(serialized['start_date'], '2026-09-01');
      expect(serialized['end_date'], '2026-09-06');
      expect(serialized['flow_level'], 'sedang');
      expect(serialized['symptoms'], ['Kram Perut', 'Lelah']);
    });

    test('BmiRecordModel handles bmi_value, category, and advice from backend', () {
      final jsonPayload = {
        "id": 12,
        "weight_kg": 54.0,
        "height_cm": 162.0,
        "bmi_value": 20.6,
        "category": "Normal",
        "advice": "Pertahankan pola makan seimbang dan aktivitas fisik teratur.",
        "created_at": "2026-09-12T10:00:00.000000Z"
      };

      final model = BmiRecordModel.fromJson(jsonPayload);
      expect(model.id, 12);
      expect(model.weightKg, 54.0);
      expect(model.heightCm, 162.0);
      expect(model.bmiScore, 20.6);
      expect(model.category, 'Normal');
      expect(model.advice, 'Pertahankan pola makan seimbang dan aktivitas fisik teratur.');
      expect(model.createdAt, '2026-09-12T10:00:00.000000Z');

      final serialized = model.toJson();
      expect(serialized['weight_kg'], 54.0);
      expect(serialized['height_cm'], 162.0);
    });

    test('PeriodPredictionModel deserializes predictions correctly', () {
      final jsonPayload = {
        "next_period_date": "2026-09-29",
        "ovulation_date": "2026-09-15",
        "fertile_window_start": "2026-09-10",
        "fertile_window_end": "2026-09-16"
      };

      final model = PeriodPredictionModel.fromJson(jsonPayload);
      expect(model.nextPeriodDate, '2026-09-29');
      expect(model.ovulationDate, '2026-09-15');
      expect(model.fertileWindowStart, '2026-09-10');
      expect(model.fertileWindowEnd, '2026-09-16');
    });

    test('PeriodPredictionModel deserializes scientific nested payload correctly', () {
      final scientificPayload = {
        "cycle_metrics": {
          "moving_average_length": 29,
          "shortest_cycle": 26,
          "longest_cycle": 31,
          "variation_days": 5,
          "is_regular": true,
          "status_label": "Siklus Teratur"
        },
        "current_status": {
          "target_date": "2026-09-12",
          "cycle_day": 12,
          "phase": "Fase Folikuler (Pra-Ovulasi)",
          "phase_description": "Folikel ovarium sedang berkembang menuju pematangan sel telur.",
          "days_until_next_period": 17,
          "fertility_status": "Masa Subur (Jendela Fertile)"
        },
        "predictions": {
          "next_period_date": "2026-09-29",
          "ovulation_date": "2026-09-15",
          "fertile_window_start": "2026-09-10",
          "fertile_window_end": "2026-09-16",
          "ogino_knaus_window": {
            "start_day": 8,
            "end_day": 20
          }
        },
        "clinical_disclaimer": "Prediksi ini berbasis ritmik kalender (Duane et al., 2016).",
        "scientific_references": [
          {"author": "ACOG", "year": 2015, "title": "Committee Opinion No. 651"},
          {"author": "Wilcox, A. J., et al.", "year": 1995, "title": "NEJM 1995"}
        ]
      };

      final model = PeriodPredictionModel.fromJson(scientificPayload);
      expect(model.nextPeriodDate, '2026-09-29');
      expect(model.ovulationDate, '2026-09-15');
      expect(model.fertileWindowStart, '2026-09-10');
      expect(model.fertileWindowEnd, '2026-09-16');
      expect(model.cycleDay, 12);
      expect(model.currentPhase, 'Fase Folikuler (Pra-Ovulasi)');
      expect(model.daysUntilNextPeriod, 17);
      expect(model.movingAverageLength, 29);
      expect(model.isRegular, true);
      expect(model.oginoKnausRange, 'Hari ke-8 s/d 20');
      expect(model.scientificReferences.length, 2);
      expect(model.scientificReferences.first, contains('ACOG (2015)'));
      expect(model.clinicalDisclaimer, contains('Duane et al., 2016'));
    });

    test('PeriodPredictionModel deserializes backend next_period object correctly', () {
      final backendPayload = {
        "cycle_metrics": {
          "average_cycle_length": 28,
          "shortest_cycle": 28,
          "longest_cycle": 28,
          "is_regular": true,
          "cycle_category": "Normal (21 - 35 hari)"
        },
        "current_status": {
          "cycle_day": 12,
          "phase_name": "Jendela Masa Subur (Fertile Window)",
          "phase_description": "Masa subur biologis berdasarkan viabilitas sperma 5 hari...",
          "days_until_next_period": 16,
          "is_period_late": false
        },
        "predictions": {
          "next_period": {
            "start_date": "2026-09-29",
            "end_date": "2026-10-03",
            "formula_applied": "LMP (01/09/2026) + 28 hari siklus",
            "clinical_reference": "ACOG Committee Opinion No. 651"
          },
          "ovulation": {
            "date": "2026-09-15",
            "formula_applied": "Hari ke-1 Haid Berikutnya (29/09/2026) - 14 hari fase luteal",
            "clinical_reference": "WHO & Berek & Novak"
          },
          "fertile_window": {
            "start_date": "2026-09-10",
            "end_date": "2026-09-16",
            "total_days": 6,
            "peak_date": "2026-09-15",
            "clinical_reference": "Wilcox, A. J., et al. (NEJM, 1995)"
          },
          "ogino_knaus": {
            "applicable": true,
            "cycle_day_start": 10,
            "cycle_day_end": 17,
            "clinical_reference": "Kemenkes RI (2021) & Metode Ogino-Knaus"
          }
        }
      };

      final model = PeriodPredictionModel.fromJson(backendPayload);
      expect(model.nextPeriodDate, '2026-09-29');
      expect(model.ovulationDate, '2026-09-15');
      expect(model.fertileWindowStart, '2026-09-10');
      expect(model.fertileWindowEnd, '2026-09-16');
      expect(model.currentPhase, 'Jendela Masa Subur (Fertile Window)');
      expect(model.cycleDay, 12);
      expect(model.daysUntilNextPeriod, 16);
      expect(model.movingAverageLength, 28);
      expect(model.statusLabel, 'Normal (21 - 35 hari)');
      expect(model.oginoKnausRange, 'Hari ke-10 s/d 17');
    });

    test('PeriodPredictionModel parses all rich narrative and text fields from API', () {
      final richPayload = {
        "cycle_metrics": {
          "average_cycle_length": 28,
          "is_regular": true,
          "cycle_category": "Normal (21 - 35 hari)",
          "cycle_category_description": "Panjang siklus haidmu berada dalam rentang yang sehat dan normal.",
          "regularity_status": "Siklus Teratur"
        },
        "current_status": {
          "cycle_day": 12,
          "phase_name": "Fase Pra-Subur (Masa Bersih)",
          "phase_description": "Tubuh sedang pulih setelah haid dan menyiapkan sel telur baru.",
          "hormone_context": "Hormon estrogen mulai meningkat secara bertahap.",
          "days_until_next_period": 16,
          "countdown_text": "16 hari lagi",
          "summary_narrative": "Haid berikutnya diperkirakan tiba pada tanggal 29 September 2026 (sekitar 16 hari lagi).",
          "fertility_status": "Rendah - Sedang"
        },
        "predictions": {
          "next_period": {
            "start_date": "2026-09-29",
            "start_formatted": "29 September 2026",
            "formula_applied": "Dihitung dari haid terakhir (01/09/2026) + siklus 28 hari",
            "narrative": "Haid berikutnya diperkirakan tiba pada tanggal 29 September 2026."
          },
          "ovulation": {
            "date": "2026-09-15",
            "formatted": "15 September 2026",
            "formula_applied": "14 hari sebelum perkiraan haid berikutnya (29/09/2026)",
            "narrative": "Pelepasan sel telur matang diperkirakan pada tanggal 15 September 2026."
          },
          "fertile_window": {
            "start_date": "2026-09-10",
            "end_date": "2026-09-16",
            "formatted": "10 September - 16 September 2026",
            "formula_applied": "Rentang 6 hari (5 hari sebelum puncak ovulasi hingga 1 hari setelahnya)",
            "narrative": "Masa subur berlangsung selama 6 hari dengan peluang pembuahan optimal."
          },
          "ogino_knaus": {
            "applicable": true,
            "formatted": "Hari ke-10 s.d. 17",
            "formula_applied": "Disesuaikan dengan variasi siklus",
            "narrative": "Rentang variasi siklus berada di hari ke-10 s.d. 17."
          }
        },
        "clinical_disclaimer": "Perkiraan siklus haid ini dihitung sebagai panduan pola tubuh mandiri."
      };

      final model = PeriodPredictionModel.fromJson(richPayload);
      expect(model.summaryNarrative, contains('29 September 2026'));
      expect(model.countdownText, '16 hari lagi');
      expect(model.currentPhase, 'Fase Pra-Subur (Masa Bersih)');
      expect(model.hormoneContext, contains('estrogen'));
      expect(model.nextPeriodFormatted, '29 September 2026');
      expect(model.nextPeriodFormula, contains('01/09/2026'));
      expect(model.ovulationFormatted, '15 September 2026');
      expect(model.ovulationFormula, contains('14 hari sebelum'));
      expect(model.fertileWindowFormatted, contains('10 September'));
      expect(model.fertileWindowNarrative, contains('Masa subur'));
      expect(model.oginoKnausFormatted, 'Hari ke-10 s.d. 17');
      expect(model.cycleCategoryDescription, contains('sehat dan normal'));
      expect(model.regularityStatus, 'Siklus Teratur');
      expect(model.clinicalDisclaimer, contains('panduan pola tubuh mandiri'));
    });

    test('BloodGuideModel and HygieneGuideModel deserialize accurately', () {
      final bloodJson = {
        "color_name": "Merah Terang",
        "hex_color": "#dc2626",
        "status": "Darah Segar & Normal",
        "description": "Mengindikasikan aliran darah yang baru keluar."
      };

      final bloodModel = BloodGuideModel.fromJson(bloodJson);
      expect(bloodModel.colorName, 'Merah Terang');
      expect(bloodModel.hexColor, '#dc2626');
      expect(bloodModel.status, 'Darah Segar & Normal');
      expect(bloodModel.description, 'Mengindikasikan aliran darah yang baru keluar.');

      final hygieneJson = {
        "step": 1,
        "title": "Arah Membasuh yang Benar",
        "description": "Basuh dari depan ke belakang."
      };

      final hygieneModel = HygieneGuideModel.fromJson(hygieneJson);
      expect(hygieneModel.step, 1);
      expect(hygieneModel.title, 'Arah Membasuh yang Benar');
      expect(hygieneModel.description, 'Basuh dari depan ke belakang.');
    });
  });
}
