import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/state_view.dart';
import 'education_controller.dart';
import 'widgets/topic_flipbook.dart';

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
          tooltip: 'Kembali ke modul',
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
          errorMessage: controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : null,
          isEmpty: topic == null,
          emptyMessage: 'Materi tidak ditemukan.',
          onRetry: () => controller.fetchTopic(moduleId, topicId),
          child: topic == null
              ? const SizedBox.shrink()
              : TopicFlipbook(
                  key: ObjectKey(topic),
                  topic: topic,
                  onFinished: () {
                    Get.back();
                    controller.refreshAllProgress(moduleId);
                  },
                ),
        );
      }),
    );
  }
}
