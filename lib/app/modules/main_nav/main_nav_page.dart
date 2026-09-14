import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_tab.dart';
import '../education/education_tab.dart';
import '../forum/forum_list_page.dart';
import '../profile/profile_tab.dart';
import 'main_nav_controller.dart';

class MainNavPage extends GetView<MainNavController> {
  const MainNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      const HomeTab(),
      const EducationTab(),
      const ForumListPage(),
      const ProfileTab(),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: tabs,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 1.0,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: controller.currentIndex.value,
              onDestinationSelected: controller.changeTab,
              backgroundColor: Theme.of(context).colorScheme.surface,
              indicatorColor: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
              height: 68,
              elevation: 0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded, color: isDark ? AppTheme.primary500 : AppTheme.primary700),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded, color: isDark ? AppTheme.primary500 : AppTheme.primary700),
                  label: 'Edukasi',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: Icon(Icons.chat_bubble_rounded, color: isDark ? AppTheme.primary500 : AppTheme.primary700),
                  label: 'Konseling',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: isDark ? AppTheme.primary500 : AppTheme.primary700),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ));
  }
}
