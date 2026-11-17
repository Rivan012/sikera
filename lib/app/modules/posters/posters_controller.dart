import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/community_model.dart';

class PostersController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final posters = <PosterModel>[].obs;
  final selectedPoster = Rxn<PosterModel>();

  @override
  void onInit() {
    super.onInit();
    fetchPosters();
  }

  Future<void> fetchPosters({bool forceRefresh = false}) async {
    if (posters.isEmpty || forceRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.posters);

    isLoading.value = false;

    if (response.success && response.data != null) {
      List? rawList;
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['posters'] is List) {
          rawList = map['posters'] as List;
        } else if (map['data'] is List) {
          rawList = map['data'] as List;
        }
      }

      if (rawList != null) {
        posters.value = rawList
            .map((e) => PosterModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else {
      if (posters.isEmpty) {
        errorMessage.value = response.message ?? 'Gagal memuat daftar poster.';
      }
    }
  }

  Future<void> downloadPoster(int id) async {
    final response = await ApiService.post(ApiConstants.posterDownload(id));
    if (response.success) {
      Get.snackbar(
        'Berhasil',
        'Unduhan poster telah dicatat dalam sistem.',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
      );
    }
  }

  Future<void> sharePoster(int id) async {
    final response = await ApiService.post(ApiConstants.posterShare(id));
    if (response.success) {
      Get.snackbar(
        'Berhasil',
        'Terima kasih telah menyebarkan edukasi kesehatan reproduksi.',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
      );
    }
  }
}
