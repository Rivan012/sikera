import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user_json';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyOnboarding = 'onboarding_completed';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (kDebugMode && const bool.fromEnvironment('RESET_ONBOARDING')) {
      await resetOnboarding();
    }
  }

  static bool get onboardingCompleted =>
      _prefs?.getBool(_keyOnboarding) ?? false;

  static String? get currentAccountId {
    try {
      final user = jsonDecode(getUserJson() ?? '{}');
      final id = user is Map ? int.tryParse('${user['id']}') : null;
      return id != null && id > 0 ? '$id' : null;
    } catch (_) {
      return null;
    }
  }

  static bool get termsPrivacyAccepted {
    final id = currentAccountId;
    return hasToken &&
        id != null &&
        (_prefs?.getBool('terms_privacy_accepted_$id') ?? false);
  }

  static Future<void> acceptTermsPrivacy() async {
    final id = currentAccountId;
    if (!hasToken || id == null) {
      throw StateError('Akun tidak tersedia. Masuk kembali.');
    }
    final key = 'terms_privacy_accepted_$id';
    try {
      if (await _prefs?.setBool(key, true) != true) {
        throw StateError('Persetujuan belum tersimpan.');
      }
    } catch (_) {
      await _prefs?.remove(key);
      rethrow;
    }
  }

  static Future<void> completeOnboarding() async {
    if (await _prefs?.setBool(_keyOnboarding, true) != true) {
      throw StateError('Status onboarding gagal disimpan.');
    }
  }

  static Future<void> resetOnboarding() async {
    if (await _prefs?.remove(_keyOnboarding) != true) {
      throw StateError('Status onboarding gagal direset.');
    }
  }

  static Future<void> setToken(String token) async {
    await _prefs?.setString(_keyToken, token);
  }

  static String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  static Future<void> setUserJson(String userJson) async {
    await _prefs?.setString(_keyUser, userJson);
  }

  static String? getUserJson() {
    return _prefs?.getString(_keyUser);
  }

  static Future<void> setThemeMode(String mode) async {
    await _prefs?.setString(_keyThemeMode, mode);
  }

  static String? getThemeMode() {
    return _prefs?.getString(_keyThemeMode);
  }

  static Future<void> clearAuth() async {
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyUser);
  }

  static bool get hasToken => getToken() != null && getToken()!.isNotEmpty;

  static String _scopedKey(String prefix) {
    final id = currentAccountId ?? 'guest';
    return '${prefix}_$id';
  }

  static DateTime? getAllModulesCompletedAt() {
    final raw = _prefs?.getString(_scopedKey('all_modules_completed_at'));
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  static Future<void> setAllModulesCompletedAt(DateTime timestamp) async {
    await _prefs?.setString(
      _scopedKey('all_modules_completed_at'),
      timestamp.toUtc().toIso8601String(),
    );
  }

  static Future<void> clearAllModulesCompletedAt() async {
    await _prefs?.remove(_scopedKey('all_modules_completed_at'));
  }

  static bool get globalPosttestCompleted =>
      _prefs?.getBool(_scopedKey('global_posttest_completed')) ?? false;

  static Future<void> setGlobalPosttestCompleted(bool completed) async {
    await _prefs?.setBool(_scopedKey('global_posttest_completed'), completed);
  }
}
