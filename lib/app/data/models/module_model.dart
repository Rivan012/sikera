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
    this.isCompleted = false,
    this.isLocked = false,
    this.hasVideo = false,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      topicCode: json['topic_code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      youtubeVideoId: json['youtube_video_id']?.toString(),
      youtubeEmbedUrl: json['youtube_embed_url']?.toString(),
      contentHtml: json['content_html']?.toString(),
      isCompleted: json['is_completed'] == true,
      isLocked: json['is_locked'] == true,
      hasVideo: json['has_video'] == true || (json['youtube_video_id'] != null && json['youtube_video_id'].toString().isNotEmpty),
    );
  }
}

class ModuleDetailModel {
  final int id;
  final int moduleNumber;
  final String title;
  final String? subtitle;
  final String? description;
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
