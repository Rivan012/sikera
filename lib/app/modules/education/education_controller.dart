import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/models/module_model.dart';
import '../../routes/app_pages.dart';
import '../home/home_controller.dart';
import '../profile/profile_controller.dart';

class EducationController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Module List
  final modules = <DashboardModuleModel>[].obs;

  // Module Detail
  final currentModule = Rxn<ModuleDetailModel>();

  // Pretest / Posttest
  final questions = <QuestionModel>[].obs;
  final answers = <String, String>{}.obs; // questionId: optionLabel
  final isSubmitting = false.obs;
  final testResult = Rxn<Map<String, dynamic>>();

  // Active Topic
  final currentTopic = Rxn<TopicModel>();

  @override
  void onInit() {
    super.onInit();
    fetchModules();
  }

  Future<void> fetchModules({bool forceRefresh = false}) async {
    if (modules.isEmpty || forceRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.modules);

    isLoading.value = false;

    if (response.success && response.data != null) {
      List? rawList;
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['modules'] is List) {
          rawList = map['modules'] as List;
        } else if (map['data'] is List) {
          rawList = map['data'] as List;
        }
      }

      if (rawList != null) {
        modules.value = rawList
            .map((e) => DashboardModuleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else {
      if (modules.isEmpty) {
        errorMessage.value = response.message ?? 'Gagal memuat daftar modul.';
      }
    }
  }

  Future<void> fetchModuleDetail(int id) async {
    if (currentModule.value == null || currentModule.value!.id != id) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.moduleDetail(id));

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        currentModule.value = ModuleDetailModel.fromJson(response.data);
      }
    } else {
      errorMessage.value = response.message ?? 'Gagal memuat detail modul.';
    }
  }

  Future<void> fetchPretest(int moduleId) async {
    isLoading.value = true;
    errorMessage.value = '';
    answers.clear();

    final response = await ApiService.get(ApiConstants.pretest(moduleId));

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic> && response.data['questions'] is List) {
        questions.value = (response.data['questions'] as List)
            .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else {
      errorMessage.value = response.message ?? 'Gagal memuat soal pre-test.';
    }
  }

  Future<void> submitPretest(int moduleId) async {
    if (answers.length < questions.length) {
      Get.snackbar(
        'Perhatian',
        'Harap jawab seluruh pertanyaan sebelum mengumpulkan.',
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    final response = await ApiService.post(
      ApiConstants.pretest(moduleId),
      body: {'answers': answers},
    );

    isSubmitting.value = false;

    if (response.success && response.data != null) {
      testResult.value = response.data is Map<String, dynamic> ? response.data : {};
      await fetchModuleDetail(moduleId);
      refreshAllProgress(moduleId);
      Get.offNamed(Routes.EDUCATION_MODULE_DETAIL, arguments: moduleId);
      Get.snackbar(
        'Pre-Test Selesai!',
        'Akses materi modul berhasil dibuka. Silakan pelajari submateri berikut.',
        backgroundColor: const Color(0xFF0F766E),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      Get.snackbar(
        'Gagal Submit',
        response.message ?? 'Terjadi kesalahan saat mengumpulkan pre-test.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchTopic(int moduleId, int topicId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.topic(moduleId, topicId));

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic> && response.data['topic'] is Map<String, dynamic>) {
        currentTopic.value = TopicModel.fromJson(response.data['topic']);
      }
    } else {
      errorMessage.value = response.message ?? 'Gagal memuat submateri.';
    }
  }

  Future<void> fetchPosttest(int moduleId) async {
    isLoading.value = true;
    errorMessage.value = '';
    answers.clear();

    final response = await ApiService.get(ApiConstants.posttest(moduleId));

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic> && response.data['questions'] is List) {
        questions.value = (response.data['questions'] as List)
            .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else {
      errorMessage.value = response.message ?? 'Gagal memuat soal post-test.';
    }
  }

  Future<void> submitPosttest(int moduleId) async {
    if (answers.length < questions.length) {
      Get.snackbar(
        'Perhatian',
        'Harap jawab seluruh pertanyaan sebelum mengumpulkan.',
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    final response = await ApiService.post(
      ApiConstants.posttest(moduleId),
      body: {'answers': answers},
    );

    isSubmitting.value = false;

    if (response.success && response.data != null) {
      testResult.value = response.data is Map<String, dynamic> ? response.data : {};
      refreshAllProgress(moduleId);
      Get.offNamed(Routes.EDUCATION_RESULT, arguments: {
        'isPretest': false,
        'moduleId': moduleId,
        'data': response.data,
      });
    } else {
      Get.snackbar(
        'Gagal Submit',
        response.message ?? 'Terjadi kesalahan saat mengumpulkan post-test.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshAllProgress([int? moduleId]) async {
    if (moduleId != null) {
      await fetchModuleDetail(moduleId);
    }
    await fetchModules(forceRefresh: true);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchDashboard(forceRefresh: true);
    }
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().fetchProfile(forceRefresh: true);
    }
  }
}
