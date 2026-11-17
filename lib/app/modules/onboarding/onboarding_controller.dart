import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_pages.dart';
import 'onboarding_data.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  bool _isChangingPage = false;

  bool get isLastPage => currentPage.value == onboardingPages.length - 1;

  Future<void> next({bool reduceMotion = false}) async {
    if (_isChangingPage || isSaving.value || !pageController.hasClients) return;
    if (isLastPage) {
      await complete();
      return;
    }
    _isChangingPage = true;
    try {
      if (reduceMotion) {
        pageController.jumpToPage(currentPage.value + 1);
      } else {
        await pageController.animateToPage(
          currentPage.value + 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
        );
      }
    } finally {
      _isChangingPage = false;
    }
  }

  Future<void> complete() async {
    if (isSaving.value) return;
    isSaving.value = true;
    errorMessage.value = '';
    try {
      await StorageService.completeOnboarding();
      if (!isClosed) Get.offAllNamed(Routes.LOGIN);
    } catch (_) {
      if (!isClosed) {
        errorMessage.value = 'Status belum tersimpan. Coba lagi.';
        isSaving.value = false;
      }
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
