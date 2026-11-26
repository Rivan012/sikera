import 'package:html/parser.dart' as html;

class QuestionOption {
  final String label;
  final String text;

  QuestionOption({required this.label, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      label: json['label']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }
}

class QuestionModel {
  final int id;
  final String questionText;
  final List<QuestionOption> options;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    List<QuestionOption> parsedOptions = [];
    if (json['options'] is List) {
      parsedOptions = (json['options'] as List)
          .map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return QuestionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      questionText: json['question_text']?.toString() ?? '',
      options: parsedOptions,
    );
  }
}

class TopicModel {
  final int id;
  final String topicCode;
  final String title;
  final String? youtubeVideoId;
  final String? youtubeEmbedUrl;
  final String? contentHtml;
  final String? pdfUrl;
  final bool isCompleted;
  final bool isLocked;
  final bool hasVideo;

  TopicModel({
    required this.id,
    required this.topicCode,
    required this.title,
    this.youtubeVideoId,
    this.youtubeEmbedUrl,
    this.contentHtml,
    this.pdfUrl,
    this.isCompleted = false,
    this.isLocked = false,
    this.hasVideo = false,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    var content = json['content_html']?.toString();
    var pdf = json['pdf_url']?.toString().trim() ?? '';
    final file = json['file_url']?.toString().trim() ?? '';
    final fileType = json['mime_type'] ?? json['content_type'];
    if (pdf.isEmpty &&
        (_isPdfPath(file) || fileType == 'application/pdf' || fileType == 'pdf')) {
      pdf = file;
    }
    final body = content?.trim() ?? '';
    if (!body.contains(RegExp(r'\s')) && _isPdfPath(body)) {
      if (pdf.isEmpty) pdf = body;
      if (pdf == body) content = null;
    } else if (body.contains('<')) {
      final fragment = html.parseFragment(body);
      for (final element in fragment.querySelectorAll(
        'a[href], iframe[src], embed[src], object[data]',
      )) {
        final link = (element.attributes['href'] ??
                element.attributes['src'] ??
                element.attributes['data']!)
            .trim();
        if (link.isEmpty) continue;
        if (pdf.isEmpty &&
            (_isPdfPath(link) || element.attributes['type'] == 'application/pdf')) {
          pdf = link;
        }
        if (link == pdf) {
          element.remove();
          content = fragment.outerHtml;
        }
      }
    }
    return TopicModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      topicCode: json['topic_code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      youtubeVideoId: json['youtube_video_id']?.toString(),
      youtubeEmbedUrl: json['youtube_embed_url']?.toString(),
      contentHtml: content,
      pdfUrl: pdf.isEmpty ? null : pdf,
      isCompleted: json['is_completed'] == true,
      isLocked: json['is_locked'] == true,
      hasVideo: json['has_video'] == true || (json['youtube_video_id'] != null && json['youtube_video_id'].toString().isNotEmpty),
    );
  }

  static bool _isPdfPath(String value) =>
      !value.contains(RegExp(r'[<>\r\n]')) &&
      (Uri.tryParse(value)?.path.toLowerCase().endsWith('.pdf') ?? false);
}

class ModuleDetailModel {
  final int id;
  final int moduleNumber;
  final String title;
  final String? subtitle;
  final String? description;
  final String? bannerImage;
  final bool isLocked;
  final bool hasPretest;
  final bool allTopicsDone;
  final bool hasPosttest;
  final int? posttestScore;
  final double? nGain;
  final List<TopicModel> topics;

  ModuleDetailModel({
    required this.id,
    required this.moduleNumber,
    required this.title,
    this.subtitle,
    this.description,
    this.bannerImage,
    this.isLocked = false,
    required this.hasPretest,
    this.allTopicsDone = false,
    required this.hasPosttest,
    this.posttestScore,
    this.nGain,
    this.topics = const [],
  });

  factory ModuleDetailModel.fromJson(Map<String, dynamic> json) {
    final mod = json['module'] is Map<String, dynamic>
        ? json['module'] as Map<String, dynamic>
        : json;

    List<TopicModel> parsedTopics = [];
    final rawTopics = json['topics'] ?? mod['topics'];
    if (rawTopics is List) {
      parsedTopics = rawTopics
          .map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final rawNGain = json['n_gain'] ?? mod['n_gain'];
    double? parsedNGain;
    if (rawNGain != null) {
      parsedNGain = rawNGain is num ? rawNGain.toDouble() : double.tryParse(rawNGain.toString());
    }

    final rawScore = json['posttest_score'] ?? mod['posttest_score'];
    int? parsedScore;
    if (rawScore != null) {
      parsedScore = rawScore is int ? rawScore : int.tryParse(rawScore.toString());
    }

    return ModuleDetailModel(
      id: mod['id'] is int ? mod['id'] : int.tryParse(mod['id'].toString()) ?? 0,
      moduleNumber: mod['module_number'] is int
          ? mod['module_number']
          : int.tryParse(mod['module_number']?.toString() ?? '1') ?? 1,
      title: mod['title']?.toString() ?? '',
      subtitle: mod['subtitle']?.toString(),
      description: mod['description']?.toString() ?? mod['subtitle']?.toString(),
      bannerImage: mod['banner_image']?.toString() ?? json['banner_image']?.toString(),
      isLocked: json['is_locked'] == true || mod['is_locked'] == true,
      hasPretest: json['has_pretest'] == true || mod['has_pretest'] == true,
      allTopicsDone: json['all_topics_done'] == true || mod['all_topics_done'] == true,
      hasPosttest: json['has_posttest'] == true || mod['has_posttest'] == true,
      posttestScore: parsedScore,
      nGain: parsedNGain,
      topics: parsedTopics,
    );
  }
}

enum PosttestAvailability {
  lockedIncompleteModules,
  waitingCooldown,
  available,
  completed,
}

class GlobalPosttestStatus {
  static const int requiredDelayDays = 3;

  final int totalModules;
  final int completedModules;
  final bool allModulesCompleted;
  final DateTime? allModulesCompletedAt;
  final DateTime? availableAt;
  final bool isUnlocked;
  final bool hasCompletedPosttest;
  final int? pretestScore;
  final int? posttestScore;
  final double? nGainScore;
  final String? effectivenessCategory;
  final int delayDays;

  const GlobalPosttestStatus({
    this.totalModules = 0,
    this.completedModules = 0,
    this.allModulesCompleted = false,
    this.allModulesCompletedAt,
    this.availableAt,
    this.isUnlocked = false,
    this.hasCompletedPosttest = false,
    this.pretestScore,
    this.posttestScore,
    this.nGainScore,
    this.effectivenessCategory,
    this.delayDays = requiredDelayDays,
  });

  DateTime? get effectiveAvailableAt =>
      availableAt ?? allModulesCompletedAt?.add(Duration(days: delayDays));

  PosttestAvailability availabilityAt(DateTime now) {
    if (hasCompletedPosttest) return PosttestAvailability.completed;
    if (!allModulesCompleted) {
      return PosttestAvailability.lockedIncompleteModules;
    }
    if (isUnlocked) return PosttestAvailability.available;
    final unlockAt = effectiveAvailableAt;
    if (unlockAt != null && !now.isBefore(unlockAt)) {
      return PosttestAvailability.available;
    }
    return PosttestAvailability.waitingCooldown;
  }

  Duration remainingDuration(DateTime now) {
    final unlockAt = effectiveAvailableAt;
    if (unlockAt == null) return Duration(days: delayDays);
    final diff = unlockAt.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  String formatRemaining(DateTime now) {
    final diff = remainingDuration(now);
    if (diff == Duration.zero) return 'Siap dikerjakan';
    final days = diff.inDays;
    final hours = diff.inHours.remainder(24);
    final minutes = diff.inMinutes.remainder(60);
    if (days > 0) {
      return hours > 0 ? '$days hari $hours jam lagi' : '$days hari lagi';
    }
    if (hours > 0) {
      return minutes > 0 ? '$hours jam $minutes menit lagi' : '$hours jam lagi';
    }
    if (minutes > 0) return '$minutes menit lagi';
    return 'Kurang dari 1 menit lagi';
  }

  GlobalPosttestStatus copyWith({
    int? totalModules,
    int? completedModules,
    bool? allModulesCompleted,
    DateTime? allModulesCompletedAt,
    DateTime? availableAt,
    bool? isUnlocked,
    bool? hasCompletedPosttest,
    int? pretestScore,
    int? posttestScore,
    double? nGainScore,
    String? effectivenessCategory,
    int? delayDays,
  }) {
    return GlobalPosttestStatus(
      totalModules: totalModules ?? this.totalModules,
      completedModules: completedModules ?? this.completedModules,
      allModulesCompleted: allModulesCompleted ?? this.allModulesCompleted,
      allModulesCompletedAt:
          allModulesCompletedAt ?? this.allModulesCompletedAt,
      availableAt: availableAt ?? this.availableAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      hasCompletedPosttest: hasCompletedPosttest ?? this.hasCompletedPosttest,
      pretestScore: pretestScore ?? this.pretestScore,
      posttestScore: posttestScore ?? this.posttestScore,
      nGainScore: nGainScore ?? this.nGainScore,
      effectivenessCategory:
          effectivenessCategory ?? this.effectivenessCategory,
      delayDays: delayDays ?? this.delayDays,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text)?.toLocal();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory GlobalPosttestStatus.fromJson(Map<String, dynamic> json) {
    final completedAt = _parseDate(
      json['all_modules_completed_at'] ?? json['completed_at'],
    );
    final availableAt = _parseDate(
      json['available_at'] ?? json['posttest_available_at'] ?? json['unlock_at'],
    );
    final total = _parseInt(json['total_modules']) ?? 0;
    final completed = _parseInt(json['completed_modules']) ?? 0;
    final allCompleted =
        json['all_modules_completed'] == true ||
        (total > 0 && completed >= total);
    final unlocked =
        json['is_unlocked'] == true || json['can_take_posttest'] == true;
    final done =
        json['has_posttest'] == true ||
        json['has_completed_posttest'] == true ||
        json['is_completed'] == true;

    return GlobalPosttestStatus(
      totalModules: total,
      completedModules: completed,
      allModulesCompleted: allCompleted,
      allModulesCompletedAt: completedAt,
      availableAt: availableAt,
      isUnlocked: unlocked,
      hasCompletedPosttest: done,
      pretestScore: _parseInt(json['pretest_score']),
      posttestScore: _parseInt(json['posttest_score'] ?? json['score']),
      nGainScore: _parseDouble(json['n_gain_score'] ?? json['n_gain']),
      effectivenessCategory: json['effectiveness_category']?.toString(),
      delayDays:
          _parseInt(json['unlock_delay_days'] ?? json['delay_days']) ??
          requiredDelayDays,
    );
  }
}
