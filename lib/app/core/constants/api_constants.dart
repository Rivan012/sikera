import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static const String _apiBaseUrlDefine = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String _googleAndroidClientIdDefine = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
  );
  static const String _googleIosClientIdDefine = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );
  static const String _googleClientIdDefine = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
  );
  static const String _googleAndroidRedirectUriDefine = String.fromEnvironment(
    'GOOGLE_ANDROID_REDIRECT_URI',
  );
  static const String _googleIosRedirectUriDefine = String.fromEnvironment(
    'GOOGLE_IOS_REDIRECT_URI',
  );
  static const String _googleRedirectUriDefine = String.fromEnvironment(
    'GOOGLE_REDIRECT_URI',
  );

  static String _readEnv(
    String key, {
    required String defineValue,
    String fallback = '',
  }) {
    final trimmedDefine = defineValue.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;

    if (dotenv.isInitialized) {
      final dotEnvValue = dotenv.maybeGet(key)?.trim();
      if (dotEnvValue != null && dotEnvValue.isNotEmpty) {
        return dotEnvValue;
      }
    }

    return fallback;
  }

  static String get baseUrl => _readEnv(
    'API_BASE_URL',
    defineValue: _apiBaseUrlDefine,
    fallback: 'https://sikera.my.id/api/v1',
  );

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Google OAuth 2.0 API endpoints (Authorization Code + PKCE)
  static const String googleAuthEndpoint =
      'https://accounts.google.com/o/oauth2/v2/auth';
  static const String googleTokenEndpoint =
      'https://oauth2.googleapis.com/token';
  static const String googleRevokeEndpoint =
      'https://oauth2.googleapis.com/revoke';

  // Google Cloud OAuth 2.0 public client config (.env / --dart-define)
  static String get googleAndroidClientId => _readEnv(
    'GOOGLE_ANDROID_CLIENT_ID',
    defineValue: _googleAndroidClientIdDefine,
  );
  static String get googleIosClientId => _readEnv(
    'GOOGLE_IOS_CLIENT_ID',
    defineValue: _googleIosClientIdDefine,
  );
  static String get googleClientId => _readEnv(
    'GOOGLE_CLIENT_ID',
    defineValue: _googleClientIdDefine,
  );
  static String get googleAndroidRedirectUri => _readEnv(
    'GOOGLE_ANDROID_REDIRECT_URI',
    defineValue: _googleAndroidRedirectUriDefine,
  );
  static String get googleIosRedirectUri => _readEnv(
    'GOOGLE_IOS_REDIRECT_URI',
    defineValue: _googleIosRedirectUriDefine,
  );
  static String get googleRedirectUri => _readEnv(
    'GOOGLE_REDIRECT_URI',
    defineValue: _googleRedirectUriDefine,
  );

  // Dashboard
  static const String dashboard = '/dashboard';

  // Modules & Education
  static const String modules = '/modules';
  static String moduleDetail(int id) => '/modules/$id';
  static String pretest(int id) => '/modules/$id/pretest';
  static String moduleBanner(int id) => '/modules/$id/banner';
  static String topic(int moduleId, int topicId) =>
      '/modules/$moduleId/topic/$topicId';
  static String posttest(int id) => '/modules/$id/posttest';

  // Global Post-Test (terbuka 3 hari setelah semua modul selesai)
  static const String globalPosttest = '/posttest';
  static const String globalPosttestStatus = '/posttest/status';

  // Admin: Kelola Pre-Test (per modul) & Post-Test (terpisah)
  static String adminModulePretests(int moduleId) =>
      '/admin/modules/$moduleId/pretest';
  static String adminModulePretestItem(int moduleId, int questionId) =>
      '/admin/modules/$moduleId/pretest/$questionId';
  static const String adminPosttests = '/admin/posttest';
  static String adminPosttestItem(int questionId) =>
      '/admin/posttest/$questionId';

  // Selfcare
  static const String selfcareSummary = '/selfcare/summary';
  static const String period = '/selfcare/period';
  static const String periodHistory = '/selfcare/period/history';
  static const String periodPrediction = '/selfcare/period/prediction';
  static const String periodCalculate = '/selfcare/period/calculate';
  static const String periodWaliddCalculate =
      '/selfcare/period/walidd/calculate';
  static const String periodPbacCalculate = '/selfcare/period/pbac/calculate';
  static const String bmi = '/selfcare/bmi';
  static const String bmiHistory = '/selfcare/bmi/history';
  static const String bloodGuide = '/selfcare/guides/blood';
  static const String hygieneGuide = '/selfcare/guides/hygiene';

  // Posters
  static const String posters = '/posters';
  static String posterDownload(int id) => '/posters/$id/download';
  static String posterShare(int id) => '/posters/$id/share';

  // Cases & Forum
  static const String cases = '/cases';
  static String caseDetail(int id) => '/cases/$id';
  static const String forum = '/forum';
  static String forumDetail(int id) => '/forum/$id';
  static String forumReply(int id) => '/forum/$id/reply';

  // Gamification
  static const String trivia = '/gamification/trivia';
  static const String mythFact = '/gamification/myth-fact';
}
