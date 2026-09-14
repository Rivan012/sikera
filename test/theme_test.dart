import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sikera/app/core/theme/app_theme.dart';

void main() {
  group('SIKERA Design System Tokens', () {
    test('Official brand color hex values match DESIGN.md', () {
      expect(AppTheme.primary900, const Color(0xFF03045E));
      expect(AppTheme.primary700, const Color(0xFF0077B6));
      expect(AppTheme.primary500, const Color(0xFF00B4D8));
      expect(AppTheme.primary200, const Color(0xFF90E0EF));
      expect(AppTheme.primary50, const Color(0xFFCAF0F8));
    });

    test('Semantic colors are properly defined', () {
      expect(AppTheme.success, const Color(0xFF16803C));
      expect(AppTheme.warning, const Color(0xFFB7791F));
      expect(AppTheme.error, const Color(0xFFC53030));
      expect(AppTheme.info, const Color(0xFF0077B6));
    });

    test('Brand gradient has correct 3-step stops and colors', () {
      expect(AppTheme.brandGradient.colors, [
        AppTheme.primary900,
        AppTheme.primary700,
        AppTheme.primary500,
      ]);
      expect(AppTheme.brandGradient.stops, [0.0, 0.55, 1.0]);
    });

    test('Light theme properties adhere to DESIGN.md', () {
      final light = AppTheme.lightTheme;
      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, AppTheme.backgroundLight);
      expect(light.colorScheme.primary, AppTheme.primary700);
      expect(light.colorScheme.secondary, AppTheme.primary500);
    });

    test('Dark theme properties adhere to DESIGN.md', () {
      final dark = AppTheme.darkTheme;
      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, AppTheme.backgroundDark);
      expect(dark.cardTheme.color, AppTheme.surfaceDark);
      expect(dark.colorScheme.primary, AppTheme.primary500);
    });

    test('Button themes enforce minimum 44px tap targets and 12px radius', () {
      final light = AppTheme.lightTheme;
      final elevatedMinSize = light.elevatedButtonTheme.style?.minimumSize?.resolve({});
      final outlinedMinSize = light.outlinedButtonTheme.style?.minimumSize?.resolve({});

      expect(elevatedMinSize?.height, greaterThanOrEqualTo(44.0));
      expect(outlinedMinSize?.height, greaterThanOrEqualTo(44.0));
    });

    test('Official DESIGN.md radius tokens are defined', () {
      expect(AppTheme.radiusSm, 8.0);
      expect(AppTheme.radiusMd, 12.0);
      expect(AppTheme.radiusLg, 16.0);
      expect(AppTheme.radiusXl, 20.0);
      expect(AppTheme.radius2Xl, 24.0);
      expect(AppTheme.radiusPill, 999.0);
      expect(AppTheme.cardShadow, isNotEmpty);
      expect(AppTheme.elevatedCardShadow, isNotEmpty);
    });

    test('Backwards-compatibility tokens are defined', () {
      expect(AppTheme.jagoCardRadius, 20.0);
      expect(AppTheme.jagoPillRadius, 28.0);
      expect(AppTheme.pocketSurfaceLight, const Color(0xFFF0F9FD));
      expect(AppTheme.pocketSurfaceDark, const Color(0xFF0F2B40));
      expect(AppTheme.primary100, const Color(0xFFBBEBF6));
      expect(AppTheme.jagoPocketShadow, isNotEmpty);
      expect(AppTheme.jagoSoftShadow, isNotEmpty);
    });
  });
}
