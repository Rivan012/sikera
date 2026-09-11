import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import 'forum_controller.dart';

/// Halaman Detail Pertanyaan & Tanggapan Konselor.
/// Menerapkan antislop-layoutmobile dan flutter-build-responsive-layout:
/// - Responsive constraint (maxWidth: 720px).
/// - Kartu penanya berkarakter dengan penegasan privasi anonim.
/// - Tanggapan konselor terverifikasi dengan badge kredibilitas.
/// - Input balasan aman dengan tap target memenuhi standar 48px.
class ForumDetailPage extends GetView<ForumController> {
  const ForumDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final int postId = (Get.arguments is int) ? Get.arguments as int : 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Diskusi & Konseling'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final post = controller.selectedPost.value;

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          isEmpty: post == null,
          emptyMessage: 'Pertanyaan tidak ditemukan.',
          emptyIcon: Icons.forum_outlined,
          onRetry: () => controller.fetchPostDetail(postId),
          child: post == null
              ? const SizedBox.shrink()
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Kartu Pertanyaan Mahasiswa
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.brandGradient,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary900.withValues(alpha: 0.25),
                                        blurRadius: 14,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              ForumController.topicLabel(post.topic),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.security_rounded, size: 14, color: AppTheme.primary50),
                                          const SizedBox(width: 4),
                                          Text(
                                            post.anonymousAlias?.isNotEmpty == true
                                                ? '${post.anonymousAlias!} (Terlindungi)'
                                                : (post.isAnonymous ? 'Anonim (Terlindungi)' : 'Mahasiswa'),
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primary50,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        post.title,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        post.content,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          height: 1.5,
                                          color: AppTheme.primary50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // Section Header: Tanggapan Konselor
                                Row(
                                  children: [
                                    Text(
                                      'Tanggapan Konselor & Ahli',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppTheme.textPrimaryDark : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppTheme.primary900.withValues(alpha: 0.4) : AppTheme.primary50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${post.replies.length}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                if (post.replies.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0)),
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.hourglass_empty_rounded,
                                            size: 36,
                                            color: isDark ? AppTheme.textSecondaryDark : const Color(0xFF94A3B8),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Pertanyaan sedang ditinjau oleh tim konselor kesehatan reproduksi.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: isDark ? AppTheme.textSecondaryDark : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ...post.replies.map((reply) => Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppTheme.surfaceDark : Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: AppTheme.primary700,
                                                  child: Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  reply.responderName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13.5,
                                                    color: isDark ? AppTheme.textPrimaryDark : const Color(0xFF0F172A),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFECFDF5),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    reply.responderRole,
                                                    style: const TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF059669),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              reply.replyContent,
                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1.5,
                                                color: isDark ? AppTheme.textPrimaryDark : const Color(0xFF334155),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                              ],
                            ),
                          ),
                        ),

                        // Form Balasan di bagian bawah
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.surfaceDark : Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: SafeArea(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller.replyContentController,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? AppTheme.textPrimaryDark : const Color(0xFF0F172A),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Tulis tanggapan atau pertanyaan lanjutan...',
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppTheme.textSecondaryDark : const Color(0xFF94A3B8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Obx(() => ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary700,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(48, 48),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      onPressed: controller.isSubmittingReply.value
                                          ? null
                                          : () => controller.sendReply(post.id),
                                      child: controller.isSubmittingReply.value
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Icon(Icons.send_rounded, size: 20),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      }),
    );
  }
}
