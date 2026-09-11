import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/community_model.dart';
import 'posters_controller.dart';

class PosterDetailPage extends GetView<PostersController> {
  const PosterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final poster = (Get.arguments is PosterModel)
        ? Get.arguments as PosterModel
        : controller.selectedPoster.value;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Poster Kaspro'),
      ),
      body: poster == null
          ? const Center(child: Text('Poster tidak ditemukan.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Poster Visual Container
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.primary900.withValues(alpha: 0.35) : AppTheme.primary50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppTheme.primary700.withValues(alpha: 0.4) : AppTheme.primary200,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf_outlined, color: isDark ? AppTheme.primary200 : AppTheme.primary700, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            poster.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? AppTheme.primary200 : AppTheme.primary900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            poster.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            poster.description ?? 'Poster edukasi resmi program kesehatan reproduksi mahasiswa.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.downloadPoster(poster.id),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Unduh Poster'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.sharePoster(poster.id),
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: const Text('Bagikan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
