import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../routes/app_pages.dart';
import 'posters_controller.dart';

/// Halaman Daftar Poster Edukasi Visual Kaspro.
/// Menerapkan antislop-layoutmobile dan flutter-build-responsive-layout:
/// - Responsive constraint (maxWidth: 720px).
/// - Thumbnail visual dan metadata unduh/bagikan yang rapi.
/// - Tap target minimum 48px pada setiap kartu.
class PosterListPage extends GetView<PostersController> {
  const PosterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Poster Visual Edukasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => StateView(
            isLoading: controller.isLoading.value,
            errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
            isEmpty: controller.posters.isEmpty,
            emptyMessage: 'Belum ada poster edukasi yang tersedia.',
            emptyIcon: Icons.image_outlined,
            onRetry: controller.fetchPosters,
            child: RefreshIndicator(
              color: AppTheme.primary700,
              onRefresh: () => controller.fetchPosters(forceRefresh: true),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: controller.posters.length,
                    itemBuilder: (context, index) {
                      final poster = controller.posters[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                            width: 1.0,
                          ),
                          boxShadow: isDark ? null : AppTheme.cardShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            onTap: () {
                              controller.selectedPoster.value = poster;
                              Get.toNamed(Routes.POSTER_DETAIL, arguments: poster);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.primary900.withValues(alpha: 0.35) : AppTheme.primary50,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    ),
                                    child: Icon(Icons.image_rounded, color: isDark ? AppTheme.primary200 : AppTheme.primary700, size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          poster.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.5,
                                            letterSpacing: -0.2,
                                            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                          ),
                                        ),
                                        if (poster.description != null && poster.description!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            poster.description!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              height: 1.35,
                                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.file_download_outlined, size: 14, color: AppTheme.primary700),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${poster.downloadCount} Unduhan',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500,
                                                color: isDark ? AppTheme.textSecondaryDark : const Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            const Icon(Icons.share_outlined, size: 14, color: AppTheme.primary500),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${poster.shareCount} Bagikan',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500,
                                                color: isDark ? AppTheme.textSecondaryDark : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primary700),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
