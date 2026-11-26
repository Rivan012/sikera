import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
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

  // Global Post-Test Status (muncul 3 hari setelah menyelesaikan semua modul)
  final posttestStatus = Rxn<GlobalPosttestStatus>();
  DateTime Function() nowProvider = DateTime.now;

  // Module Detail
  final currentModule = Rxn<ModuleDetailModel>();

  // Pretest / Posttest
  final questions = <QuestionModel>[].obs;
  final answers = <String, String>{}.obs; // questionId: optionLabel
  final isSubmitting = false.obs;
  final testResult = Rxn<Map<String, dynamic>>();

  // Active Topic
  final currentTopic = Rxn<TopicModel>();

  GlobalPosttestStatus get effectivePosttestStatus {
    final total = modules.length;
    final completed = modules.where((m) => m.isTopicsCompleted).length;
    final allFromModules = total > 0 && completed == total;
    final server = posttestStatus.value;

    if (server != null) {
      final resolvedTotal = server.totalModules > 0 ? server.totalModules : total;
      final resolvedCompleted = server.totalModules > 0
          ? server.completedModules
          : completed;
      final resolvedAllDone =
          server.allModulesCompleted || (resolvedTotal > 0 && resolvedCompleted >= resolvedTotal);
      final fallbackCompletedAt =
          server.allModulesCompletedAt ??
          _latestModuleCompletedAt() ??
          (resolvedAllDone ? StorageService.getAllModulesCompletedAt() : null);

      return server.copyWith(
        totalModules: resolvedTotal,
        completedModules: resolvedCompleted,
        allModulesCompleted: resolvedAllDone,
        allModulesCompletedAt: fallbackCompletedAt,
        hasCompletedPosttest:
            server.hasCompletedPosttest || StorageService.globalPosttestCompleted,
      );
    }

    final completedAt = allFromModules
        ? (_latestModuleCompletedAt() ?? StorageService.getAllModulesCompletedAt())
        : null;

    return GlobalPosttestStatus(
      totalModules: total,
      completedModules: completed,
      allModulesCompleted: allFromModules,
      allModulesCompletedAt: completedAt,
      hasCompletedPosttest: StorageService.globalPosttestCompleted,
      delayDays: GlobalPosttestStatus.requiredDelayDays,
    );
  }

  DateTime? _latestModuleCompletedAt() {
    DateTime? latest;
    for (final module in modules) {
      final timestamp = module.completedAt;
      if (timestamp != null && (latest == null || timestamp.isAfter(latest))) {
        latest = timestamp;
      }
    }
    return latest;
  }

  Future<void> _syncCompletionTimestamp({
    GlobalPosttestStatus? serverStatus,
  }) async {
    final total = modules.length;
    final completed = modules.where((m) => m.isTopicsCompleted).length;
    final allDone =
        (serverStatus?.allModulesCompleted ?? false) ||
        (total > 0 && completed == total);

    if (allDone) {
      final existing = StorageService.getAllModulesCompletedAt();
      final candidate =
          serverStatus?.allModulesCompletedAt ??
          _latestModuleCompletedAt() ??
          existing ??
          nowProvider();
      if (existing == null || serverStatus?.allModulesCompletedAt != null) {
        await StorageService.setAllModulesCompletedAt(candidate);
      }
    } else if (total > 0) {
      await StorageService.clearAllModulesCompletedAt();
    }

    if (serverStatus?.hasCompletedPosttest == true) {
      await StorageService.setGlobalPosttestCompleted(true);
    }
  }

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
      GlobalPosttestStatus? embeddedPosttest;
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['modules'] is List) {
          rawList = map['modules'] as List;
        } else if (map['data'] is List) {
          rawList = map['data'] as List;
        }
        final rawPosttest = map['posttest'] ?? map['posttest_status'];
        if (rawPosttest is Map<String, dynamic>) {
          embeddedPosttest = GlobalPosttestStatus.fromJson(rawPosttest);
        }
      }

      if (rawList != null) {
        modules.value = rawList
            .map((e) => DashboardModuleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (embeddedPosttest != null) {
        posttestStatus.value = embeddedPosttest;
      }
      await _syncCompletionTimestamp(serverStatus: embeddedPosttest);
      if (embeddedPosttest == null) {
        await fetchGlobalPosttestStatus();
      }
    } else {
      if (modules.isEmpty) {
        errorMessage.value = response.message ?? 'Gagal memuat daftar modul.';
      }
    }
  }

  Future<void> fetchGlobalPosttestStatus() async {
    final response = await ApiService.get(ApiConstants.globalPosttestStatus);
    if (response.success && response.data is Map<String, dynamic>) {
      final parsed = GlobalPosttestStatus.fromJson(
        response.data as Map<String, dynamic>,
      );
      posttestStatus.value = parsed;
      await _syncCompletionTimestamp(serverStatus: parsed);
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
        backgroundColor: AppTheme.warning,
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
        'Pre-Test Selesai',
        'Akses materi modul berhasil dibuka. Silakan pelajari submateri berikut.',
        backgroundColor: AppTheme.success,
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
        backgroundColor: AppTheme.error,
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

  Future<void> fetchGlobalPosttest() async {
    isLoading.value = true;
    errorMessage.value = '';
    answers.clear();

    final status = effectivePosttestStatus;
    final availability = status.availabilityAt(nowProvider());
    if (availability == PosttestAvailability.lockedIncompleteModules) {
      isLoading.value = false;
      errorMessage.value =
          'Selesaikan seluruh modul terlebih dahulu. Post-Test akan terbuka ${status.delayDays} hari setelah semua modul tuntas.';
      return;
    }
    if (availability == PosttestAvailability.waitingCooldown) {
      isLoading.value = false;
      errorMessage.value =
          'Post-Test Akhir belum dapat dikerjakan. Tersedia dalam ${status.formatRemaining(nowProvider())}.';
      return;
    }

    final response = await ApiService.get(ApiConstants.globalPosttest);

    isLoading.value = false;

    if (response.success && response.data != null) {
      final raw = response.data;
      List? rawQuestions;
      if (raw is Map<String, dynamic> && raw['questions'] is List) {
        rawQuestions = raw['questions'] as List;
      } else if (raw is List) {
        rawQuestions = raw;
      }
      if (rawQuestions != null) {
        questions.value = rawQuestions
            .whereType<Map<String, dynamic>>()
            .map(QuestionModel.fromJson)
            .toList();
      }
    } else {
      errorMessage.value = response.message ?? 'Gagal memuat soal Post-Test Akhir.';
    }
  }

  Future<void> submitGlobalPosttest() async {
    if (answers.length < questions.length) {
      Get.snackbar(
        'Perhatian',
        'Harap jawab seluruh pertanyaan sebelum mengumpulkan.',
        backgroundColor: AppTheme.warning,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    final response = await ApiService.post(
      ApiConstants.globalPosttest,
      body: {'answers': answers},
    );

    isSubmitting.value = false;

    if (response.success && response.data != null) {
      final resultMap = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      testResult.value = resultMap;
      await StorageService.setGlobalPosttestCompleted(true);
      posttestStatus.value = effectivePosttestStatus.copyWith(
        hasCompletedPosttest: true,
        pretestScore: resultMap['pretest_score'] is int
            ? resultMap['pretest_score'] as int
            : int.tryParse(resultMap['pretest_score']?.toString() ?? ''),
        posttestScore: resultMap['posttest_score'] is int
            ? resultMap['posttest_score'] as int
            : int.tryParse(
                (resultMap['posttest_score'] ?? resultMap['score'])?.toString() ??
                    '',
              ),
        nGainScore: resultMap['n_gain_score'] is num
            ? (resultMap['n_gain_score'] as num).toDouble()
            : double.tryParse(resultMap['n_gain_score']?.toString() ?? ''),
        effectivenessCategory: resultMap['effectiveness_category']?.toString(),
      );
      refreshAllProgress();
      Get.offNamed(
        Routes.EDUCATION_RESULT,
        arguments: {
          'isPretest': false,
          'isGlobalPosttest': true,
          'data': resultMap,
        },
      );
    } else {
      Get.snackbar(
        'Gagal Submit',
        response.message ?? 'Terjadi kesalahan saat mengumpulkan post-test.',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
      );
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
        backgroundColor: AppTheme.warning,
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
        backgroundColor: AppTheme.error,
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
