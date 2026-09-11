import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import 'profile_controller.dart';

/// Tab User: Profil Mahasiswa, Data Akademik, dan Pengaturan Tampilan.
/// Mengikuti skill antislop-layoutmobile dan flutter-build-responsive-layout:
/// - Responsive constraint (maxWidth: 720px) terpusat.
/// - Avatar inisial dengan kontras jelas (R-23 honest placeholder).
/// - Chip statistik gamifikasi poin & hari aktif.
/// - Switcher dark/light mode fungsional di kedua tema (R-34).
/// - Dialog konfirmasi keluar akun untuk mencegah klik tidak sengaja.
class ProfileTab extends GetView<ProfileController> {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        final user = controller.user.value;

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          isEmpty: false,
          onRetry: controller.fetchProfile,
          child: RefreshIndicator(
            color: AppTheme.primary700,
            onRefresh: controller.fetchProfile,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  children: [
                    // Profil Header Card
                    _buildProfileHeaderCard(context, user, isDark),
                    const SizedBox(height: 16),

                    // Informasi Akademik & Mahasiswa
                    _buildAcademicCard(context, user, isDark),
                    const SizedBox(height: 16),

                    // Pengaturan Tampilan (Dark/Light Mode)
                    _buildThemeSettingsCard(context, isDark),
                    const SizedBox(height: 24),

                    // Tombol Keluar Akun
                    _buildLogoutButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeaderCard(BuildContext context, dynamic user, bool isDark) {
    final String initial = (user?.name != null && user!.name.isNotEmpty)
        ? user.name[0].toUpperCase()
        : 'M';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary900.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Mahasiswa SIKERA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'mhs@unib.ac.id',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 18),

          // Gamifikasi Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF243038) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(AppTheme.jagoPillRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${user?.points ?? 0} Poin',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF243038) : const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(AppTheme.jagoPillRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Color(0xFFEA580C), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${user?.streakDays ?? 0} Hari Aktif',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicCard(BuildContext context, dynamic user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Icon(Icons.school_outlined, size: 20, color: isDark ? AppTheme.primary500 : AppTheme.primary700),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Akademik',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Nomor Induk Mahasiswa (NIM)', user?.nim ?? '-', isDark),
          const Divider(height: 20),
          _buildInfoRow('Program Studi', user?.prodi ?? '-', isDark),
          const Divider(height: 20),
          _buildInfoRow('Fakultas', user?.fakultas ?? '-', isDark),
          const Divider(height: 20),
          _buildInfoRow('Jenis Kelamin', user?.gender == 'L' ? 'Laki-laki' : (user?.gender == 'P' ? 'Perempuan' : '-'), isDark),
        ],
      ),
    );
  }

  Widget _buildThemeSettingsCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppTheme.jagoPocketShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Icon(Icons.palette_outlined, size: 20, color: isDark ? AppTheme.primary500 : AppTheme.primary700),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Pengaturan Tampilan',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Mode Gelap (Dark Mode)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
                  ),
                ),
                subtitle: Text(
                  'Menyesuaikan pencahayaan layar agar lebih nyaman di mata',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                ),
                value: controller.isDarkMode.value,
                activeTrackColor: isDark ? AppTheme.primary500 : AppTheme.primary700,
                activeThumbColor: Colors.white,
                onChanged: controller.toggleTheme,
              )),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.statusError,
          side: BorderSide(color: AppTheme.statusError.withValues(alpha: 0.35), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.jagoPillRadius)),
        ),
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Keluar dari Akun',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun SIKERA? Progres belajar Anda tetap tersimpan aman di server.',
          style: TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusError,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.jagoPillRadius)),
            ),
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
          ),
        ),
      ],
    );
  }
}
