import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikera/app/core/services/storage_service.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/modules/splash/splash_page.dart';
import 'package:sikera/app/routes/app_pages.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('Splash uses logo colors and retains routing, dark=$dark', (
      tester,
    ) async {
      Get.testMode = true;
      SharedPreferences.setMockInitialValues(
        dark
            ? {
                'auth_token': 'test-token',
                'auth_user_json': '{"id":1}',
                'terms_privacy_accepted_1': true,
              }
            : {'onboarding_completed': true},
      );
      await StorageService.init();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(Get.reset);
      final capture = GlobalKey();
      if (Platform.environment['SIKERA_CAPTURE_SPLASH'] == '1') {
        await (FontLoader('Roboto')..addFont(
              Future.value(
                ByteData.sublistView(
                  File('C:/Windows/Fonts/arial.ttf').readAsBytesSync(),
                ),
              ),
            ))
            .load();
      }
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: RepaintBoundary(key: capture, child: const SplashPage()),
          getPages: [
            GetPage(
              name: Routes.HOME,
              page: () => const Scaffold(body: Text('Home test')),
            ),
            GetPage(
              name: Routes.LOGIN,
              page: () => const Scaffold(body: Text('Login test')),
            ),
          ],
        ),
      );
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/logo/sikera_logo_putih.png'),
          capture.currentContext!,
        ),
      );
      await tester.pump(const Duration(milliseconds: 1300));
      final background =
          tester.widget<Container>(find.byType(Container).first).decoration
              as BoxDecoration;
      expect(
        background.color,
        dark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      );
      final text = tester.widget<Text>(
        find.text('Sistem Informasi\nKesehatan Remaja'),
      );
      expect(
        text.style!.color,
        dark ? AppTheme.textPrimaryDark : AppTheme.primary900,
      );
      final bgLum = background.color!.computeLuminance();
      final fgLum = text.style!.color!.computeLuminance();
      final lighter = bgLum > fgLum ? bgLum : fgLum;
      final darker = bgLum > fgLum ? fgLum : bgLum;
      expect((lighter + .05) / (darker + .05), greaterThan(4.5));
      expect(tester.takeException(), isNull);
      if (Platform.environment['SIKERA_CAPTURE_SPLASH'] == '1') {
        await tester.runAsync(() async {
          final image =
              await (capture.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build').create(recursive: true);
          await File(
            'build/splash-review-${dark ? 'dark' : 'light'}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          if (!dark) {
            await File(
              'build/splash-mint.png',
            ).writeAsBytes(bytes.buffer.asUint8List());
          }
          image.dispose();
        });
      }
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text(dark ? 'Home test' : 'Login test'), findsOneWidget);
    });
  }
}
