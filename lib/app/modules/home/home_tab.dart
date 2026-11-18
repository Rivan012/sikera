import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/dashboard_model.dart';
import '../../routes/app_pages.dart';
import '../main_nav/main_nav_controller.dart';
import 'home_controller.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key, this.enableAutoSlide});

  /// Opsional untuk mengaktifkan/menonaktifkan geser otomatis pada pengujian.
  /// Secara bawaan aktif di aplikasi nyata dan menghormati pengaturan aksesibilitas.
  final bool? enableAutoSlide;

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;
    final profileBg = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final profileBorder = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final modules =
              controller.dashboardData.value?.modules ??
              <DashboardModuleModel>[];
          final firstName = controller.currentUser.value?.name
              .trim()
              .split(' ')
              .firstOrNull;
          return StateView(
            isLoading: controller.isLoading.value,
            loadingMessage: 'Memuat beranda...',
            errorMessage: controller.errorMessage.value.isEmpty
                ? null
                : controller.errorMessage.value,
            onRetry: () => controller.fetchDashboard(forceRefresh: true),
            child: RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
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
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.pocketSurfaceLight
                                      : AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                  border: Border.all(
                                    color: profileBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/logo/sikera_logo_putih.png',
                                  fit: BoxFit.contain,
                                  excludeFromSemantics: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'SIKERA',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: headingColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              Material(
                                color: profileBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                  side: BorderSide(
                                    color: profileBorder,
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  tooltip: 'Buka profil',
                                  onPressed: () => _openTab(3, Routes.HOME),
                                  icon: const Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Halo, ${firstName == null || firstName.isEmpty ? 'Mahasiswa' : firstName}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: headingColor,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Belajar dan pahami kesehatan reproduksimu.',
                            style: TextStyle(
                              color: _secondary(context),
                              fontSize: 14.5,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (controller.searchQuery.value.isEmpty) ...[
                            _LearningModules(
                              modules: modules,
                              onOpen: _openModule,
                              enableAutoSlide: enableAutoSlide,
                            ),
                            const SizedBox(height: 24),
                          ],
                          _buildSearchBar(context),
                          const SizedBox(height: 24),
                          if (controller.searchQuery.value.isNotEmpty)
                            _buildSearchResults(context, modules)
                          else
                            _buildServicesGrid(context),
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
  }

  Widget _buildSearchBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: controller.searchController,
      onChanged: (value) => controller.searchQuery.value = value.trim(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari modul edukasi',
        prefixIcon: const Icon(Icons.search_rounded),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
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
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMale = controller.currentUser.value?.gender == 'L';
    final cardBg = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final cardBorder = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;

    Widget artwork(String name) => Image.asset(
      'assets/icon/home/$name.jpg',
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );

    final services = <({String title, Widget icon, VoidCallback action})>[
      (
        title: 'Edukasi',
        icon: artwork('edukasi'),
        action: () => _openTab(1, Routes.EDUCATION_MODULE_LIST),
      ),
      (
        title: 'Konseling',
        icon: artwork('konsultasi'),
        action: () => _openTab(2, Routes.FORUM),
      ),
      if (!isMale)
        (
          title: 'Catat Haid',
          icon: artwork('catat-haid'),
          action: () => Get.toNamed(Routes.SELFCARE_PERIOD),
        )
      else
        (
          title: 'Kebersihan Diri',
          icon: const Icon(Icons.clean_hands_outlined),
          action: () => Get.toNamed(Routes.SELFCARE_HYGIENE_GUIDE),
        ),
      (
        title: 'Siklus & IMT',
        icon: artwork('siklus-dan-imt'),
        action: () => Get.toNamed(Routes.SELFCARE),
      ),
      (
        title: 'Kalkulator IMT',
        icon: artwork('kalkulator'),
        action: () => Get.toNamed(Routes.SELFCARE_BMI),
      ),
      (
        title: 'Kuis Trivia',
        icon: const Icon(Icons.quiz_outlined),
        action: () => Get.toNamed(Routes.TRIVIA),
      ),
      (
        title: 'Poster Visual',
        icon: const Icon(Icons.collections_bookmark_outlined),
        action: () => Get.toNamed(Routes.POSTERS),
      ),
      (
        title: 'Studi Kasus',
        icon: const Icon(Icons.assignment_outlined),
        action: () => Get.toNamed(Routes.CASES),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Jelajah Layanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih layanan edukasi, pencatatan mandiri, atau ruang diskusi',
          style: TextStyle(fontSize: 13.5, color: _secondary(context)),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: cardBorder, width: 1),
            boxShadow: isDark ? null : AppTheme.cardShadow,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scaledBase = MediaQuery.textScalerOf(context).scale(16);
              final cols = scaledBase >= 26
                  ? 2
                  : constraints.maxWidth < 290
                  ? 3
                  : 4;

              final rows = <Widget>[];
              for (var i = 0; i < services.length; i += cols) {
                if (rows.isNotEmpty) {
                  rows.add(const SizedBox(height: 14));
                }
                final rowItems = <Widget>[];
                for (var c = 0; c < cols; c++) {
                  if (c > 0) {
                    rowItems.add(const SizedBox(width: 8));
                  }
                  final idx = i + c;
                  if (idx < services.length) {
                    final item = services[idx];
                    rowItems.add(
                      Expanded(
                        child: _ServiceLauncherTile(
                          title: item.title,
                          icon: item.icon,
                          onTap: item.action,
                        ),
                      ),
                    );
                  } else {
                    rowItems.add(const Expanded(child: SizedBox.shrink()));
                  }
                }
                rows.add(
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rowItems,
                  ),
                );
              }

              return Column(mainAxisSize: MainAxisSize.min, children: rows);
            },
          ),
        ),
      ],
    );
  }

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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (results.isEmpty)
          Text(
            'Tidak ditemukan modul dengan kata kunci tersebut.',
            style: TextStyle(color: _secondary(context), height: 1.5),
          )
        else
          ...results.map(
            (module) => _ServiceLink(
              title: module.title,
              subtitle:
                  '${module.completedTopics}/${module.totalTopics} submateri selesai',
              icon: Icons.menu_book_outlined,
              onTap: () => _openModule(module),
            ),
          ),
      ],
    );
  }
}

class _LearningModules extends StatefulWidget {
  const _LearningModules({
    required this.modules,
    required this.onOpen,
    this.enableAutoSlide,
  });

  final List<DashboardModuleModel> modules;
  final ValueChanged<DashboardModuleModel?> onOpen;
  final bool? enableAutoSlide;

  @override
  State<_LearningModules> createState() => _LearningModulesState();
}

class _LearningModulesState extends State<_LearningModules> {
  static const Duration _autoSlideInterval = Duration(seconds: 4);

  int? _selectedId;
  int _slideDirection = 1;
  Timer? _autoSlideTimer;
  bool _reduceMotion = false;

  bool get _shouldAutoSlide {
    final isTestBinding = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');
    final enabled = widget.enableAutoSlide ?? !isTestBinding;
    return enabled && !_reduceMotion && widget.modules.length > 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _syncAutoSlideTimer();
  }

  @override
  void didUpdateWidget(covariant _LearningModules oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modules.length != widget.modules.length ||
        oldWidget.enableAutoSlide != widget.enableAutoSlide) {
      _syncAutoSlideTimer();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _syncAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
    if (_shouldAutoSlide) {
      _autoSlideTimer = Timer.periodic(_autoSlideInterval, (_) {
        if (!mounted || widget.modules.length <= 1) return;
        _stepSlide(1, fromUser: false);
      });
    }
  }

  DashboardModuleModel? _resolveSelected(List<DashboardModuleModel> modules) {
    return modules.firstWhereOrNull((m) => m.id == _selectedId) ??
        modules.firstWhereOrNull((m) => m.progressPercentage < 100) ??
        modules.firstOrNull;
  }

  void _stepSlide(int delta, {required bool fromUser}) {
    final modules = widget.modules;
    if (modules.length <= 1) return;
    final current = _resolveSelected(modules);
    final currentIndex = current == null ? 0 : modules.indexOf(current);
    final nextIndex = (currentIndex + delta + modules.length) % modules.length;
    setState(() {
      _slideDirection = delta >= 0 ? 1 : -1;
      _selectedId = modules[nextIndex].id;
    });
    if (fromUser) {
      _syncAutoSlideTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final modules = widget.modules;
    final selected = _resolveSelected(modules);
    final index = selected == null ? 0 : modules.indexOf(selected);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;
    final bannerBorder = isDark
        ? AppTheme.borderDark
        : AppTheme.strongBorderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Ruang Belajar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: headingColor,
              ),
            ),
            TextButton(
              onPressed: () => widget.onOpen(null),
              child: const Text(
                'Semua modul',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        if (modules.isNotEmpty) ...[
          Text(
            '${modules.where((m) => m.progressPercentage == 100).length} dari ${modules.length} modul selesai',
            style: TextStyle(color: _secondary(context), fontSize: 13),
          ),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: modules.length <= 1
              ? null
              : (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < -180) {
                    _stepSlide(1, fromUser: true);
                  } else if (velocity > 180) {
                    _stepSlide(-1, fromUser: true);
                  }
                },
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: bannerBorder, width: 1),
            ),
            child: selected == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada modul tersedia',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: headingColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tarik halaman untuk memuat ulang atau buka daftar modul.',
                        style: TextStyle(
                          color: _secondary(context),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => widget.onOpen(null),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onPrimaryContainer,
                        ),
                        child: const Text('Buka daftar modul'),
                      ),
                    ],
                  )
                : AnimatedSwitcher(
                    duration: _reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final isIncoming =
                          child.key == ValueKey<int>(selected.id);
                      final beginOffset = isIncoming
                          ? Offset(0.14 * _slideDirection, 0)
                          : Offset(-0.14 * _slideDirection, 0);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: beginOffset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildSlideContent(
                      context,
                      module: selected,
                      isDark: isDark,
                      headingColor: headingColor,
                      colors: colors,
                    ),
                  ),
          ),
        ),
        if (modules.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ExcludeSemantics(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: List.generate(modules.length, (dotIndex) {
                      final active = dotIndex == index;
                      return AnimatedContainer(
                        duration: _reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 200),
                        width: active ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active
                              ? (isDark
                                    ? AppTheme.primary500
                                    : AppTheme.primary700)
                              : (isDark
                                    ? AppTheme.elevatedSurfaceDark
                                    : AppTheme.strongBorderLight),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusPill,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Modul sebelumnya',
                onPressed: () => _stepSlide(-1, fromUser: true),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Flexible(
                child: Text(
                  '${index + 1} dari ${modules.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _secondary(context),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Modul berikutnya',
                onPressed: () => _stepSlide(1, fromUser: true),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSlideContent(
    BuildContext context, {
    required DashboardModuleModel module,
    required bool isDark,
    required Color headingColor,
    required ColorScheme colors,
  }) {
    final completed = module.progressPercentage == 100;
    final started = module.progressPercentage > 0;
    final statusLabel = completed
        ? 'Selesai'
        : started
        ? 'Dalam Proses'
        : 'Belum Dimulai';
    final statusBg = completed
        ? (isDark ? AppTheme.elevatedSurfaceDark : AppTheme.successLight)
        : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight);
    final statusFg = completed
        ? (isDark ? AppTheme.primary200 : AppTheme.success)
        : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight);
    final chipBg = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;

    return Column(
      key: ValueKey<int>(module.id),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                'Modul ${module.moduleNumber}',
                style: TextStyle(
                  color: headingColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusFg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          module.title,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: headingColor,
            height: 1.25,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(
              '${module.completedTopics} dari ${module.totalTopics} submateri selesai',
              style: TextStyle(color: _secondary(context), fontSize: 13),
            ),
            Text(
              '${module.progressPercentage}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: headingColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (module.progressPercentage / 100).clamp(0, 1),
          minHeight: 6,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          backgroundColor: colors.surface,
          color: colors.primary,
          semanticsLabel: 'Progres belajar ${module.title}',
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          key: const ValueKey('learning-banner'),
          onPressed: () => widget.onOpen(module),
          child: Text(
            completed
                ? 'Baca Ulang Materi'
                : !started
                ? 'Mulai Belajar'
                : 'Lanjutkan Belajar',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _ServiceLauncherTile extends StatelessWidget {
  const _ServiceLauncherTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 84),
        child: AspectRatio(
          aspectRatio: 1,
          child: IconButton(
            tooltip: title,
            onPressed: onTap,
            icon: icon,
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              iconSize: 32,
              foregroundColor: isDark
                  ? AppTheme.primary200
                  : AppTheme.primary700,
              backgroundColor: isDark
                  ? AppTheme.softAccentSurfaceDark
                  : AppTheme.primary50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceLink extends StatelessWidget {
  const _ServiceLink({
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
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Icon(icon, color: _secondary(context), size: 24),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: _secondary(context),
                height: 1.4,
              ),
            ),
          ),
          onTap: onTap,
        ),
        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
      ],
    ),
  );
}

Color _secondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppTheme.textSecondaryDark
    : AppTheme.textSecondaryLight;
