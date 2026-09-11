class PosterModel {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? pdfUrl;
  final int downloadCount;
  final int shareCount;

  PosterModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.pdfUrl,
    this.downloadCount = 0,
    this.shareCount = 0,
  });

  factory PosterModel.fromJson(Map<String, dynamic> json) {
    return PosterModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? json['caption']?.toString() ?? json['share_text']?.toString(),
      imageUrl: json['image_url']?.toString(),
      pdfUrl: json['pdf_url']?.toString(),
      downloadCount: json['download_count'] is int ? json['download_count'] : int.tryParse(json['download_count']?.toString() ?? '0') ?? 0,
      shareCount: json['share_count'] is int ? json['share_count'] : int.tryParse(json['share_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class CaseStudyModel {
  final int id;
  final String title;
  final String category;
  final String summary;
  final String content;
  final String? legalAspect;
  final String? medicalAspect;
  final String? solutionTips;

  CaseStudyModel({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    this.legalAspect,
    this.medicalAspect,
    this.solutionTips,
  });

  factory CaseStudyModel.fromJson(Map<String, dynamic> json) {
    return CaseStudyModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Umum',
      summary: json['summary']?.toString() ?? json['narrative']?.toString() ?? '',
      content: json['content']?.toString() ?? json['narrative']?.toString() ?? '',
      legalAspect: json['legal_aspect']?.toString() ?? json['legal_analysis']?.toString(),
      medicalAspect: json['medical_aspect']?.toString() ?? json['medical_analysis']?.toString(),
      solutionTips: json['solution_tips']?.toString(),
    );
  }
}

class ForumReplyModel {
  final int id;
  final String responderName;
  final String responderRole;
  final String replyContent;
  final String createdAt;

  ForumReplyModel({
    required this.id,
    required this.responderName,
    required this.responderRole,
    required this.replyContent,
    required this.createdAt,
  });

  factory ForumReplyModel.fromJson(Map<String, dynamic> json) {
    final roleBadge = json['role_badge']?.toString() ?? json['responder_role']?.toString();
    String roleTitle = 'Mahasiswa';
    if (roleBadge == 'dosen_pa') {
      roleTitle = 'Dosen PA Konselor';
    } else if (roleBadge == 'admin') {
      roleTitle = 'Admin SIKERA';
    } else if (roleBadge != null && roleBadge.isNotEmpty) {
      roleTitle = roleBadge;
    }

    return ForumReplyModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      responderName: json['display_name']?.toString() ?? json['responder_name']?.toString() ?? 'Konselor',
      responderRole: roleTitle,
      replyContent: json['reply_content']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class ForumPostModel {
  final int id;
  final String title;
  final String topic;
  final String content;
  final bool isAnonymous;
  final String? anonymousAlias;
  final bool isAnsweredByCounselor;
  final int repliesCount;
  final String createdAt;
  final List<ForumReplyModel> replies;

  ForumPostModel({
    required this.id,
    required this.title,
    required this.topic,
    required this.content,
    this.isAnonymous = true,
    this.anonymousAlias,
    this.isAnsweredByCounselor = false,
    this.repliesCount = 0,
    required this.createdAt,
    this.replies = const [],
  });

  factory ForumPostModel.fromJson(Map<String, dynamic> json) {
    List<ForumReplyModel> parsedReplies = [];
    if (json['replies'] is List) {
      parsedReplies = (json['replies'] as List)
          .map((e) => ForumReplyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final rawRepliesCount = json['replies_count'];
    final repliesCount = rawRepliesCount is int
        ? rawRepliesCount
        : (int.tryParse(rawRepliesCount?.toString() ?? '') ?? parsedReplies.length);

    return ForumPostModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      topic: json['topic']?.toString() ?? 'Medis',
      content: json['content']?.toString() ?? '',
      isAnonymous: json['is_anonymous'] == true || json['is_anonymous'] == 1 || json['anonymous_alias'] != null,
      anonymousAlias: json['anonymous_alias']?.toString(),
      isAnsweredByCounselor: json['is_answered_by_counselor'] == true || json['is_answered_by_counselor'] == 1,
      repliesCount: repliesCount,
      createdAt: json['created_at']?.toString() ?? '',
      replies: parsedReplies,
    );
  }
}
