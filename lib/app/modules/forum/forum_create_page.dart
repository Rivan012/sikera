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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.softAccentSurfaceDark
                          : AppTheme.primary50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: isDark
                              ? AppTheme.primary200
                              : AppTheme.primary700,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Identitas Anda sepenuhnya dirahasiakan dan aman bersama konselor kampus.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.primary900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller.titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Pertanyaan Singkat',
                      hintText:
                          'Contoh: Nyeri perut hebat saat hari ke-1 haid...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue:
                        controller.topics.contains(
                          controller.topicController.text,
                        )
                        ? controller.topicController.text
                        : controller.topics.first,
                    decoration: const InputDecoration(
                      labelText: 'Topik Bahasan',
                    ),
                    items: controller.topics
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(ForumController.topicLabel(t)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) controller.topicController.text = val;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Uraian Pertanyaan atau Curhatan',
                      hintText:
                          'Jelaskan kronologi, durasi keluhan, atau hal yang ingin dikonsultasikan...',
                      helperText:
                          'Minimal 10 karakter agar konselor dapat menganalisis dengan jelas.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Kirim Secara Anonim (Disarankan)'),
                      subtitle: const Text(
                        'Nama dan data pribadi tidak akan ditampilkan.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: controller.isAnonymous.value,
                      activeTrackColor: isDark
                          ? AppTheme.primary500
                          : AppTheme.primary700,
                      activeThumbColor: Colors.white,
                      onChanged: (val) {
                        controller.isAnonymous.value = val;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.createPost,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              controller.isAnonymous.value
                                  ? 'Kirim Pertanyaan Anonim'
                                  : 'Kirim Pertanyaan',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
