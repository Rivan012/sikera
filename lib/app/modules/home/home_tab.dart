import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/dashboard_model.dart';
import '../../routes/app_pages.dart';
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
        final modules =
            controller.dashboardData.value?.modules ?? <DashboardModuleModel>[];
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
                            const Expanded(
                              child: Text(
                                'SIKERA',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Buka profil',
                              onPressed: () => _openTab(3, Routes.HOME),
                              icon: const Icon(Icons.person_outline_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Halo, ${firstName == null || firstName.isEmpty ? 'Mahasiswa' : firstName}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belajar dan pahami kesehatan reproduksimu.',
                          style: TextStyle(
                            color: _secondary(context),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (controller.searchQuery.value.isEmpty) ...[
                          _LearningModules(
                            modules: modules,
                            onOpen: _openModule,
                          ),
                          const SizedBox(height: 28),
                        ],
                        _buildSearchBar(context),
                        const SizedBox(height: 24),
                        if (controller.searchQuery.value.isNotEmpty)
                          _buildSearchResults(context, modules)
                        else
                          _buildServices(context),
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

  Widget _buildSearchBar(BuildContext context) => TextField(
    controller: controller.searchController,
    onChanged: (value) => controller.searchQuery.value = value.trim(),
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Cari modul edukasi',
      prefixIcon: const Icon(Icons.search_rounded),
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

  Widget _buildServices(BuildContext context) {
    final services =
        <
          ({
            String title,
            String description,
            IconData icon,
            VoidCallback action,
          })
        >[
          (
            title: 'Edukasi',
            description: 'Materi kesehatan reproduksi',
            icon: Icons.menu_book_outlined,
            action: () => _openTab(1, Routes.EDUCATION_MODULE_LIST),
          ),
          (
            title: 'Konseling',
            description: 'Diskusi dan pertanyaan',
            icon: Icons.chat_bubble_outline_rounded,
            action: () => _openTab(2, Routes.FORUM),
          ),
          if (controller.currentUser.value?.gender != 'L')
            (
              title: 'Catat Haid',
              description: 'Catatan dan prediksi siklus',
              icon: Icons.calendar_month_outlined,
              action: () => Get.toNamed(Routes.SELFCARE_PERIOD),
            ),
          (
            title: 'Kuis Trivia',
            description: 'Uji pemahamanmu',
            icon: Icons.quiz_outlined,
            action: () => Get.toNamed(Routes.TRIVIA),
          ),
          (
            title: 'Siklus & IMT',
            description: 'Catatan kesehatan dan kalkulator IMT',
            icon: Icons.favorite_outline_rounded,
            action: () => Get.toNamed(Routes.SELFCARE),
          ),
        ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Jelajah Layanan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...services.map(
          (service) => _ServiceLink(
            title: service.title,
            subtitle: service.description,
            icon: service.icon,
            onTap: service.action,
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => widget.onOpen(null),
              child: const Text('Semua modul'),
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: selected == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Belum ada modul tersedia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tarik halaman untuk memuat ulang atau buka daftar modul.',
                      style: TextStyle(color: _secondary(context), height: 1.5),
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
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Modul ${selected.moduleNumber}',
                      style: TextStyle(
                        color: _secondary(context),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selected.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${selected.completedTopics} dari ${selected.totalTopics} submateri selesai',
                          style: TextStyle(
                            color: _secondary(context),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${selected.progressPercentage}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (selected.progressPercentage / 100).clamp(0, 1),
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: colors.surface,
                      color: colors.primary,
                      semanticsLabel: 'Progres belajar ${selected.title}',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      key: const ValueKey('learning-banner'),
                      onPressed: () => widget.onOpen(selected),
                      child: Text(
                        selected.progressPercentage == 100
                            ? 'Baca Ulang Materi'
                            : selected.progressPercentage == 0
                            ? 'Mulai Belajar'
                            : 'Lanjutkan Belajar',
                      ),
                    ),
                  ],
                ),
        ),
        if (modules.length > 1) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
                  '${index + 1} dari ${modules.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _secondary(context)),
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
