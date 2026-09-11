import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user_json';
  static const String _keyThemeMode = 'theme_mode';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
}
