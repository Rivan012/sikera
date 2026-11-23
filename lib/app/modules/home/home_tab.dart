import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/dashboard_model.dart';
import '../../routes/app_pages.dart';
import '../education/widgets/module_banner.dart';
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
    final brandTitleColor = isDark ? AppTheme.primary200 : AppTheme.primary700;
    final brandSubtitleColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.primary700;
    final profileBg = isDark
        ? AppTheme.softAccentSurfaceDark
        : const Color(0xFFEAF7FC);
    final profileBorder = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final profileIconColor = isDark ? AppTheme.primary200 : AppTheme.primary700;

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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: isDark ? 48 : 54,
                                height: isDark ? 48 : 54,
                                padding: EdgeInsets.all(isDark ? 3 : 0),
                                decoration: isDark
                                    ? BoxDecoration(
                                        color: AppTheme.pocketSurfaceLight,
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMd,
                                        ),
                                      )
                                    : null,
                                child: Image.asset(
                                  'assets/logo/sikera_logo_putih.png',
                                  fit: BoxFit.contain,
                                  excludeFromSemantics: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SIKERA',
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                        color: brandTitleColor,
                                        letterSpacing: -0.3,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Sistem Informasi Kesehatan Remaja',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: brandSubtitleColor,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: profileBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: profileBorder,
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  tooltip: 'Buka profil',
                                  onPressed: () => _openTab(2, Routes.HOME),
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size(48, 48),
                                    foregroundColor: profileIconColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.person_outline_rounded,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Halo, ${firstName == null || firstName.isEmpty ? 'Mahasiswa' : firstName}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: headingColor,
                              height: 1.18,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Belajar dan pahami kesehatan reproduksimu.',
                            style: TextStyle(
                              color: _secondary(context),
                              fontSize: 14.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSearchBar(context),
                          if (controller.searchQuery.value.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildSearchResults(context, modules),
                          ] else ...[
                            const SizedBox(height: 22),
                            _LearningModules(
                              modules: modules,
                              onOpen: _openModule,
                              enableAutoSlide: enableAutoSlide,
                            ),
                            const SizedBox(height: 22),
                            _buildServicesGrid(context),
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
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final iconColor = isDark ? AppTheme.primary500 : AppTheme.primary700;

    return TextField(
      controller: controller.searchController,
      onChanged: (value) => controller.searchQuery.value = value.trim(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari modul edukasi',
        filled: true,
        fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        prefixIcon: Icon(Icons.search_rounded, color: iconColor, size: 22),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          borderSide: BorderSide(color: colors.primary, width: 1.8),
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
    final cardBg = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final cardBorder = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;

    Widget artwork(String assetPath, IconData fallbackIcon) => Image.asset(
      assetPath,
      bundle: _ServiceIconBundle.instance,
      scale: 1,
      width: 60,
      height: 60,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) =>
          Icon(fallbackIcon, size: 32, color: headingColor),
    );

    final services =
        <
          ({
            String title,
            Widget icon,
            Color tint,
            VoidCallback action,
          })
        >[
          (
            title: 'Edukasi',
            icon: artwork(
              'assets/icon/edukasi-icon.svg',
              Icons.menu_book_rounded,
            ),
            tint: isDark ? const Color(0xFF123A4F) : const Color(0xFFE8F6FC),
            action: () => _openTab(1, Routes.EDUCATION_MODULE_LIST),
          ),
          (
            title: 'Catat Haid',
            icon: artwork(
              'assets/icon/catat-haid-icon.svg',
              Icons.calendar_month_rounded,
            ),
            tint: isDark ? const Color(0xFF2E2233) : const Color(0xFFFDEFF3),
            action: () => Get.toNamed(Routes.SELFCARE_PERIOD),
          ),
          (
            title: 'Kalkulator IMT',
            icon: artwork(
              'assets/icon/kalkulator-icon.svg',
              Icons.calculate_rounded,
            ),
            tint: isDark ? const Color(0xFF2C2B22) : const Color(0xFFFFF6DF),
            action: () => Get.toNamed(Routes.SELFCARE_BMI),
          ),
        ];

    Widget buildTile(
      ({String title, Widget icon, Color tint, VoidCallback action}) item,
    ) {
      return TextButton(
        onPressed: item.action,
        style: TextButton.styleFrom(
          alignment: Alignment.topCenter,
          backgroundColor: item.tint,
          foregroundColor: headingColor,
          minimumSize: const Size(48, 108),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 60, child: Center(child: item.icon)),
            const SizedBox(height: 10),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: headingColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Jelajah Layanan',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: headingColor,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
            border: Border.all(color: cardBorder, width: 1),
            boxShadow: isDark ? null : AppTheme.cardShadow,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              final scaledLabel = MediaQuery.textScalerOf(context).scale(13);
              final fitsSingleRow =
                  constraints.maxWidth >= 240 && scaledLabel <= 18;
              if (fitsSingleRow) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < services.length; i++) ...[
                        if (i > 0) const SizedBox(width: gap),
                        Expanded(child: buildTile(services[i])),
                      ],
                    ],
                  ),
                );
              }
              final columns = constraints.maxWidth >= 260 ? 2 : 1;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final item in services)
                    SizedBox(width: width, child: buildTile(item)),
                ],
              );
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
    final actionColor = isDark ? AppTheme.primary200 : AppTheme.primary700;
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
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: headingColor,
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: () => widget.onOpen(null),
              style: TextButton.styleFrom(
                foregroundColor: actionColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text(
                'Semua modul',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        if (modules.isNotEmpty) ...[
          Text(
            '${modules.where((m) => m.progressPercentage == 100).length} dari ${modules.length} modul selesai',
            style: TextStyle(color: _secondary(context), fontSize: 13.5),
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
            padding: selected == null
                ? const EdgeInsets.fromLTRB(18, 16, 18, 18)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: selected == null
                  ? null
                  : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
              gradient: selected == null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [
                              AppTheme.softAccentSurfaceDark,
                              AppTheme.surfaceDark,
                            ]
                          : const [Color(0xFFDCF5FC), Color(0xFFF0FAFE)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: selected == null
                  ? Border.all(color: bannerBorder, width: 1)
                  : null,
              boxShadow: isDark ? null : AppTheme.cardShadow,
            ),
            foregroundDecoration: selected == null
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.borderDark
                          : AppTheme.borderLight,
                      width: 1,
                    ),
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
                    ),
                  ),
          ),
        ),
        if (modules.length > 1) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                tooltip: 'Modul sebelumnya',
                onPressed: () => _stepSlide(-1, fromUser: true),
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: headingColor,
                ),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Center(
                  child: Semantics(
                    label: 'Modul ${index + 1} dari ${modules.length}',
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
                            width: active ? 24 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: active
                                  ? (isDark
                                        ? AppTheme.primary500
                                        : AppTheme.primary700)
                                  : (isDark
                                        ? AppTheme.elevatedSurfaceDark
                                        : AppTheme.primary200),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusPill,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Modul berikutnya',
                onPressed: () => _stepSlide(1, fromUser: true),
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: headingColor,
                ),
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
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completed = module.progressPercentage == 100;
    final started = module.progressPercentage > 0;
    final secondaryText = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final primaryText = isDark ? AppTheme.textPrimaryDark : AppTheme.primary900;
    final trackColor = isDark ? AppTheme.borderDark : AppTheme.primary50;
    final progressColor = isDark ? AppTheme.primary500 : AppTheme.primary700;

    return Semantics(
      key: ValueKey<int>(module.id),
      label: 'Modul ${module.moduleNumber}: ${module.title}',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final bannerHeight = (cardWidth / 2.2).clamp(136.0, 220.0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: ModuleBanner(
                  moduleId: module.id,
                  bannerImage: module.bannerImage,
                  moduleNumber: module.moduleNumber,
                  title: module.title,
                  width: cardWidth,
                  height: bannerHeight,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  useModuleFallback: true,
                  borderRadius: BorderRadius.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${module.completedTopics} dari ${module.totalTopics} submateri selesai',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${module.progressPercentage}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (module.progressPercentage / 100).clamp(0, 1),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      backgroundColor: trackColor,
                      color: progressColor,
                      semanticsLabel: 'Progres belajar ${module.title}',
                    ),
                    const SizedBox(height: 12),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Figma SVG exports wrap high-resolution PNG/JPEG bitmaps inside <image xlink:href>.
class _ServiceIconBundle extends CachingAssetBundle {
  static final instance = _ServiceIconBundle();
  static final Map<String, Uint8List> _decodedCache = {};

  @override
  Future<ByteData> load(String key) async {
    final cached = _decodedCache[key];
    if (cached != null) return ByteData.sublistView(cached);
    final raw = await rootBundle.load(key);
    final svg = latin1.decode(
      raw.buffer.asUint8List(raw.offsetInBytes, raw.lengthInBytes),
    );
    final source = RegExp(
      r'data:image/(?:png|jpeg|jpg|webp);base64,([^"]+)',
    ).firstMatch(svg);
    if (source == null) throw FormatException('Gambar ikon tidak tersedia', key);
    final bytes = base64Decode(source.group(1)!);
    _decodedCache[key] = bytes;
    return ByteData.sublistView(bytes);
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
