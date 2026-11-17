import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/community_model.dart';
import '../../routes/app_pages.dart';
import 'forum_controller.dart';

/// Halaman Forum Tanya Anonim & Konseling Mahasiswa.
/// Menerapkan antislop-layoutmobile dan flutter-build-responsive-layout:
/// - Responsive constraint (maxWidth: 720px).
/// - Chip filter kategori topik & pencarian pertanyaan.
/// - Kartu pertanyaan dengan badge anonimitas dan verifikasi jawaban konselor.
/// - Tap target minimum 48px untuk FAB dan seluruh kartu.
class ForumListPage extends GetView<ForumController> {
  const ForumListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Tanya Anonim'),
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary700,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        onPressed: () {
          controller.resetCreateForm();
          Get.toNamed(Routes.FORUM_CREATE);
        },
        icon: const Icon(Icons.edit_note_rounded, size: 22),
        label: const Text(
          'Tanya Konselor',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      body: Obx(() {
        final allPosts = controller.posts;
        final filterTopic = controller.selectedFilterTopic.value;
        final query = controller.searchQuery.value.toLowerCase();

        final filteredPosts = allPosts.where((post) {
          final matchesTopic = filterTopic == 'Semua' || post.topic == filterTopic;
          final matchesSearch = query.isEmpty ||
              post.title.toLowerCase().contains(query) ||
              post.content.toLowerCase().contains(query);
          return matchesTopic && matchesSearch;
        }).toList();

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          isEmpty: allPosts.isEmpty,
          emptyMessage: 'Belum ada pertanyaan di forum ini. Jadilah yang pertama bertanya!',
          emptyIcon: Icons.forum_outlined,
          onRetry: controller.fetchForumPosts,
          child: RefreshIndicator(
            color: AppTheme.primary700,
            onRefresh: () => controller.fetchForumPosts(forceRefresh: true),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  children: [
                    // Header Banner: Ruang Konseling Aman
                    _buildCounselingBanner(context, isDark),
                    const SizedBox(height: 16),

                    // Search Bar
                    _buildSearchBar(context, isDark),
                    const SizedBox(height: 14),

                    // Filter Kategori Chips
                    _buildFilterChips(context, isDark),
                    const SizedBox(height: 16),

                    // Counter Hasil
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        'Daftar Pertanyaan Mahasiswa (${filteredPosts.length})',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (filteredPosts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(28),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.0),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 40,
                                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMutedLight,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tidak ada diskusi yang cocok dengan filter atau kata kunci.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...filteredPosts.map((post) => _buildPostCard(context, post, isDark)),
                    const SizedBox(height: 80), // Padding ekstra agar tidak tertutup FAB
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCounselingBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.0,
        ),
        boxShadow: isDark ? null : AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                Icons.lock_person_rounded,
                color: isDark ? AppTheme.primary500 : AppTheme.primary700,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konsultasi Privat & Bebas Khawatir',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Identitas Anda terlindungi sebagai mahasiswa anonim. Pertanyaan akan dijawab langsung oleh tim medis dan konselor kampus.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.0,
        ),
      ),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val.trim(),
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: 'Cari topik atau pertanyaan...',
          hintStyle: TextStyle(
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            fontSize: 13.5,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            size: 20,
          ),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => controller.searchQuery.value = '',
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, bool isDark) {
    final filterOptions = ['Semua', ...controller.topics];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filterOptions.map((option) {
        final isSelected = controller.selectedFilterTopic.value == option;
        return ChoiceChip(
          label: Text(
            option == 'Semua'
                ? 'Semua Topik'
                : ForumController.topicShortLabel(option),
          ),
          selected: isSelected,
          selectedColor: isDark ? AppTheme.primary200 : AppTheme.primary700,
          backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
          checkmarkColor: isDark ? AppTheme.primary900 : Colors.white,
          side: BorderSide(
            color: isSelected
                ? (isDark ? AppTheme.primary200 : AppTheme.primary700)
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: 1.2,
          ),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppTheme.primary900 : Colors.white)
                : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
          ),
          onSelected: (_) => controller.selectedFilterTopic.value = option,
        );
      }).toList(),
    );
  }

  Widget _buildPostCard(BuildContext context, ForumPostModel post, bool isDark) {
    final hasReplies = post.repliesCount > 0 || post.replies.isNotEmpty;
    final totalReplies = post.repliesCount > 0 ? post.repliesCount : post.replies.length;

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
            controller.fetchPostDetail(post.id);
            Get.toNamed(Routes.FORUM_DETAIL, arguments: post.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar: Topic Tag & Anonymity Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                      child: Text(
                        ForumController.topicShortLabel(post.topic),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                          color: isDark ? AppTheme.primary500 : AppTheme.primary700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isAnonymous ? Icons.visibility_off_rounded : Icons.person_outline_rounded,
                          size: 14,
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          post.anonymousAlias?.isNotEmpty == true
                              ? post.anonymousAlias!
                              : (post.isAnonymous ? 'Anonim' : 'Mahasiswa'),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  post.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: -0.2,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                  ),
                ),
                const SizedBox(height: 6),

                // Excerpt
                Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 14),

                // Bottom Bar: Counselor Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: hasReplies || post.isAnsweredByCounselor
                            ? (isDark ? AppTheme.statusSuccess.withValues(alpha: 0.15) : AppTheme.successLight)
                            : (isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            post.isAnsweredByCounselor
                                ? Icons.verified_rounded
                                : (hasReplies ? Icons.chat_bubble_outline_rounded : Icons.pending_outlined),
                            size: 14,
                            color: post.isAnsweredByCounselor || hasReplies
                                ? (isDark ? const Color(0xFF34D399) : AppTheme.statusSuccess)
                                : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            post.isAnsweredByCounselor
                                ? 'Dijawab Konselor ($totalReplies)'
                                : (hasReplies
                                    ? '$totalReplies Tanggapan'
                                    : 'Menunggu Jawaban'),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: post.isAnsweredByCounselor || hasReplies
                                  ? (isDark ? const Color(0xFF34D399) : AppTheme.statusSuccess)
                                  : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                            ),
                          ),
                        ],
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
  }
}
