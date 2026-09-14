import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import 'education_controller.dart';
import 'widgets/topic_video_player.dart';

class TopicPage extends GetView<EducationController> {
  const TopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is Map ? Get.arguments as Map : {};
    final int moduleId = args['moduleId'] is int ? args['moduleId'] as int : 1;
    final int topicId = args['topicId'] is int ? args['topicId'] as int : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi Pembelajaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Get.back();
            controller.refreshAllProgress(moduleId);
          },
        ),
      ),
      body: Obx(() {
        final topic = controller.currentTopic.value;

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          isEmpty: topic == null,
          emptyMessage: 'Materi tidak ditemukan.',
          onRetry: () => controller.fetchTopic(moduleId, topicId),
          child: topic == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Submateri Code & Title
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Submateri ${topic.topicCode}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Pemutar Video YouTube Interaktif (Jika Tersedia)
                      if ((topic.youtubeVideoId != null && topic.youtubeVideoId!.isNotEmpty) ||
                          (topic.youtubeEmbedUrl != null && topic.youtubeEmbedUrl!.isNotEmpty)) ...[
                        TopicVideoPlayer(
                          videoId: topic.youtubeVideoId ?? '',
                          embedUrl: topic.youtubeEmbedUrl,
                          title: topic.title,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Content Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Penjelasan Materi',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Divider(height: 20),
                              Text(
                                (topic.contentHtml ?? 'Konten materi sedang dimuat.')
                                    .replaceAll(RegExp(r'<[^>]*>'), '')
                                    .trim(),
                                style: const TextStyle(fontSize: 14, height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.refreshAllProgress(moduleId);
                          Get.snackbar(
                            'Materi Selesai Dipelajari',
                            'Progres belajar Anda telah berhasil disimpan.',
                            backgroundColor: AppTheme.primary900,
                            colorText: Colors.white,
                            icon: const Icon(Icons.check_circle_rounded, color: AppTheme.primary500),
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: const Text('Selesai Membaca Materi'),
                      ),
                    ],
                  ),
                ),
        );
      }),
    );
  }
}
