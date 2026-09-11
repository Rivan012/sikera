import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'gamification_controller.dart';

class DiaryPage extends GetView<GamificationController> {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Diary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bagaimana Perasaan Anda Hari Ini?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedMood.value,
                          decoration: const InputDecoration(labelText: 'Pilih Suasana Hati (Mood)'),
                          items: controller.moods
                              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedMood.value = val;
                          },
                        )),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.moodNoteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Pribadi (Terenkripsi Aman)',
                        hintText: 'Tuliskan unek-unek atau refleksi diri Anda hari ini...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.saveDiaryEntry,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('Simpan Mood Diary'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Riwayat Mood Diary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Obx(() {
              if (controller.diaryEntries.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Belum ada catatan mood yang disimpan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.diaryEntries.length,
                itemBuilder: (context, index) {
                  final entry = controller.diaryEntries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Builder(builder: (context) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return CircleAvatar(
                          backgroundColor: isDark ? AppTheme.primary900.withValues(alpha: 0.4) : AppTheme.primary50,
                          child: Icon(Icons.mood, color: isDark ? AppTheme.primary200 : AppTheme.primary700),
                        );
                      }),
                      title: Text(entry.mood, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        entry.encryptedNote ?? 'Tidak ada catatan tambahan.',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        entry.entryDate,
                        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
