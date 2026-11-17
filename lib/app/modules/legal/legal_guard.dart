import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_pages.dart';

class LegalGuard extends GetMiddleware {
  LegalGuard({this.consentPage = false});
  final bool consentPage;

  @override
  RouteSettings? redirect(String? route) {
    if (!StorageService.hasToken) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    if (!consentPage && !StorageService.termsPrivacyAccepted) {
      return const RouteSettings(name: Routes.TERMS_PRIVACY_CONSENT);
    }
    return null;
  }
}
