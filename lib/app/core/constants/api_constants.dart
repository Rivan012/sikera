class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sikera.my.id/api/v1',
  );

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Google Sign-In OAuth client IDs (opsional via --dart-define)
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '755858406803-f3sd37akh7eleuibqcfccaapkpq2vu95.apps.googleusercontent.com',
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
