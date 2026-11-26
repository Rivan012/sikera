import 'module_model.dart';
import 'user_model.dart';

class DashboardModuleModel {
  final int id;
  final int moduleNumber;
  final String title;
  final String? bannerImage;
  final int totalTopics;
  final int completedTopics;
  final int progressPercentage;
  final bool hasPretest;
  final bool hasPosttest;
  final DateTime? completedAt;

  DashboardModuleModel({
    required this.id,
    required this.moduleNumber,
    required this.title,
    this.bannerImage,
    required this.totalTopics,
    required this.completedTopics,
    required this.progressPercentage,
    required this.hasPretest,
    required this.hasPosttest,
    this.completedAt,
  });

  bool get isTopicsCompleted => totalTopics > 0
      ? completedTopics >= totalTopics
      : progressPercentage >= 100;

  factory DashboardModuleModel.fromJson(Map<String, dynamic> json) {
    final rawCompletedAt = json['completed_at']?.toString().trim();
    return DashboardModuleModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      moduleNumber: json['module_number'] is int ? json['module_number'] : int.tryParse(json['module_number']?.toString() ?? '1') ?? 1,
      title: json['title']?.toString() ?? '',
      bannerImage: json['banner_image']?.toString(),
      totalTopics: json['total_topics'] is int ? json['total_topics'] : int.tryParse(json['total_topics']?.toString() ?? '0') ?? 0,
      completedTopics: json['completed_topics'] is int ? json['completed_topics'] : int.tryParse(json['completed_topics']?.toString() ?? '0') ?? 0,
      progressPercentage: json['progress_percentage'] is int ? json['progress_percentage'] : int.tryParse(json['progress_percentage']?.toString() ?? '0') ?? 0,
      hasPretest: json['has_pretest'] == true,
      hasPosttest: json['has_posttest'] == true,
      completedAt: (rawCompletedAt == null || rawCompletedAt.isEmpty)
          ? null
          : DateTime.tryParse(rawCompletedAt)?.toLocal(),
    );
  }
}

class DashboardDataModel {
  final UserModel? user;
  final List<DashboardModuleModel> modules;
  final List<dynamic> posters;
  final Map<String, dynamic>? selfcare;
  final GlobalPosttestStatus? posttestStatus;

  DashboardDataModel({
    this.user,
    this.modules = const [],
    this.posters = const [],
    this.selfcare,
    this.posttestStatus,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    if (json['user'] is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(json['user']);
    }

    List<DashboardModuleModel> parsedModules = [];
    if (json['modules'] is List) {
      parsedModules = (json['modules'] as List)
          .map((e) => DashboardModuleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    GlobalPosttestStatus? parsedPosttest;
    final rawPosttest = json['posttest'] ?? json['posttest_status'];
    if (rawPosttest is Map<String, dynamic>) {
      parsedPosttest = GlobalPosttestStatus.fromJson(rawPosttest);
    }

    return DashboardDataModel(
      user: parsedUser,
      modules: parsedModules,
      posters: json['posters'] is List ? json['posters'] : [],
      selfcare: json['selfcare'] is Map<String, dynamic> ? json['selfcare'] : null,
      posttestStatus: parsedPosttest,
    );
  }
}
