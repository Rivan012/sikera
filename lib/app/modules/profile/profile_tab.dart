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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        final user = controller.user.value;
        return StateView(
          isLoading: controller.isLoading.value,
          loadingMessage: 'Memuat profil...',
          errorMessage: controller.errorMessage.value,
          isEmpty: user == null,
          emptyIcon: Icons.account_circle_outlined,
          emptyMessage:
              'Profil belum tersedia. Muat ulang untuk melihat data akunmu.',
          onRetry: controller.fetchProfile,
          child: user == null
              ? const SizedBox.shrink()
              : RefreshIndicator(
                  onRefresh: controller.fetchProfile,
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          children: [
                            _ProfileCard(user: user),
                            const SizedBox(height: 20),
                            _AcademicDetails(user: user),
                            const SizedBox(height: 16),
                            Text(
                              'Tampilan',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Card(
                              margin: EdgeInsets.zero,
                              child: Obx(
                                () => SwitchListTile(
                                  secondary: Icon(
                                    controller.isDarkMode.value
                                        ? Icons.dark_mode_outlined
                                        : Icons.light_mode_outlined,
                                  ),
                                  title: const Text(
                                    'Mode gelap',
                                    textAlign: TextAlign.center,
                                  ),
                                  subtitle: const Text(
                                    'Gunakan tampilan dengan latar gelap.',
                                    textAlign: TextAlign.center,
                                  ),
                                  value: controller.isDarkMode.value,
                                  onChanged: controller.toggleTheme,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const LegalLinks(),
                            const SizedBox(height: 8),
                            Center(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  foregroundColor: theme.colorScheme.error,
                                ),
                                onPressed: () => _confirmLogout(context),
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                ),
                                label: const Text('Keluar dari akun'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      }),
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final name = user.name.trim();
    final email = user.email?.trim() ?? '';
    final avatar = user.avatar?.trim() ?? '';
    final initials = name.isEmpty ? '' : name.characters.first.toUpperCase();
    final fallback = initials.isEmpty
        ? const Icon(
            Icons.person_outline_rounded,
            size: 32,
            color: AppTheme.primary900,
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              initials,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppTheme.primary900,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 34),
                child: Container(
                  width: double.infinity,
                  height: 68,
                  alignment: AlignmentDirectional.topStart,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        dark ? AppTheme.surfaceDark : AppTheme.primary900,
                        dark
                            ? AppTheme.softAccentSurfaceDark
                            : AppTheme.primary700,
                      ],
                    ),
                  ),
                  child: Image.asset(
                    'assets/logo/sikera_logo_putih.png',
                    width: 46,
                    height: 46,
                    cacheWidth: 160,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardColor,
                ),
                child: ClipOval(
                  child: ColoredBox(
                    color: AppTheme.primary50,
                    child: avatar.isEmpty
                        ? Center(child: fallback)
                        : Image.network(
                            avatar,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                            errorBuilder: (_, _, _) => Center(child: fallback),
                          ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Column(
              children: [
                Text(
                  name.isEmpty ? 'Nama belum tersedia' : name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? 'Email belum tersedia' : email,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            color: dark
                ? AppTheme.pocketSurfaceDark
                : AppTheme.pocketSurfaceLight,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 36,
              runSpacing: 12,
              children: [
                _metric(
                  context,
                  Icons.workspace_premium_outlined,
                  user.points,
                  'Poin belajar',
                ),
                _metric(
                  context,
                  Icons.date_range_outlined,
                  user.streakDays,
                  'Hari aktif',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, IconData icon, int count, String label) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            Text(
              '$count',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AcademicDetails extends StatelessWidget {
  const _AcademicDetails({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fields = [
      (Icons.badge_outlined, 'Nomor induk mahasiswa (NIM)', user.nim),
      (Icons.menu_book_outlined, 'Program studi', user.prodi),
      (Icons.account_balance_outlined, 'Fakultas', user.fakultas),
      (
        Icons.person_outline_rounded,
        'Jenis kelamin',
        switch (user.gender) {
          'L' => 'Laki-laki',
          'P' => 'Perempuan',
          _ => null,
        },
      ),
    ];
    return Column(
      children: [
        Text(
          'Informasi akademik',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = MediaQuery.textScalerOf(context);
                final columns = constraints.maxWidth >= 2 * scale.scale(230)
                    ? 2
                    : 1;
                return Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    for (final (index, (icon, label, value)) in fields.indexed)
                      SizedBox(
                        width: constraints.maxWidth / columns,
                        child: Column(
                          children: [
                            if (index >= columns) const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 9,
                                horizontal: 8,
                              ),
                              child: Column(
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 6,
                                    children: [
                                      Icon(
                                        icon,
                                        size: 19,
                                        color: theme.colorScheme.primary,
                                      ),
                                      Text(
                                        label,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    value != null && value.trim().isNotEmpty
                                        ? value
                                        : 'Belum tersedia',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
