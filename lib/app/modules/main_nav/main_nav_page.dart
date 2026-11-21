import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_tab.dart';
import '../education/education_tab.dart';
import '../profile/profile_tab.dart';
import 'main_nav_controller.dart';

class MainNavPage extends GetView<MainNavController> {
  const MainNavPage({super.key});

  Widget _navSvgIcon(
    String assetPath, {
    required bool isDark,
    required bool selected,
  }) {
    final stroke = selected
        ? (isDark ? AppTheme.primary900 : Colors.white)
        : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight);
    final fill = selected
        ? (isDark
              ? AppTheme.primary900.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.22))
        : (isDark ? AppTheme.elevatedSurfaceDark : const Color(0xFFEAF7FC));

    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorMapper: _NavIconColorMapper(stroke: stroke, fill: fill),
      excludeFromSemantics: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      const HomeTab(),
      const EducationTab(),
      const ProfileTab(),
    ];

    return Obx(() {
      final activeIndex = controller.currentIndex.value.clamp(
        0,
        tabs.length - 1,
      );
      return Scaffold(
        body: IndexedStack(index: activeIndex, children: tabs),
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
            selectedIndex: activeIndex,
            onDestinationSelected: controller.changeTab,
            backgroundColor: Theme.of(context).colorScheme.surface,
            indicatorColor: isDark ? AppTheme.primary500 : AppTheme.primary700,
            indicatorShape: const StadiumBorder(),
            height: 68,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: isDark
                      ? AppTheme.textMutedDark
                      : AppTheme.textMutedLight,
                ),
                selectedIcon: Icon(
                  Icons.home_rounded,
                  color: isDark ? AppTheme.primary900 : Colors.white,
                ),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: _navSvgIcon(
                  'assets/icon/btn-edukasi.svg',
                  isDark: isDark,
                  selected: false,
                ),
                selectedIcon: _navSvgIcon(
                  'assets/icon/btn-edukasi.svg',
                  isDark: isDark,
                  selected: true,
                ),
                label: 'Edukasi',
              ),
              NavigationDestination(
                icon: _navSvgIcon(
                  'assets/icon/btn-profile.svg',
                  isDark: isDark,
                  selected: false,
                ),
                selectedIcon: _navSvgIcon(
                  'assets/icon/btn-profile.svg',
                  isDark: isDark,
                  selected: true,
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _NavIconColorMapper extends ColorMapper {
  const _NavIconColorMapper({required this.stroke, required this.fill});

  final Color stroke;
  final Color fill;

  static const _sourceStroke = Color(0xFF75618F);
  static const _sourceFill = Color(0xFFF0EAFB);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == _sourceFill) return fill;
    if (color == _sourceStroke) return stroke;
    return color;
  }
}
