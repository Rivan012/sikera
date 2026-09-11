import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../data/models/selfcare_model.dart';

class SelfcareController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final summaryData = Rxn<Map<String, dynamic>>();
  final isFemale = true.obs;

  // Period Tracker Form
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final cycleLengthController = TextEditingController(text: '28');
  final periodDurationController = TextEditingController(text: '5');
  final flowLevel = 'sedang'.obs;
  final flowColor = 'Merah Terang'.obs;
  final painScore = 3.obs;
  final selectedSymptoms = <String>[].obs;
  final notesController = TextEditingController();

  // BMI Form
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final bmiResult = Rxn<BmiRecordModel>();

  // Guides
  final bloodGuides = <dynamic>[].obs;
  final hygieneGuides = <dynamic>[].obs;

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

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary({bool forceRefresh = false}) async {
    if (summaryData.value == null || forceRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.selfcareSummary);

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        summaryData.value = response.data;
        if (response.data['is_female'] != null) {
          isFemale.value = response.data['is_female'] == true;
        }
      }
    } else {
      if (summaryData.value == null) {
        errorMessage.value = response.message ?? 'Gagal memuat ringkasan self-care.';
      }
    }
  }

  Future<void> submitPeriod() async {
    if (startDate.value == null) {
      Get.snackbar(
        'Perhatian',
        'Tanggal mulai haid wajib dipilih.',
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final record = PeriodRecordModel(
      startDate: "${startDate.value!.year.toString().padLeft(4, '0')}-${startDate.value!.month.toString().padLeft(2, '0')}-${startDate.value!.day.toString().padLeft(2, '0')}",
      endDate: endDate.value != null
          ? "${endDate.value!.year.toString().padLeft(4, '0')}-${endDate.value!.month.toString().padLeft(2, '0')}-${endDate.value!.day.toString().padLeft(2, '0')}"
          : null,
      cycleLength: int.tryParse(cycleLengthController.text.trim()) ?? 28,
      periodDuration: int.tryParse(periodDurationController.text.trim()) ?? 5,
      flowLevel: flowLevel.value,
      flowColor: flowColor.value,
      nrsPainScore: painScore.value,
      symptoms: selectedSymptoms.toList(),
      notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
    );

    final response = await ApiService.post(
      ApiConstants.period,
      body: record.toJson(),
    );

    isLoading.value = false;

    if (response.success) {
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Catatan siklus haid berhasil disimpan.',
        backgroundColor: Colors.teal.shade700,
        colorText: Colors.white,
      );
      fetchSummary();
    } else {
      Get.snackbar(
        'Gagal Menyimpan',
        response.message ?? 'Terjadi kesalahan.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
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
      body: {
        'weight_kg': weight,
        'height_cm': height,
      },
    );

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        bmiResult.value = BmiRecordModel.fromJson(response.data);
      }
      fetchSummary();
    } else {
      // Fallback kalkulasi mandiri jika endpoint offline
      final heightInMeters = height / 100;
      final score = weight / (heightInMeters * heightInMeters);
      String category = 'Normal';
      if (score < 18.5) {
        category = 'Berat Kurang';
      } else if (score >= 25.0 && score < 30.0) {
        category = 'Berat Lebih (Overweight)';
      } else if (score >= 30.0) {
        category = 'Obesitas';
      }

      bmiResult.value = BmiRecordModel(
        weightKg: weight,
        heightCm: height,
        bmiScore: double.parse(score.toStringAsFixed(1)),
        category: category,
      );
    }
  }

  Future<void> fetchBloodGuides({bool forceRefresh = false}) async {
    if (bloodGuides.isEmpty || forceRefresh) {
      isLoading.value = true;
    }
    final response = await ApiService.get(ApiConstants.bloodGuide);
    isLoading.value = false;
    if (response.success && response.data != null) {
      List? list;
      if (response.data is List) {
        list = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['guides'] is List) {
          list = map['guides'] as List;
        } else if (map['data'] is List) {
          list = map['data'] as List;
        }
      }
      if (list != null) {
        bloodGuides.value = list;
      }
    }
  }

  Future<void> fetchHygieneGuides({bool forceRefresh = false}) async {
    if (hygieneGuides.isEmpty || forceRefresh) {
      isLoading.value = true;
    }
    final response = await ApiService.get(ApiConstants.hygieneGuide);
    isLoading.value = false;
    if (response.success && response.data != null) {
      List? list;
      if (response.data is List) {
        list = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['guides'] is List) {
          list = map['guides'] as List;
        } else if (map['data'] is List) {
          list = map['data'] as List;
        }
      }
      if (list != null) {
        hygieneGuides.value = list;
      }
    }
  }

  @override
  void onClose() {
    cycleLengthController.dispose();
    periodDurationController.dispose();
    notesController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.onClose();
  }
}
