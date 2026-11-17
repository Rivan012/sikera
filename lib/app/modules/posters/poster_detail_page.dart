import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/community_model.dart';
import 'posters_controller.dart';

class PosterDetailPage extends GetView<PostersController> {
  const PosterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Poster Kaspro')),
      body: Obx(() {
        final poster = (Get.arguments is PosterModel)
            ? Get.arguments as PosterModel
            : controller.selectedPoster.value;

        return StateView(
          isLoading: controller.isLoading.value && poster == null,
          loadingMessage: 'Memuat detail poster...',
          errorMessage:
              controller.errorMessage.value.isNotEmpty && poster == null
              ? controller.errorMessage.value
              : null,
          isEmpty: poster == null,
          emptyMessage: 'Poster tidak ditemukan.',
          emptyIcon: Icons.image_outlined,
          onRetry: controller.fetchPosters,
          child: poster == null
              ? const SizedBox.shrink()
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 240,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.softAccentSurfaceDark
                                  : AppTheme.primary50,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusLg,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: isDark
                                        ? AppTheme.primary200
                                        : AppTheme.primary700,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    poster.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: isDark
                                          ? AppTheme.textPrimaryDark
                                          : AppTheme.primary900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    poster.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    poster.description ??
                                        'Poster edukasi resmi program kesehatan reproduksi mahasiswa.',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.5,
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
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
                                  onPressed: () =>
                                      controller.downloadPoster(poster.id),
                                  icon: const Icon(
                                    Icons.download_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Unduh Poster'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      controller.sharePoster(poster.id),
                                  icon: const Icon(
                                    Icons.share_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Bagikan'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      }),
    );
  }
}
