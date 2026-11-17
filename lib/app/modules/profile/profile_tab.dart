import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/user_model.dart';
import '../legal/widgets/legal_links.dart';
import 'profile_controller.dart';

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
          loadingMessage: 'Memuat profil...',
          errorMessage: controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : null,
          isEmpty: user == null,
          emptyMessage:
              'Profil belum tersedia. Muat ulang untuk melihat data akunmu.',
          onRetry: controller.fetchProfile,
          child: RefreshIndicator(
            color: AppTheme.primary700,
            onRefresh: controller.fetchProfile,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  children: [
                    _buildProfileHeader(context, user, isDark),
                    const SizedBox(height: 32),
                    Text(
                      'Informasi akademik',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAcademicCard(context, user, isDark),
                    const SizedBox(height: 32),
                    Text(
                      'Tampilan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Mode gelap'),
                        subtitle: const Text(
                          'Gunakan tampilan dengan latar gelap.',
                        ),
                        value: controller.isDarkMode.value,
                        activeTrackColor: isDark
                            ? AppTheme.primary500
                            : AppTheme.primary700,
                        activeThumbColor: Colors.white,
                        onChanged: controller.toggleTheme,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    const LegalLinks(),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      onPressed: () => _confirmLogout(context),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Keluar dari akun'),
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

  Widget _buildProfileHeader(
    BuildContext context,
    UserModel? user,
    bool isDark,
  ) {
    final name = user?.name.trim() ?? '';
    final email = user?.email?.trim() ?? '';
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isDark
                  ? AppTheme.softAccentSurfaceDark
                  : AppTheme.primary50,
              foregroundColor: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.primary900,
              child: name.isEmpty
                  ? const Icon(Icons.person_outline, size: 28)
                  : Text(
                      name.characters.first.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'Nama belum tersedia' : name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email.isEmpty ? 'Email belum tersedia' : email,
                    style: TextStyle(color: secondaryColor, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (user != null) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _buildMetric(
                context,
                '${user.points}',
                'Poin belajar',
                secondaryColor,
              ),
              _buildMetric(
                context,
                '${user.streakDays}',
                'Hari aktif',
                secondaryColor,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String value,
    String label,
    Color secondaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: secondaryColor, fontSize: 13)),
      ],
    );
  }

  Widget _buildAcademicCard(
    BuildContext context,
    UserModel? user,
    bool isDark,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoRow('Nomor induk mahasiswa (NIM)', user?.nim, isDark),
            const Divider(height: 32),
            _buildInfoRow('Program studi', user?.prodi, isDark),
            const Divider(height: 32),
            _buildInfoRow('Fakultas', user?.fakultas, isDark),
            const Divider(height: 32),
            _buildInfoRow(
              'Jenis kelamin',
              user?.gender == 'L'
                  ? 'Laki-laki'
                  : user?.gender == 'P'
                  ? 'Perempuan'
                  : null,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value == null || value.trim().isEmpty ? 'Belum tersedia' : value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.5,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.primary900,
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu perlu masuk kembali untuk mengakses akun SIKERA.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 48),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
