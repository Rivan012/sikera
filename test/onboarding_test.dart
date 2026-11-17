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
import 'package:sikera/app/modules/onboarding/onboarding_controller.dart';
import 'package:sikera/app/modules/onboarding/widgets/page_indicator.dart';
import 'package:sikera/app/routes/app_pages.dart';

void main() {
  final capture = GlobalKey();
  final captureEnabled =
      Platform.environment['SIKERA_CAPTURE_ONBOARDING'] == '1';

  ThemeData previewTheme(ThemeData theme) => !captureEnabled
      ? theme
      : theme.copyWith(
          textButtonTheme: TextButtonThemeData(
            style: theme.textButtonTheme.style?.copyWith(
              textStyle: WidgetStatePropertyAll(
                theme.textButtonTheme.style?.textStyle
                    ?.resolve({})
                    ?.copyWith(fontFamily: 'Roboto'),
              ),
            ),
          ),
        );
  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });
  tearDown(Get.reset);

  Future<void> mount(
    WidgetTester tester, {
    String route = Routes.ONBOARDING,
    Size size = const Size(390, 844),
    bool dark = false,
    double scale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: previewTheme(AppTheme.lightTheme),
        darkTheme: previewTheme(AppTheme.darkTheme),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: route,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: RepaintBoundary(key: capture, child: child!),
        ),
        getPages: [
          ...AppPages.routes.where(
            (page) => [Routes.ONBOARDING, Routes.SPLASH].contains(page.name),
          ),
          GetPage(
            name: Routes.LOGIN,
            page: () => const Scaffold(body: Text('Login test')),
          ),
          GetPage(
            name: Routes.HOME,
            page: () => const Scaffold(body: Text('Home test')),
          ),
        ],
      ),
    );
    if (route == Routes.SPLASH) await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('First launch enters onboarding without completing it', (
    tester,
  ) async {
    await mount(tester, route: Routes.SPLASH);
    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(StorageService.onboardingCompleted, false);
  });

  testWidgets('Returning guest skips onboarding', (tester) async {
    await StorageService.completeOnboarding();
    await StorageService.init();
    await mount(tester, route: Routes.SPLASH);
    expect(find.text('Login test'), findsOneWidget);
  });

  testWidgets('Existing authenticated session still goes Home', (tester) async {
    await StorageService.setToken('test-token');
    await StorageService.setUserJson('{"id":1}');
    await StorageService.acceptTermsPrivacy();
    await mount(tester, route: Routes.SPLASH);
    expect(find.text('Home test'), findsOneWidget);
  });

  for (final skipPage in [0, 1]) {
    testWidgets(
      'Skip on page ${skipPage + 1} persists completion and clears back stack',
      (tester) async {
        await mount(tester);
        if (skipPage == 1) await tap(tester, 'Selanjutnya');
        await tap(tester, 'Lewati');
        expect(StorageService.onboardingCompleted, true);
        expect(
          (await SharedPreferences.getInstance()).getBool(
            'onboarding_completed',
          ),
          true,
        );
        expect(find.text('Login test'), findsOneWidget);
        expect(
          Navigator.of(tester.element(find.text('Login test'))).canPop(),
          false,
        );
      },
    );
  }

  testWidgets('Next, swipe back, dots and finish follow all three pages', (
    tester,
  ) async {
    await mount(tester);
    expect(
      tester.widget<PageIndicator>(find.byType(PageIndicator)).activeIndex,
      0,
    );
    await tap(tester, 'Selanjutnya');
    expect(find.text('Edukasi & Pemantauan Mandiri'), findsOneWidget);
    expect(
      tester.widget<PageIndicator>(find.byType(PageIndicator)).activeIndex,
      1,
    );
    await tester.drag(find.byType(PageView), const Offset(350, 0));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PageIndicator>(find.byType(PageIndicator)).activeIndex,
      0,
    );
    await tap(tester, 'Selanjutnya');
    await tap(tester, 'Selanjutnya');
    expect(find.text('Siap Untuk Memulai?'), findsOneWidget);
    expect(find.text('Lewati').hitTestable(), findsNothing);
    expect(
      tester.widget<PageIndicator>(find.byType(PageIndicator)).activeIndex,
      2,
    );
    expect(StorageService.onboardingCompleted, false);
    await tap(tester, 'Masuk ke Aplikasi');
    expect(StorageService.onboardingCompleted, true);
    expect(find.text('Login test'), findsOneWidget);
    expect(Get.isRegistered<OnboardingController>(), false);
  });

  test('Reset removes only onboarding status; logout preserves it', () async {
    await StorageService.setToken('test-token');
    await StorageService.setThemeMode('dark');
    await StorageService.completeOnboarding();
    await StorageService.resetOnboarding();
    expect(StorageService.onboardingCompleted, false);
    expect(StorageService.getToken(), 'test-token');
    expect(StorageService.getThemeMode(), 'dark');
    await StorageService.completeOnboarding();
    await StorageService.clearAuth();
    expect(StorageService.onboardingCompleted, true);
  });

  test('Development reset flag is applied during initialization', () async {
    await StorageService.completeOnboarding();
    await StorageService.init();
    expect(
      StorageService.onboardingCompleted,
      !const bool.fromEnvironment('RESET_ONBOARDING'),
    );
  });

  testWidgets(
    'Rapid next taps advance once; errors remain readable and saving disables actions',
    (tester) async {
      await mount(tester, size: const Size(320, 568), scale: 2);
      await tester.tap(find.text('Selanjutnya'));
      await tester.tap(find.text('Selanjutnya'));
      await tester.pumpAndSettle();
      final controller = Get.find<OnboardingController>();
      expect(controller.currentPage.value, 1);
      controller.errorMessage.value =
          'Status belum tersimpan. Periksa ruang penyimpanan, lalu coba lagi.';
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      controller.isSaving.value = true;
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNull,
      );
    },
  );

  if (captureEnabled) {
    testWidgets('Capture onboarding previews', (tester) async {
      await (FontLoader('Roboto')..addFont(
            Future.value(
              ByteData.sublistView(
                File('C:/Windows/Fonts/arial.ttf').readAsBytesSync(),
              ),
            ),
          ))
          .load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      for (final dark in [false, true]) {
        await mount(tester, dark: dark);
        await tester.runAsync(
          () => precacheImage(
            const ResizeImage(
              AssetImage('assets/logo/sikera_logo_putih.png'),
              width: 800,
            ),
            capture.currentContext!,
          ),
        );
        Get.find<OnboardingController>().pageController.jumpToPage(0);
        await tester.pumpAndSettle();
        for (var i = 0; i < 3; i++) {
          await tester.runAsync(() async {
            final image =
                await (capture.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory('build').create(recursive: true);
            await File(
              'build/onboarding-${dark ? 'dark' : 'light'}-${i + 1}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
          if (i < 2) await tap(tester, 'Selanjutnya');
        }
      }
    });
  }

  for (final dark in [false, true]) {
    for (final layout in [
      (const Size(320, 568), 1.0),
      (const Size(320, 568), 2.0),
      (const Size(844, 390), 1.0),
      (const Size(800, 1024), 1.0),
    ]) {
      testWidgets('All pages fit ${layout.$1} text=${layout.$2} dark=$dark', (
        tester,
      ) async {
        await mount(tester, size: layout.$1, scale: layout.$2, dark: dark);
        for (var i = 0; i < 3; i++) {
          expect(tester.takeException(), isNull);
          expect(
            tester.widget<PageIndicator>(find.byType(PageIndicator)).count,
            3,
          );
          final button = find.text(
            i == 2 ? 'Masuk ke Aplikasi' : 'Selanjutnya',
          );
          expect(button.hitTestable(), findsOneWidget);
          if (i < 2) await tap(tester, 'Selanjutnya');
        }
      });
    }
  }
}
