import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../data/models/community_model.dart';

class CasesController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final cases = <CaseStudyModel>[].obs;
  final selectedCase = Rxn<CaseStudyModel>();

  @override
  void onInit() {
    super.onInit();
    fetchCases();
  }

  Future<void> fetchCases({bool forceRefresh = false}) async {
    if (cases.isEmpty || forceRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.cases);

    isLoading.value = false;

    if (response.success && response.data != null) {
      List? rawList;
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['case_studies'] is List) {
          rawList = map['case_studies'] as List;
        } else if (map['data'] is List) {
          rawList = map['data'] as List;
        }
      }

      if (rawList != null) {
        cases.value = rawList
            .map((e) => CaseStudyModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else {
      if (cases.isEmpty) {
        errorMessage.value = response.message ?? 'Gagal memuat daftar studi kasus.';
      }
    }
  }

  Future<void> fetchCaseDetail(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.caseDetail(id));

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final target = map['case_study'] is Map<String, dynamic>
            ? map['case_study'] as Map<String, dynamic>
            : map;
        selectedCase.value = CaseStudyModel.fromJson(target);
      }
    } else {
      errorMessage.value = response.message ?? 'Gagal memuat detail kasus.';
    }
  }
}
