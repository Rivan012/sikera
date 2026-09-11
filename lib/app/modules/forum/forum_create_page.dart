import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'forum_controller.dart';

class ForumCreatePage extends GetView<ForumController> {
  const ForumCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tulis Pertanyaan Konseling'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.primary900.withValues(alpha: 0.35) : AppTheme.primary50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppTheme.primary700.withValues(alpha: 0.4) : AppTheme.primary200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: isDark ? AppTheme.primary200 : AppTheme.primary700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Identitas Anda sepenuhnya dirahasiakan dan aman bersama konselor kampus.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.primary200 : AppTheme.primary900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller.titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Pertanyaan Singkat',
                        hintText: 'Contoh: Nyeri perut hebat saat hari ke-1 haid...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: controller.topics.contains(controller.topicController.text)
                          ? controller.topicController.text
                          : controller.topics.first,
                      decoration: const InputDecoration(labelText: 'Topik Bahasan'),
                      items: controller.topics
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(ForumController.topicLabel(t)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) controller.topicController.text = val;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller.contentController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Uraian Pertanyaan atau Curhatan',
                        hintText: 'Jelaskan kronologi, durasi keluhan, atau hal yang ingin dikonsultasikan...',
                        helperText: 'Minimal 10 karakter agar konselor dapat menganalisis dengan jelas.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Obx(() => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Kirim Secara Anonim (Disarankan)'),
                          subtitle: const Text('Nama dan data pribadi tidak akan ditampilkan.', style: TextStyle(fontSize: 11)),
                          value: controller.isAnonymous.value,
                          activeThumbColor: AppTheme.primary700,
                          onChanged: (val) {
                            controller.isAnonymous.value = val;
                          },
                        )),
                    const SizedBox(height: 20),
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.createPost,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Kirim Pertanyaan Anonim'),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
