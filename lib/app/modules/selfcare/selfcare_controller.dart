import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/selfcare_model.dart';
import '../../data/models/period_assessment_model.dart';
import '../home/home_controller.dart';
import '../profile/profile_controller.dart';

class SelfcareController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final summaryData = Rxn<Map<String, dynamic>>();
  final isFemale = false.obs;
  final periodHistory = <PeriodRecordModel>[].obs;
  final bmiHistory = <BmiRecordModel>[].obs;
  final periodPredictions = Rxn<PeriodPredictionModel>();
  final simulationResult = Rxn<PeriodPredictionModel>();
  final isHistoryLoading = false.obs;
  final isBmiHistoryLoading = false.obs;
  final isPredictionLoading = false.obs;
  final isCalculatingSimulation = false.obs;
  final historyError = ''.obs;
  final predictionError = ''.obs;
  final simulationError = ''.obs;
  final isSavingPeriod = false.obs;
  final periodError = ''.obs;
  final periodSuccess = ''.obs;

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final menarcheAgeController = TextEditingController();
  final isRegular = Rxn<bool>();
  final cycleLengthController = TextEditingController(text: '28');
  final periodDurationController = TextEditingController(text: '5');
  final flowLevel = 'sedang'.obs;
  final flowColor = 'Merah Terang'.obs;
  final bloodConsistency = 'Sedang / Normal'.obs;
  final painScore = 0.obs;
  final workingAbility = 0.obs;
  final painDaysController = TextEditingController(text: '0');
  final painLocations = <String>[].obs;
  final selectedSymptoms = <String>[].obs;
  final notesController = TextEditingController();
  final includePbac = false.obs;
  final pbacCounts = <String, int>{
    'pads_light': 0,
    'pads_medium': 0,
    'pads_heavy': 0,
    'clots_small': 0,
    'clots_large': 0,
  }.obs;
  final pbacResult = Rxn<PeriodAssessmentResult>();
  final waliddResult = Rxn<PeriodAssessmentResult>();
  final pbacError = ''.obs;
  final waliddError = ''.obs;
  final isCalculatingPbac = false.obs;
  final isCalculatingWalidd = false.obs;
  int _pbacRevision = 0;
  int _waliddRevision = 0;
  int _simulationRevision = 0;

  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final bmiResult = Rxn<BmiRecordModel>();
  final bloodGuides = <BloodGuideModel>[].obs;
  final hygieneGuides = <HygieneGuideModel>[].obs;
  final isBloodLoading = false.obs;
  final isHygieneLoading = false.obs;
  final bloodError = ''.obs;
  final hygieneError = ''.obs;

  final availableSymptoms = [
    'Kram Perut',
    'Sakit Kepala',
    'Lelah / Lemas',
    'Nyeri Payudara',
    'Perubahan Suasana Hati',
    'Nafsu Makan Meningkat',
    'Jerawat',
    'Kembung',
  ];

  static String dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  int? get recordedDuration {
    final start = startDate.value;
    final end = endDate.value;
    if (start == null || end == null) return null;
    return DateTime.utc(
          end.year,
          end.month,
          end.day,
        ).difference(DateTime.utc(start.year, start.month, start.day)).inDays +
        1;
  }

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasToken) unawaited(loadSelfcare());
  }

  Future<void> loadSelfcare() async {
    await fetchSummary();
    if (!StorageService.hasToken) return;
    await Future.wait([
      if (isFemale.value) fetchPeriodHistory(),
      if (isFemale.value) fetchPeriodPrediction(),
      fetchBmiHistory(),
    ]);
  }

  Future<void> fetchSummary({bool forceRefresh = false}) async {
    if (isLoading.value || !StorageService.hasToken) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.get(ApiConstants.selfcareSummary);
      if (!response.success || response.data is! Map<String, dynamic>) {
        errorMessage.value =
            response.message ?? 'Gagal memuat ringkasan self-care.';
        return;
      }
      final data = response.data as Map<String, dynamic>;
      summaryData.value = data;
      isFemale.value = data['is_female'] == true || data['is_female'] == 1;
      final tracker = data['period_tracker'];
      final rawPrediction = tracker is Map
          ? tracker['predictions'] ?? tracker['prediction']
          : data['predictions'] ?? data['prediction'];
      periodPredictions.value =
          isFemale.value && rawPrediction is Map<String, dynamic>
          ? PeriodPredictionModel.fromJson(rawPrediction)
          : null;
      if (!isFemale.value) periodHistory.clear();
      final bmiTracker = data['bmi_tracker'];
      final latestBmi = bmiTracker is Map
          ? bmiTracker['latest_bmi']
          : data['latest_bmi'];
      if (latestBmi is Map<String, dynamic>) {
        bmiResult.value = BmiRecordModel.fromJson(latestBmi);
      }
    } catch (_) {
      errorMessage.value = 'Format ringkasan tidak dapat dibaca. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPeriodPrediction() async {
    if (!StorageService.hasToken ||
        !isFemale.value ||
        isPredictionLoading.value) {
      return;
    }
    isPredictionLoading.value = true;
    predictionError.value = '';
    try {
      final response = await ApiService.get(ApiConstants.periodPrediction);
      if (response.success && response.data is Map<String, dynamic>) {
        final prediction = PeriodPredictionModel.fromJson(response.data);
        if (prediction.nextPeriodDate.isEmpty) throw const FormatException();
        periodPredictions.value = prediction;
      } else if (response.statusCode == 200 &&
          response.data == null &&
          !response.isMalformed) {
        periodPredictions.value = null;
      } else {
        predictionError.value =
            response.message ?? 'Prediksi belum dapat dimuat.';
      }
    } catch (_) {
      predictionError.value = 'Format prediksi tidak dapat dibaca. Coba lagi.';
    } finally {
      isPredictionLoading.value = false;
    }
  }

  Future<void> fetchPeriodHistory() async {
    if (!StorageService.hasToken || !isFemale.value || isHistoryLoading.value) {
      return;
    }
    isHistoryLoading.value = true;
    historyError.value = '';
    try {
      final response = await ApiService.get(ApiConstants.periodHistory);
      if (!response.success) {
        historyError.value = response.message ?? 'Riwayat belum dapat dimuat.';
        return;
      }
      final data = response.data;
      final logs = data is List
          ? data
          : data is Map
          ? data['period_logs'] ?? data['data']
          : null;
      if (logs is! List) throw const FormatException();
      periodHistory.assignAll(
        logs
            .map(
              (e) => PeriodRecordModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .take(20),
      );
    } catch (_) {
      historyError.value = 'Format riwayat tidak dapat dibaca. Coba lagi.';
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> fetchBmiHistory() async {
    if (!StorageService.hasToken || isBmiHistoryLoading.value) return;
    isBmiHistoryLoading.value = true;
    try {
      final response = await ApiService.get(ApiConstants.bmiHistory);
      if (response.success) {
        final data = response.data;
        final logs = data is List
            ? data
            : data is Map
            ? data['bmi_logs'] ?? data['data']
            : null;
        if (logs is List) {
          bmiHistory.assignAll(
            logs.whereType<Map<String, dynamic>>().map(BmiRecordModel.fromJson),
          );
        }
      }
    } finally {
      isBmiHistoryLoading.value = false;
    }
  }

  void invalidateSimulation() {
    _simulationRevision++;
    simulationResult.value = null;
    simulationError.value = '';
  }

  Future<PeriodPredictionModel?> calculatePeriodSimulation({
    required DateTime lastPeriodDate,
    required int cycleLength,
    required int periodDuration,
    List<int>? cycleHistory,
    DateTime? targetDate,
    int projectionCount = 3,
  }) async {
    if (isCalculatingSimulation.value) return null;
    invalidateSimulation();
    if (cycleLength < 15 ||
        cycleLength > 60 ||
        periodDuration < 1 ||
        periodDuration > 14 ||
        projectionCount < 1 ||
        projectionCount > 6 ||
        (cycleHistory?.any((e) => e < 15 || e > 60) ?? false)) {
      simulationError.value = 'Isi siklus 15–60 hari dan durasi 1–14 hari.';
      return null;
    }
    final revision = _simulationRevision;
    isCalculatingSimulation.value = true;
    try {
      final response = await ApiService.post(
        ApiConstants.periodCalculate,
        auth: false,
        body: {
          'last_period_date': dateOnly(lastPeriodDate),
          'cycle_length': cycleLength,
          'period_duration': periodDuration,
          if (cycleHistory != null && cycleHistory.isNotEmpty)
            'cycle_history': cycleHistory,
          'target_date': dateOnly(targetDate ?? DateTime.now()),
          'projection_count': projectionCount,
        },
      );
      if (revision != _simulationRevision) return null;
      if (!response.success || response.data is! Map<String, dynamic>) {
        simulationError.value =
            response.message ?? 'Simulasi belum dapat dihitung.';
        return null;
      }
      final prediction = PeriodPredictionModel.fromJson(response.data);
      if (prediction.nextPeriodDate.isEmpty) throw const FormatException();
      simulationResult.value = prediction;
      return prediction;
    } catch (_) {
      if (revision == _simulationRevision) {
        simulationError.value = 'Hasil simulasi tidak dapat dibaca. Coba lagi.';
      }
      return null;
    } finally {
      isCalculatingSimulation.value = false;
    }
  }

  void invalidatePbac() {
    _pbacRevision++;
    pbacResult.value = null;
    pbacError.value = '';
  }

  void invalidateWalidd() {
    _waliddRevision++;
    waliddResult.value = null;
    waliddError.value = '';
  }

  Future<void> calculatePbac() async {
    if (isCalculatingPbac.value) return;
    invalidatePbac();
    final revision = _pbacRevision;
    isCalculatingPbac.value = true;
    try {
      final response = await ApiService.post(
        ApiConstants.periodPbacCalculate,
        auth: false,
        body: Map<String, dynamic>.from(pbacCounts),
      );
      if (revision != _pbacRevision) return;
      if (!response.success || response.data is! Map<String, dynamic>) {
        pbacError.value = response.message ?? 'Skor PBAC belum dapat dihitung.';
        return;
      }
      pbacResult.value = PeriodAssessmentResult.fromJson(response.data);
    } catch (_) {
      if (revision == _pbacRevision) {
        pbacError.value = 'Hasil PBAC tidak dapat dibaca. Coba lagi.';
      }
    } finally {
      isCalculatingPbac.value = false;
    }
  }

  Future<void> calculateWalidd() async {
    if (isCalculatingWalidd.value) return;
    invalidateWalidd();
    final days = int.tryParse(painDaysController.text);
    if (days == null || days < 0 || days > 30) {
      waliddError.value = 'Isi jumlah hari nyeri antara 0 dan 30.';
      return;
    }
    final revision = _waliddRevision;
    isCalculatingWalidd.value = true;
    try {
      final response = await ApiService.post(
        ApiConstants.periodWaliddCalculate,
        auth: false,
        body: {
          'working_ability': workingAbility.value,
          'locations': painLocations.toList(),
          'nrs_score': painScore.value,
          'pain_days': days,
        },
      );
      if (revision != _waliddRevision) return;
      if (!response.success || response.data is! Map<String, dynamic>) {
        waliddError.value =
            response.message ?? 'Skor WaLIDD belum dapat dihitung.';
        return;
      }
      waliddResult.value = PeriodAssessmentResult.fromJson(response.data);
    } catch (_) {
      if (revision == _waliddRevision) {
        waliddError.value = 'Hasil WaLIDD tidak dapat dibaca. Coba lagi.';
      }
    } finally {
      isCalculatingWalidd.value = false;
    }
  }

  String? validatePeriod() {
    if (!StorageService.hasToken) return 'Masuk untuk menyimpan catatan haid.';
    if (!isFemale.value) {
      return 'Pencatatan haid tersedia untuk akun mahasiswi.';
    }
    final start = startDate.value;
    if (start == null) return 'Pilih tanggal mulai haid.';
    final today = DateUtils.dateOnly(DateTime.now());
    if (start.isAfter(today) || (endDate.value?.isAfter(today) ?? false)) {
      return 'Tanggal catatan tidak boleh melewati hari ini.';
    }
    if (recordedDuration != null && recordedDuration! < 1) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
    }
    final cycle = int.tryParse(cycleLengthController.text);
    if (cycle == null || cycle < 15 || cycle > 60) {
      return 'Isi panjang siklus antara 15 dan 60 hari.';
    }
    final duration =
        recordedDuration ?? int.tryParse(periodDurationController.text);
    if (duration == null || duration < 1 || duration > 14) {
      return 'Isi durasi haid antara 1 dan 14 hari.';
    }
    if (isRegular.value == null) return 'Pilih apakah siklus biasanya teratur.';
    final ageText = menarcheAgeController.text.trim();
    final age = int.tryParse(ageText);
    if (ageText.isNotEmpty && (age == null || age < 8 || age > 25)) {
      return 'Usia haid pertama yang didukung adalah 8–25 tahun.';
    }
    final days = int.tryParse(painDaysController.text);
    if (days == null || days < 0 || days > 30) {
      return 'Isi jumlah hari nyeri antara 0 dan 30.';
    }
    if (painScore.value == 0 &&
        (workingAbility.value > 0 || painLocations.isNotEmpty || days > 0)) {
      return 'Periksa skor nyeri: NRS 0 berarti tidak ada nyeri. Sesuaikan isian WaLIDD.';
    }
    if (notesController.text.length > 500) {
      return 'Catatan maksimal 500 karakter.';
    }
    return null;
  }

  Map<String, dynamic> periodPayload() => {
    if (menarcheAgeController.text.trim().isNotEmpty)
      'menarche_age': int.parse(menarcheAgeController.text.trim()),
    'start_date': dateOnly(startDate.value!),
    if (endDate.value != null) 'end_date': dateOnly(endDate.value!),
    'cycle_length': int.parse(cycleLengthController.text),
    'period_duration':
        recordedDuration ?? int.parse(periodDurationController.text),
    'is_regular': isRegular.value!,
    'flow_level': flowLevel.value,
    'flow_color': flowColor.value,
    'blood_consistency': bloodConsistency.value,
    if (includePbac.value)
      ...pbacCounts.map((key, value) => MapEntry('pbac_$key', value)),
    'nrs_pain_score': painScore.value,
    'has_dysmenorrhea': painScore.value > 0,
    'walidd_working_ability': workingAbility.value,
    'walidd_locations': painLocations.toList(),
    'walidd_pain_days': int.parse(painDaysController.text),
    'symptoms': selectedSymptoms.toList(),
    if (notesController.text.trim().isNotEmpty)
      'notes': notesController.text.trim(),
  };

  Future<void> submitPeriod() async {
    if (isSavingPeriod.value || periodSuccess.value.isNotEmpty) return;
    periodError.value = validatePeriod() ?? '';
    if (periodError.value.isNotEmpty) return;
    isSavingPeriod.value = true;
    try {
      final response = await ApiService.post(
        ApiConstants.period,
        body: periodPayload(),
      );
      if (!response.success || response.data is! Map) {
        periodError.value =
            response.message ??
            'Catatan belum dapat disimpan. Periksa riwayat sebelum mencoba lagi.';
        return;
      }
      final data = response.data as Map;
      if (data['period_log'] is! Map) {
        periodError.value =
            'Konfirmasi penyimpanan tidak lengkap. Periksa riwayat sebelum mengirim ulang.';
        return;
      }
      final points = int.tryParse('${data['points_earned']}');
      periodSuccess.value =
          'Catatan haid berhasil disimpan.${points == null ? '' : ' +$points poin.'}';
      await fetchSummary(forceRefresh: true);
      await Future.wait([fetchPeriodHistory(), fetchPeriodPrediction()]);
      if (Get.isRegistered<HomeController>()) {
        unawaited(
          Get.find<HomeController>().fetchDashboard(forceRefresh: true),
        );
      }
      if (Get.isRegistered<ProfileController>()) {
        unawaited(
          Get.find<ProfileController>().fetchProfile(forceRefresh: true),
        );
      }
    } catch (_) {
      periodError.value =
          'Konfirmasi penyimpanan tidak dapat dibaca. Periksa riwayat sebelum mencoba lagi.';
    } finally {
      isSavingPeriod.value = false;
    }
  }

  void resetPeriodForm() {
    if (isSavingPeriod.value) return;
    startDate.value = null;
    endDate.value = null;
    menarcheAgeController.clear();
    isRegular.value = null;
    cycleLengthController.text = '28';
    periodDurationController.text = '5';
    flowLevel.value = 'sedang';
    flowColor.value = 'Merah Terang';
    bloodConsistency.value = 'Sedang / Normal';
    painScore.value = 0;
    workingAbility.value = 0;
    painDaysController.text = '0';
    painLocations.clear();
    selectedSymptoms.clear();
    notesController.clear();
    includePbac.value = false;
    pbacCounts.updateAll((_, value) => 0);
    invalidatePbac();
    invalidateWalidd();
    periodError.value = '';
    periodSuccess.value = '';
  }

  Future<void> calculateBmi() async {
    final weight = double.tryParse(weightController.text.trim());
    final height = double.tryParse(heightController.text.trim());

    if (weight == null || height == null || weight <= 0 || height <= 0) {
      Get.snackbar(
        'Perhatian',
        'Masukkan berat dan tinggi badan yang valid.',
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final response = await ApiService.post(
      ApiConstants.bmi,
      body: {'weight_kg': weight, 'height_cm': height},
    );

    isLoading.value = false;

    if (response.success && response.data != null) {
      Map<String, dynamic>? bmiData;
      if (response.data is Map<String, dynamic>) {
        bmiData = response.data['bmi_log'] ?? response.data;
      }
      if (bmiData != null) {
        bmiResult.value = BmiRecordModel.fromJson(bmiData);
      }
      Get.snackbar(
        'Perhitungan Berhasil',
        'Data IMT dan rekomendasi gizi berhasil disimpan.',
        backgroundColor: Colors.teal.shade700,
        colorText: Colors.white,
      );
      fetchSummary(forceRefresh: true);
      fetchBmiHistory();
    } else {
      // Fallback kalkulasi mandiri jika offline
      final heightInMeters = height / 100;
      final score = weight / (heightInMeters * heightInMeters);
      String category = 'Normal';
      String advice =
          'Pertahankan pola makan seimbang dan aktivitas fisik teratur untuk menjaga kestabilan hormonal.';
      if (score < 18.5) {
        category = 'Kekurangan Berat Badan';
        advice =
            'Tingkatkan asupan kalori bernutrisi dan protein untuk mendukung pematangan sel telur dan siklus haid normal.';
      } else if (score >= 25.0 && score < 30.0) {
        category = 'Overweight';
        advice =
            'Perhatikan porsi makan dan perbanyak serat untuk mencegah resistensi insulin yang dapat memengaruhi siklus reproduksi.';
      } else if (score >= 30.0) {
        category = 'Obesitas';
        advice =
            'Konsultasikan dengan dokter gizi untuk program penurunan berat badan aman guna memelihara kesehatan sistem reproduksi.';
      }

      bmiResult.value = BmiRecordModel(
        weightKg: weight,
        heightCm: height,
        bmiScore: double.parse(score.toStringAsFixed(1)),
        category: category,
        advice: advice,
      );
    }
  }

  Future<void> fetchBloodGuides({bool forceRefresh = false}) async {
    if (isBloodLoading.value) return;
    isBloodLoading.value = true;
    bloodError.value = '';
    try {
      final response = await ApiService.get(
        ApiConstants.bloodGuide,
        auth: false,
      );
      if (!response.success) {
        bloodError.value =
            response.message ?? 'Panduan darah belum dapat dimuat.';
        return;
      }
      final data = response.data;
      final list = data is List
          ? data
          : data is Map
          ? data['guides'] ?? data['data']
          : null;
      if (list is! List) throw const FormatException();
      bloodGuides.assignAll(
        list.map(
          (e) => BloodGuideModel.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
      );
    } catch (_) {
      bloodError.value = 'Format panduan darah tidak dapat dibaca. Coba lagi.';
    } finally {
      isBloodLoading.value = false;
    }
  }

  Future<void> fetchHygieneGuides({bool forceRefresh = false}) async {
    if (isHygieneLoading.value) return;
    isHygieneLoading.value = true;
    hygieneError.value = '';
    try {
      final response = await ApiService.get(
        ApiConstants.hygieneGuide,
        auth: false,
      );
      if (!response.success) {
        hygieneError.value =
            response.message ?? 'Panduan kebersihan belum dapat dimuat.';
        return;
      }
      final data = response.data;
      final list = data is List
          ? data
          : data is Map
          ? data['tips'] ?? data['guides'] ?? data['data']
          : null;
      if (list is! List) throw const FormatException();
      hygieneGuides.assignAll(
        list.map(
          (e) =>
              HygieneGuideModel.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
      );
    } catch (_) {
      hygieneError.value =
          'Format panduan kebersihan tidak dapat dibaca. Coba lagi.';
    } finally {
      isHygieneLoading.value = false;
    }
  }

  @override
  void onClose() {
    menarcheAgeController.dispose();
    painDaysController.dispose();
    cycleLengthController.dispose();
    periodDurationController.dispose();
    notesController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.onClose();
  }
}
