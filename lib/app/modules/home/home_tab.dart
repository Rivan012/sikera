import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/dashboard_model.dart';
import '../../routes/app_pages.dart';
import '../main_nav/main_nav_controller.dart';
import 'home_controller.dart';

/// Halaman Beranda SIKERA Bergaya Bank Jago (Kantong Kaspro Architecture).
/// Mempertahankan 100% palet warna resmi SIKERA:
/// - Deep Navy (#03045E), Ocean Blue (#0077B6), Cyan (#00B4D8), Light Cyan (#90E0EF), Pale Cyan (#CAF0F8)
/// - Menghadirkan:
///   1. Header ramah dengan avatar squircle & notifikasi.
///   2. Kantong Utama Belajar (Hero highlight pocket).
///   3. 4-Kolom Pintasan Cepat (Quick Actions).
///   4. Kantong Kaspro 2x2 Grid (Pocket cards dengan metrik & pill tag).
///   5. Rekomendasi Wawasan Kaspro (Mitos vs Fakta & Studi Kasus).
class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Obx(() {
          final data = controller.dashboardData.value;
          final user = controller.currentUser.value;

          return StateView(
            isLoading: controller.isLoading.value,
            errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
            onRetry: () => controller.fetchDashboard(forceRefresh: true),
            child: RefreshIndicator(
              color: AppTheme.primary700,
              onRefresh: () => controller.fetchDashboard(forceRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header: Halo, [Name] & Avatar Squircle
                    _buildHeader(context, user, isDark),
                    const SizedBox(height: 16),

                    // 2. Search Bar Bergaya Jago
                    _buildSearchBar(context, isDark),
                    const SizedBox(height: 20),

                    // Jika sedang mencari, tampilkan hasil pencarian
                    if (controller.searchQuery.value.isNotEmpty)
                      _buildSearchResults(context, data?.modules ?? [], isDark)
                    else ...[
                      // 3. Kantong Utama Belajar (Main Highlight Pocket)
                      _buildMainPocket(context, data?.modules ?? [], isDark),
                      const SizedBox(height: 24),

                      // 4. Pintasan Cepat (Quick Actions 4-Kolom)
                      _buildQuickActions(context, isDark),
                      const SizedBox(height: 26),

                      // 5. Kantong Kaspro Section (Jago Pockets 2x2 Grid)
                      _buildPocketsSection(context, data?.modules ?? [], isDark),
                      const SizedBox(height: 26),

                      // 6. Rekomendasi & Wawasan Kaspro
                      _buildInsightsSection(context, isDark),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 1. Header: Halo, [Name] & Avatar Squircle
  Widget _buildHeader(BuildContext context, dynamic user, bool isDark) {
    String firstName = 'Mahasiswa';
    if (user != null && user.name != null && user.name.toString().isNotEmpty) {
      firstName = user.name.toString().split(' ').first;
    }
    final String initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'M';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/logo/sikera_logo_putih.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $firstName',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Kesehatan reproduksi & edukasi harianmu',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Notification Bell
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    Get.snackbar(
                      'Notifikasi SIKERA',
                      'Seluruh materi dan layanan konseling siap diakses.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                      colorText: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    ),
                    minimumSize: const Size(42, 42),
                    padding: EdgeInsets.zero,
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Profile Avatar Squircle
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                if (Get.isRegistered<MainNavController>()) {
                  Get.find<MainNavController>().changeTab(3);
                }
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary700,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary700.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Search Bar Bergaya Jago
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppTheme.cardShadow,
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (val) => controller.searchQuery.value = val.trim(),
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: 'Cari topik, modul, atau konsultasi...',
          hintStyle: TextStyle(
            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            fontSize: 13.5,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.primary700,
            size: 22,
          ),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.searchQuery.value = '';
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }

  // 3. Kantong Utama Belajar (Main Highlight Pocket)
  Widget _buildMainPocket(BuildContext context, List<DashboardModuleModel> modules, bool isDark) {
    DashboardModuleModel? activeModule;
    int progress = 0;

    if (modules.isNotEmpty) {
      activeModule = modules.firstWhereOrNull((m) => m.progressPercentage < 100) ?? modules.first;
      progress = activeModule.progressPercentage;
    }

    final bool allDone = modules.isNotEmpty && modules.every((m) => m.progressPercentage == 100);
    final String moduleSubtitle = allDone
        ? 'Luar biasa! Seluruh materi modul edukasi telah Anda kuasai.'
        : (activeModule != null ? 'Modul ${activeModule.moduleNumber}: ${activeModule.title}' : 'Mulai eksplorasi materi kesehatan reproduksi');

    final String buttonLabel = allDone ? 'Review Materi Belajar' : 'Lanjutkan Belajar';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag Kantong Utama & Persentase
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_rounded, size: 13, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'Kantong Utama Belajar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      allDone ? Icons.verified_rounded : Icons.trending_up_rounded,
                      size: 14,
                      color: AppTheme.primary900,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$progress%',
                      style: const TextStyle(
                        color: AppTheme.primary900,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Big Headline Status (Ala Bank Jago Saldo)
          Text(
            allDone ? 'Semua Modul Tuntas' : 'Progres Belajar $progress%',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            moduleSubtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.primary50,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Smooth Pill Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress > 0 ? (progress / 100).clamp(0.0, 1.0) : 0.0,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary500),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 18),

          // Action Pill Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary900,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                if (activeModule != null) {
                  Get.toNamed(Routes.EDUCATION_MODULE_DETAIL, arguments: activeModule.id)?.then((_) {
                    controller.fetchDashboard(forceRefresh: true);
                  });
                } else {
                  Get.toNamed(Routes.EDUCATION_MODULE_LIST)?.then((_) {
                    controller.fetchDashboard(forceRefresh: true);
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppTheme.primary900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primary900),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Pintasan Cepat (Quick Actions Grid 4-Kolom Ala Bank Jago)
  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final quickActions = [
      {
        'title': 'Edukasi',
        'icon': Icons.menu_book_rounded,
        'onTap': () {
          if (Get.isRegistered<MainNavController>()) {
            Get.find<MainNavController>().changeTab(1);
          } else {
            Get.toNamed(Routes.EDUCATION_MODULE_LIST);
          }
        },
      },
      {
        'title': 'Konseling',
        'icon': Icons.chat_bubble_rounded,
        'onTap': () {
          if (Get.isRegistered<MainNavController>()) {
            Get.find<MainNavController>().changeTab(2);
          } else {
            Get.toNamed(Routes.FORUM);
          }
        },
      },
      {
        'title': 'Catat Haid',
        'icon': Icons.calendar_month_rounded,
        'onTap': () => Get.toNamed(Routes.SELFCARE_PERIOD),
      },
      {
        'title': 'Kuis Trivia',
        'icon': Icons.quiz_rounded,
        'onTap': () => Get.toNamed(Routes.TRIVIA),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pintasan Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: quickActions.map((action) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: action['onTap'] as VoidCallback,
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceDark : AppTheme.primary50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? AppTheme.borderDark : AppTheme.primary200.withValues(alpha: 0.6),
                            width: 1.2,
                          ),
                          boxShadow: isDark ? null : AppTheme.cardShadow,
                        ),
                        child: Center(
                          child: Icon(
                            action['icon'] as IconData,
                            color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        action['title'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 5. Kantong Kaspro Section (Jago Pockets 2x2 Grid)
  Widget _buildPocketsSection(BuildContext context, List<DashboardModuleModel> modules, bool isDark) {
    final completedCount = modules.where((m) => m.progressPercentage == 100).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kantong Kaspro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
              ),
            ),
            TextButton(
              onPressed: () {
                if (Get.isRegistered<MainNavController>()) {
                  Get.find<MainNavController>().changeTab(1);
                }
              },
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppTheme.primary700,
              ),
              child: const Text('Lihat Semua', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 2x2 Pockets Grid
        Row(
          children: [
            Expanded(
              child: _buildPocketCard(
                context,
                title: 'Modul Edukasi',
                statusText: '$completedCount Modul Selesai',
                subtitle: 'Kesehatan reproduksi',
                badgeText: 'Belajar',
                icon: Icons.auto_stories_rounded,
                iconColor: AppTheme.primary700,
                isDark: isDark,
                onTap: () {
                  if (Get.isRegistered<MainNavController>()) {
                    Get.find<MainNavController>().changeTab(1);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPocketCard(
                context,
                title: 'Siklus & IMT',
                statusText: 'Kalkulator Tubuh',
                subtitle: 'Pantau haid & status gizi',
                badgeText: 'Self-Care',
                icon: Icons.favorite_rounded,
                iconColor: AppTheme.primary500,
                isDark: isDark,
                onTap: () => Get.toNamed(Routes.SELFCARE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPocketCard(
                context,
                title: 'Tanya Anonim',
                statusText: 'Ruang Privat',
                subtitle: 'Konseling ahli kampus',
                badgeText: 'Konseling',
                icon: Icons.lock_person_rounded,
                iconColor: AppTheme.primary900,
                isDark: isDark,
                onTap: () {
                  if (Get.isRegistered<MainNavController>()) {
                    Get.find<MainNavController>().changeTab(2);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPocketCard(
                context,
                title: 'Mood Diary',
                statusText: 'Refleksi Harian',
                subtitle: 'Catatan perasaan aman',
                badgeText: 'Jurnal',
                icon: Icons.sentiment_satisfied_alt_rounded,
                iconColor: AppTheme.primary700,
                isDark: isDark,
                onTap: () => Get.toNamed(Routes.DIARY),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Komponen Kartu Kantong (Pocket Card Ala Bank Jago)
  Widget _buildPocketCard(
    BuildContext context, {
    required String title,
    required String statusText,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : const Color(0xFFE2EBF0),
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top: Squircle Icon & Pill Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.primary900.withValues(alpha: 0.4) : AppTheme.primary50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(icon, color: isDark ? AppTheme.primary200 : iconColor, size: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Middle: Pocket Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                  ),
                ),
                const SizedBox(height: 3),

                // Status / Highlight Value
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                  ),
                ),
                const SizedBox(height: 2),

                // Subtitle
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 6. Rekomendasi & Wawasan Kaspro (Jago Insights Section)
  Widget _buildInsightsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wawasan & Aktivitas Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
          ),
        ),
        const SizedBox(height: 12),

        // Kartu Mitos vs Fakta Kaspro
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : const Color(0xFFE2EBF0),
              width: 1.2,
            ),
            boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primary900.withValues(alpha: 0.35) : AppTheme.primary50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.compare_arrows_rounded, color: isDark ? AppTheme.primary200 : AppTheme.primary700, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'UJI WAWASAN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mitos vs Fakta Kaspro',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Validasi mitos seputar menstruasi & pubertas.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: () => Get.toNamed(Routes.MYTH_FACT),
                child: const Text('Cek →', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Kartu Infografis Poster & Studi Kasus
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : const Color(0xFFE2EBF0),
              width: 1.2,
            ),
            boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primary900.withValues(alpha: 0.35) : AppTheme.primary50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.photo_library_rounded, color: isDark ? AppTheme.primary200 : AppTheme.primary700, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'MEDIA VISUAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Poster & Studi Kasus',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Infografis resmi dan analisis kasus hukum TPKS.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppTheme.primary200 : AppTheme.primary700,
                  side: BorderSide(color: isDark ? AppTheme.primary500 : AppTheme.primary700, width: 1.2),
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => Get.toNamed(Routes.CASES),
                child: const Text('Buka →', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7. Hasil Pencarian
  Widget _buildSearchResults(BuildContext context, List<DashboardModuleModel> modules, bool isDark) {
    final query = controller.searchQuery.value.toLowerCase();
    final results = modules.where((m) => m.title.toLowerCase().contains(query)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hasil Pencarian ("${controller.searchQuery.value}")',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
          ),
        ),
        const SizedBox(height: 12),
        if (results.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppTheme.borderDark : const Color(0xFFE2EBF0)),
              boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
            ),
            child: Center(
              child: Text(
                'Tidak ditemukan modul dengan kata kunci tersebut.',
                style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
              ),
            ),
          )
        else
          ...results.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppTheme.borderDark : const Color(0xFFE2EBF0)),
                  boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.primary900.withValues(alpha: 0.4) : AppTheme.primary50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${m.moduleNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    m.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                    ),
                  ),
                  subtitle: Text(
                    '${m.completedTopics}/${m.totalTopics} Submateri Selesai',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_rounded, size: 18, color: isDark ? AppTheme.primary200 : AppTheme.primary700),
                  onTap: () => Get.toNamed(Routes.EDUCATION_MODULE_DETAIL, arguments: m.id),
                ),
              )),
      ],
    );
  }
}
