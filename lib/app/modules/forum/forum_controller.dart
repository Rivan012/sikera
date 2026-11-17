import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/community_model.dart';

class ForumController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final posts = <ForumPostModel>[].obs;
  final selectedPost = Rxn<ForumPostModel>();
  final selectedFilterTopic = 'Semua'.obs;
  final searchQuery = ''.obs;

  // Create Form
  final titleController = TextEditingController();
  final topicController = TextEditingController(text: 'Medis');
  final contentController = TextEditingController();
  final isAnonymous = true.obs;

  // Reply Form
  final replyContentController = TextEditingController();
  final isSubmittingReply = false.obs;

  final topics = ['Medis', 'Haid', 'Hubungan', 'Darurat'];

  static String topicLabel(String topic) {
    switch (topic) {
      case 'Medis':
        return 'Kesehatan Medis & Reproduksi';
      case 'Haid':
        return 'Siklus & Keluhan Haid';
      case 'Hubungan':
        return 'Konseling Relasi & Hubungan';
      case 'Darurat':
        return 'Bantuan Mendesak / Krisis';
      default:
        return topic;
    }
  }

  static String topicShortLabel(String topic) {
    switch (topic) {
      case 'Medis':
        return 'Medis';
      case 'Haid':
        return 'Haid';
      case 'Hubungan':
        return 'Hubungan';
      case 'Darurat':
        return 'Darurat';
      default:
        return topic;
    }
  }

  void resetCreateForm() {
    titleController.clear();
    contentController.clear();
    topicController.text = topics.first;
    isAnonymous.value = true;
  }

  @override
  void onInit() {
    super.onInit();
    fetchForumPosts();
  }

  Future<void> fetchForumPosts({bool forceRefresh = false}) async {
    if (posts.isEmpty || forceRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.forum);

    isLoading.value = false;

    if (response.success && response.data != null) {
      List? rawList;
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['threads'] is List) {
          rawList = map['threads'] as List;
        } else if (map['data'] is List) {
          rawList = map['data'] as List;
        }
      }

      if (rawList != null) {
        posts.value = rawList
            .map((e) => ForumPostModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else {
      if (posts.isEmpty) {
        errorMessage.value = response.message ?? 'Gagal memuat forum diskusi.';
      }
    }
  }

  Future<void> fetchPostDetail(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await ApiService.get(ApiConstants.forumDetail(id));

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final target = map['thread'] is Map<String, dynamic>
            ? map['thread'] as Map<String, dynamic>
            : map;
        selectedPost.value = ForumPostModel.fromJson(target);
      }
    } else {
      errorMessage.value = response.message ?? 'Gagal memuat detail pertanyaan.';
    }
  }

  Future<void> createPost() async {
    final title = titleController.text.trim();
    final topic = topicController.text.trim().isNotEmpty ? topicController.text.trim() : topics.first;
    final content = contentController.text.trim();

    if (title.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Judul pertanyaan wajib diisi.',
        backgroundColor: AppTheme.warning,
        colorText: Colors.white,
      );
      return;
    }

    if (content.length < 10) {
      Get.snackbar(
        'Perhatian',
        'Uraian pertanyaan minimal 10 karakter.',
        backgroundColor: AppTheme.warning,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final response = await ApiService.post(
      ApiConstants.forum,
      body: {
        'title': title,
        'topic': topic,
        'content': content,
        'is_anonymous': isAnonymous.value,
      },
    );

    isLoading.value = false;

    if (response.success) {
      resetCreateForm();
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Pertanyaan Anda telah diajukan secara aman.',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
      );
      fetchForumPosts(forceRefresh: true);
    } else {
      Get.snackbar(
        'Gagal Mengirim',
        response.message ?? 'Terjadi kendala saat mengirim.',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> sendReply(int postId) async {
    final reply = replyContentController.text.trim();
    if (reply.isEmpty) return;

    if (reply.length < 3) {
      Get.snackbar(
        'Perhatian',
        'Isi balasan minimal 3 karakter.',
        backgroundColor: AppTheme.warning,
        colorText: Colors.white,
      );
      return;
    }

    isSubmittingReply.value = true;

    final response = await ApiService.post(
      ApiConstants.forumReply(postId),
      body: {
        'reply_content': reply,
      },
    );

    isSubmittingReply.value = false;

    if (response.success) {
      replyContentController.clear();
      fetchPostDetail(postId);
      fetchForumPosts(forceRefresh: true);
      Get.snackbar(
        'Terkirim',
        'Tanggapan Anda telah ditambahkan.',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Gagal Mengirim',
        response.message ?? 'Terjadi kendala saat mengirim balasan.',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    topicController.dispose();
    contentController.dispose();
    replyContentController.dispose();
    super.onClose();
  }
}
