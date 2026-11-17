import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/state_view.dart';
import 'education_controller.dart';
import 'widgets/test_question_pager.dart';

class PosttestPage extends GetView<EducationController> {
  const PosttestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final moduleId = Get.arguments is int ? Get.arguments as int : 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Post-Test Modul')),
      body: Obx(
        () => StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : null,
          isEmpty: controller.questions.isEmpty,
          emptyMessage: 'Soal Post-Test belum tersedia.',
          onRetry: () => controller.fetchPosttest(moduleId),
          child: TestQuestionPager(
            questions: controller.questions.toList(),
            answers: Map.of(controller.answers),
            isSubmitting: controller.isSubmitting.value,
            onAnswer: (id, answer) => controller.answers[id] = answer,
            onSubmit: () => controller.submitPosttest(moduleId),
          ),
        ),
      ),
    );
  }
}
