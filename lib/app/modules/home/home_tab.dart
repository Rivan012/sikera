import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_pages.dart';
import '../education/widgets/module_banner.dart';
import '../main_nav/main_nav_controller.dart';
import 'home_controller.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  void _openTab(int index, String fallback) {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(index);
    } else {
      Get.toNamed(fallback);
    }
  }

  void _openModule(DashboardModuleModel? module) {
    Get.toNamed(
      module == null
          ? Routes.EDUCATION_MODULE_LIST
          : Routes.EDUCATION_MODULE_DETAIL,
      arguments: module?.id,
    )?.then((_) => controller.fetchDashboard(forceRefresh: true));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: Obx(() {
        final data = controller.dashboardData.value;
        final modules = data?.modules ?? <DashboardModuleModel>[];
        final active =
            modules.firstWhereOrNull((m) => m.progressPercentage < 100) ??
            modules.firstOrNull;
        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isEmpty
              ? null
              : controller.errorMessage.value,
          onRetry: () => controller.fetchDashboard(forceRefresh: true),
          child: RefreshIndicator(
            color: AppTheme.primary700,
            onRefresh: () => controller.fetchDashboard(forceRefresh: true),
            child: SingleChildScrollView(
              key: const PageStorageKey('home-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        _buildAccountSummary(
                          context,
                          controller.currentUser.value,
                          data,
                        ),
                        const SizedBox(height: 26),
                        _buildBanner(context, active, modules),
                        const SizedBox(height: 24),
                        _buildSearchBar(context),
                        const SizedBox(height: 16),
                        if (controller.searchQuery.value.isNotEmpty)
                          _buildSearchResults(context, modules)
                        else ...[
                          _LearningModules(
                            modules: modules,
                            onOpen: _openModule,
                          ),
                          const SizedBox(height: 28),
                          _buildServices(context),
                          const SizedBox(height: 28),
                          _buildInsights(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Image.asset(
          'assets/logo/sikera_logo_putih.png',
          width: 48,
          height: 48,
          excludeFromSemantics: true,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'SIKERA',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Buka profil',
          onPressed: () => _openTab(3, Routes.HOME),
          icon: Icon(
            Icons.person_outline_rounded,
            color: colors.primary,
            size: 28,
          ),
        ),
        IconButton(
          tooltip: 'Notifikasi SIKERA',
          onPressed: () => Get.snackbar(
            'Notifikasi SIKERA',
            'Seluruh materi dan layanan konseling siap diakses.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: colors.surface,
            colorText: colors.onSurface,
            margin: const EdgeInsets.all(16),
          ),
          icon: Icon(
            Icons.notifications_outlined,
            color: colors.primary,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSummary(
    BuildContext context,
    UserModel? user,
    DashboardDataModel? data,
  ) {
    final firstName = user?.name.trim().split(' ').firstOrNull;
    final completed = data?.modules
        .where((m) => m.progressPercentage == 100)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat datang, ${firstName == null || firstName.isEmpty ? 'Mahasiswa' : firstName}',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AccountMetric(
                label: 'Poin Anda',
                value: user?.points.toString() ?? 'Belum tersedia',
                icon: Icons.toll_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AccountMetric(
                label: 'Streak',
                value: user == null
                    ? 'Belum tersedia'
                    : '${user.streakDays} hari',
                icon: Icons.local_fire_department_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AccountMetric(
                label: 'Modul tuntas',
                value: completed == null
                    ? 'Belum tersedia'
                    : '$completed/${data!.modules.length}',
                icon: Icons.task_alt_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBanner(
    BuildContext context,
    DashboardModuleModel? active,
    List<DashboardModuleModel> modules,
  ) {
    return Material(
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.surfaceDark
          : AppTheme.primary900,
      child: InkWell(
        key: const ValueKey('learning-banner'),
        onTap: () => _openModule(active),
        child: AspectRatio(
          aspectRatio: 1200 / 540,
          child: ModuleBanner(
            bannerImage: active?.bannerImage,
            moduleNumber: active?.moduleNumber ?? 1,
            title: active?.title ?? 'Modul Edukasi SIKERA',
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppTheme.radiusMd);
    return TextField(
      controller: controller.searchController,
      onChanged: (value) => controller.searchQuery.value = value.trim(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari modul edukasi',
        hintStyle: TextStyle(color: _secondary(context), fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: colors.primary, size: 25),
        suffixIcon: controller.searchQuery.value.isEmpty
            ? null
            : IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: () {
                  controller.searchController.clear();
                  controller.searchQuery.value = '';
                },
                icon: const Icon(Icons.close_rounded),
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: _border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildServices(BuildContext context) {
    final services = <({String title, IconData icon, VoidCallback action})>[
      (
        title: 'Edukasi',
        icon: Icons.menu_book_rounded,
        action: () => _openTab(1, Routes.EDUCATION_MODULE_LIST),
      ),
      (
        title: 'Konseling',
        icon: Icons.chat_bubble_outline_rounded,
        action: () => _openTab(2, Routes.FORUM),
      ),
      if (controller.currentUser.value?.gender != 'L')
        (
          title: 'Catat Haid',
          icon: Icons.calendar_month_rounded,
          action: () => Get.toNamed(Routes.SELFCARE_PERIOD),
        ),
      (
        title: 'Kuis Trivia',
        icon: Icons.quiz_outlined,
        action: () => Get.toNamed(Routes.TRIVIA),
      ),
      (
        title: 'Siklus & IMT',
        icon: Icons.favorite_outline_rounded,
        action: () => Get.toNamed(Routes.SELFCARE),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jelajah Layanan',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
            final columns = (constraints.maxWidth / (88 * scale)).floor().clamp(
              2,
              6,
            );
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 18,
              children: services
                  .map(
                    (service) => SizedBox(
                      width: width,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: service.action,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: _softSurface(context),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd,
                                    ),
                                    border: Border.all(
                                      color: _border(context),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      service.icon,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: 26,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  service.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInsights(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Wawasan & Aktivitas',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 14),
      _Surface(
        child: Column(
          children: [
            _InsightLink(
              title: 'Mitos vs Fakta Kaspro',
              subtitle: 'Uji wawasan seputar menstruasi & pubertas.',
              icon: Icons.compare_arrows_rounded,
              onTap: () => Get.toNamed(Routes.MYTH_FACT),
            ),
            Divider(height: 1, indent: 68, color: _border(context)),
            _InsightLink(
              title: 'Poster & Studi Kasus',
              subtitle: 'Baca analisis kasus hukum TPKS.',
              icon: Icons.photo_library_outlined,
              onTap: () => Get.toNamed(Routes.CASES),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildSearchResults(
    BuildContext context,
    List<DashboardModuleModel> modules,
  ) {
    final query = controller.searchQuery.value.toLowerCase();
    final results = modules.where((m) => m.title.toLowerCase().contains(query));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Hasil pencarian: "${controller.searchQuery.value}"',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (results.isEmpty)
          _Surface(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Tidak ditemukan modul dengan kata kunci tersebut.',
                style: TextStyle(color: _secondary(context)),
              ),
            ),
          )
        else
          ...results.map(
            (module) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Surface(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    module.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${module.completedTopics}/${module.totalTopics} Submateri Selesai',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openModule(module),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LearningModules extends StatefulWidget {
  const _LearningModules({required this.modules, required this.onOpen});
  final List<DashboardModuleModel> modules;
  final ValueChanged<DashboardModuleModel?> onOpen;

  @override
  State<_LearningModules> createState() => _LearningModulesState();
}

class _LearningModulesState extends State<_LearningModules> {
  int? _selectedId;

  @override
  Widget build(BuildContext context) {
    final modules = widget.modules;
    final selected =
        modules.firstWhereOrNull((m) => m.id == _selectedId) ??
        modules.firstWhereOrNull((m) => m.progressPercentage < 100) ??
        modules.firstOrNull;
    final index = selected == null ? 0 : modules.indexOf(selected);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Ruang Belajar',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
              onPressed: () => widget.onOpen(null),
              child: const Text('Semua modul'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _Surface(
          elevated: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: selected == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.menu_book_rounded, size: 32),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum ada modul tersedia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tarik halaman untuk memuat ulang atau buka daftar modul.',
                        style: TextStyle(
                          color: _secondary(context),
                          height: 1.4,
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onOpen(null),
                        child: const Text('Buka daftar modul'),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Modul ${selected.moduleNumber}',
                                  style: TextStyle(
                                    color: _secondary(context),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  selected.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filledTonal(
                            tooltip: 'Buka ${selected.title}',
                            style: IconButton.styleFrom(
                              backgroundColor: _softSurface(context),
                              foregroundColor: colors.primary,
                              minimumSize: const Size(48, 48),
                            ),
                            onPressed: () => widget.onOpen(selected),
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        selected.progressPercentage == 100
                            ? 'Modul selesai. Baca kembali materimu.'
                            : 'Lanjutkan proses belajarmu.',
                        style: TextStyle(
                          fontSize: 13,
                          color: _secondary(context),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ModuleMetric(
                              label: 'Submateri',
                              value: '${selected.totalTopics}',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ModuleMetric(
                              label: 'Selesai',
                              value: '${selected.completedTopics}',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ModuleMetric(
                              label: 'Progres',
                              value: '${selected.progressPercentage}%',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: (selected.progressPercentage / 100).clamp(0, 1),
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: _softSurface(context),
                        color: colors.primary,
                        semanticsLabel: 'Progres belajar ${selected.title}',
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => widget.onOpen(selected),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            selected.progressPercentage == 100
                                ? 'Review Materi Belajar'
                                : 'Lanjutkan Belajar',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (modules.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Modul sebelumnya',
                onPressed: index > 0
                    ? () => setState(() => _selectedId = modules[index - 1].id)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Flexible(
                child: Text(
                  '${index + 1} dari ${modules.length} modul',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _secondary(context)),
                ),
              ),
              IconButton(
                tooltip: 'Modul berikutnya',
                onPressed: index < modules.length - 1
                    ? () => setState(() => _selectedId = modules[index + 1].id)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AccountMetric extends StatelessWidget {
  const _AccountMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 12, color: _secondary(context))),
      const SizedBox(height: 7),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ],
  );
}

class _ModuleMetric extends StatelessWidget {
  const _ModuleMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: _border(context)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: _secondary(context)),
        ),
      ],
    ),
  );
}

class _InsightLink extends StatelessWidget {
  const _InsightLink({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.all(16),
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
    title: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: _secondary(context)),
      ),
    ),
    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    onTap: onTap,
  );
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child, this.elevated = false});
  final Widget child;
  final bool elevated;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      boxShadow: elevated && Theme.of(context).brightness == Brightness.light
          ? AppTheme.cardShadow
          : null,
    ),
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: BorderSide(color: _border(context), width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    ),
  );
}

Color _secondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppTheme.textSecondaryDark
    : AppTheme.textSecondaryLight;
Color _border(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppTheme.borderDark
    : AppTheme.borderLight;
Color _softSurface(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppTheme.softAccentSurfaceDark
    : AppTheme.primary50;
