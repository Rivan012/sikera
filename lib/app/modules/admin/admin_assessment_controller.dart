import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/admin_assessment_model.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/models/module_model.dart';

class AdminAssessmentController extends GetxController {
  // Modules for Pre-Test management (per module)
  final modules = <DashboardModuleModel>[].obs;
  final isLoadingModules = false.obs;
  final modulesError = ''.obs;
  final selectedModuleId = RxnInt();

  // Pre-Test questions (per selected module)
  final pretestQuestions = <AdminQuestionModel>[].obs;
  final isLoadingPretests = false.obs;
  final pretestError = ''.obs;

  // Post-Test questions (separate / global)
  final posttestQuestions = <AdminQuestionModel>[].obs;
  final isLoadingPosttests = false.obs;
  final posttestError = ''.obs;
  final posttestDelayDays = GlobalPosttestStatus.requiredDelayDays.obs;

  // Mutation states
  final isSaving = false.obs;
  final formErrorMessage = ''.obs;
  final deletingQuestionId = RxnInt();

  DashboardModuleModel? get selectedModule {
    final id = selectedModuleId.value;
    if (id == null) return modules.firstOrNull;
    return modules.firstWhereOrNull((m) => m.id == id) ?? modules.firstOrNull;
  }

  Future<void> loadPretestTab({bool forceRefresh = false}) async {
    await fetchModules(forceRefresh: forceRefresh);
    final activeId = selectedModule?.id;
    if (activeId != null) {
      selectedModuleId.value = activeId;
      await fetchPretestQuestions(activeId, forceRefresh: forceRefresh);
    }
  }

  Future<void> fetchModules({bool forceRefresh = false}) async {
    if (modules.isNotEmpty && !forceRefresh) return;
    if (modules.isEmpty || forceRefresh) {
      isLoadingModules.value = true;
    }
    modulesError.value = '';

    final response = await ApiService.get(ApiConstants.modules);

    isLoadingModules.value = false;

    if (response.success && response.data != null) {
      final rawList = _extractList(response.data, preferredKeys: ['modules', 'data']);
      if (rawList != null) {
        modules.value = rawList
            .whereType<Map<String, dynamic>>()
            .map(DashboardModuleModel.fromJson)
            .toList();
        if (modules.isNotEmpty &&
            (selectedModuleId.value == null ||
                !modules.any((m) => m.id == selectedModuleId.value))) {
          selectedModuleId.value = modules.first.id;
        }
      }
    } else {
      if (modules.isEmpty) {
        modulesError.value =
            response.message ?? 'Gagal memuat daftar modul untuk Pre-Test.';
      }
    }
  }

  Future<void> selectModule(int moduleId) async {
    if (selectedModuleId.value == moduleId &&
        pretestQuestions.isNotEmpty &&
        pretestError.value.isEmpty) {
      return;
    }
    selectedModuleId.value = moduleId;
    await fetchPretestQuestions(moduleId, forceRefresh: true);
  }

  Future<void> fetchPretestQuestions(
    int moduleId, {
    bool forceRefresh = false,
  }) async {
    isLoadingPretests.value = true;
    pretestError.value = '';

    final response = await ApiService.get(
      ApiConstants.adminModulePretests(moduleId),
    );

    isLoadingPretests.value = false;

    if (response.success && response.data != null) {
      final rawList = _extractList(
        response.data,
        preferredKeys: ['questions', 'pretests', 'data'],
      );
      pretestQuestions.value = (rawList ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => AdminQuestionModel.fromJson(
              item,
              defaultKind: AssessmentKind.pretest,
              fallbackModuleId: moduleId,
            ),
          )
          .toList();
    } else {
      pretestQuestions.clear();
      pretestError.value =
          response.message ?? 'Gagal memuat daftar soal Pre-Test modul.';
    }
  }

  Future<void> fetchPosttestQuestions({bool forceRefresh = false}) async {
    if (posttestQuestions.isEmpty || forceRefresh) {
      isLoadingPosttests.value = true;
    }
    posttestError.value = '';

    final response = await ApiService.get(ApiConstants.adminPosttests);

    isLoadingPosttests.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final delay = map['unlock_delay_days'] ?? map['delay_days'];
        final parsedDelay = delay is int
            ? delay
            : int.tryParse(delay?.toString() ?? '');
        if (parsedDelay != null && parsedDelay > 0) {
          posttestDelayDays.value = parsedDelay;
        }
      }

      final rawList = _extractList(
        response.data,
        preferredKeys: ['questions', 'posttests', 'data'],
      );
      posttestQuestions.value = (rawList ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => AdminQuestionModel.fromJson(
              item,
              defaultKind: AssessmentKind.posttest,
            ),
          )
          .toList();
    } else {
      posttestQuestions.clear();
      posttestError.value =
          response.message ?? 'Gagal memuat daftar soal Post-Test.';
    }
  }

  Future<bool> saveQuestion({
    required AssessmentKind kind,
    int? moduleId,
    int? editingId,
    required String questionText,
    required List<QuestionOption> options,
    required String correctAnswer,
  }) async {
    if (isSaving.value) return false;
    if (kind == AssessmentKind.pretest && (moduleId == null || moduleId <= 0)) {
      formErrorMessage.value = 'Pilih modul untuk soal Pre-Test.';
      return false;
    }

    isSaving.value = true;
    formErrorMessage.value = '';

    final model = AdminQuestionModel(
      id: editingId ?? 0,
      moduleId: kind == AssessmentKind.pretest ? moduleId : null,
      kind: kind,
      questionText: questionText.trim(),
      options: options,
      correctAnswer: correctAnswer.trim().toUpperCase(),
    );

    final payload = model.toPayload();
    final ApiResponse<dynamic> response;

    if (kind == AssessmentKind.pretest) {
      response = editingId == null
          ? await ApiService.post(
              ApiConstants.adminModulePretests(moduleId!),
              body: payload,
            )
          : await ApiService.put(
              ApiConstants.adminModulePretestItem(moduleId!, editingId),
              body: payload,
            );
    } else {
      response = editingId == null
          ? await ApiService.post(ApiConstants.adminPosttests, body: payload)
          : await ApiService.put(
              ApiConstants.adminPosttestItem(editingId),
              body: payload,
            );
    }

    isSaving.value = false;

    if (response.success) {
      if (kind == AssessmentKind.pretest && moduleId != null) {
        selectedModuleId.value = moduleId;
        await fetchPretestQuestions(moduleId, forceRefresh: true);
      } else {
        await fetchPosttestQuestions(forceRefresh: true);
      }
      return true;
    }

    formErrorMessage.value =
        response.message ?? 'Gagal menyimpan soal. Periksa koneksi lalu coba lagi.';
    return false;
  }

  Future<bool> deleteQuestion(AdminQuestionModel question) async {
    if (deletingQuestionId.value != null) return false;
    deletingQuestionId.value = question.id;

    final ApiResponse<dynamic> response;
    if (question.kind == AssessmentKind.pretest) {
      final moduleId = question.moduleId ?? selectedModuleId.value ?? 0;
      response = await ApiService.delete(
        ApiConstants.adminModulePretestItem(moduleId, question.id),
      );
    } else {
      response = await ApiService.delete(
        ApiConstants.adminPosttestItem(question.id),
      );
    }

    deletingQuestionId.value = null;

    if (response.success) {
      if (question.kind == AssessmentKind.pretest) {
        pretestQuestions.removeWhere((q) => q.id == question.id);
      } else {
        posttestQuestions.removeWhere((q) => q.id == question.id);
      }
      Get.snackbar(
        'Soal Dihapus',
        question.kind == AssessmentKind.pretest
            ? 'Soal Pre-Test berhasil dihapus.'
            : 'Soal Post-Test berhasil dihapus.',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    }

    Get.snackbar(
      'Gagal Menghapus',
      response.message ?? 'Soal gagal dihapus. Silakan coba lagi.',
      backgroundColor: AppTheme.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
    return false;
  }

  List<dynamic>? _extractList(
    dynamic data, {
    required List<String> preferredKeys,
  }) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in preferredKeys) {
        if (data[key] is List) {
          return data[key] as List;
        }
      }
    }
    return null;
  }
}
