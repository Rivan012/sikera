import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../routes/app_pages.dart';
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
        final activeModule = controller.currentModule.value;
        final needsPretest =
            activeModule != null &&
            activeModule.id == moduleId &&
            !activeModule.hasPretest;

        if (needsPretest) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 48,
                        color: isDark
                            ? AppTheme.primary200
                            : AppTheme.primary700,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pre-Test Diperlukan',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selesaikan Pre-Test Modul ${activeModule.moduleNumber} terlebih dahulu sebelum membaca submateri ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.fetchPretest(moduleId);
                          Get.offNamed(
                            Routes.EDUCATION_PRETEST,
                            arguments: moduleId,
                          );
                        },
                        icon: const Icon(Icons.assignment_outlined),
                        label: const Text('Mulai Pre-Test Sekarang'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

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
