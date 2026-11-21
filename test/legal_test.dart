import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikera/app/core/services/storage_service.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/modules/auth/login/login_controller.dart';
import 'package:sikera/app/modules/auth/register/register_controller.dart';
import 'package:sikera/app/modules/legal/legal_guard.dart';
import 'package:sikera/app/modules/legal/widgets/consent_checkbox.dart';
import 'package:sikera/app/routes/app_pages.dart';

void main() {
  final capture = GlobalKey();
  final captureEnabled = Platform.environment['SIKERA_CAPTURE_LEGAL'] == '1';
  ThemeData previewTheme(ThemeData theme) => !captureEnabled
      ? theme
      : theme.copyWith(
          appBarTheme: theme.appBarTheme.copyWith(
            titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
              fontFamily: 'Roboto',
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: theme.outlinedButtonTheme.style?.copyWith(
              textStyle: WidgetStatePropertyAll(
                theme.outlinedButtonTheme.style?.textStyle
                    ?.resolve({})
                    ?.copyWith(fontFamily: 'Roboto'),
              ),
            ),
          ),
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
    SharedPreferences.setMockInitialValues({
      'auth_token': 'test-token',
      'auth_user_json': '{"id":1}',
    });
    await StorageService.init();
  });
  tearDown(Get.reset);

  Future<void> mount(
    WidgetTester tester, {
    String route = Routes.TERMS_PRIVACY_CONSENT,
    bool dark = false,
    double scale = 1,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
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
            (page) => [
              Routes.TERMS_OF_SERVICE,
              Routes.PRIVACY_POLICY,
              Routes.TERMS_PRIVACY_CONSENT,
              Routes.SPLASH,
            ].contains(page.name),
          ),
          GetPage(
            name: Routes.LOGIN,
            page: () => const Scaffold(body: Text('Login test')),
          ),
          GetPage(
            name: Routes.HOME,
            page: () => const Scaffold(body: Text('Home test')),
            middlewares: [LegalGuard()],
          ),
        ],
      ),
    );
    if (route == Routes.SPLASH) await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Checkbox gates saving; links return to the same selection; accepted account enters Home',
    (tester) async {
      await mount(tester);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tap(tester, find.byType(ConsentCheckbox));
      await tap(
        tester,
        find.widgetWithText(OutlinedButton, 'Syarat & Ketentuan'),
      );
      expect(Get.currentRoute, Routes.TERMS_OF_SERVICE);
      Get.back();
      await tester.pumpAndSettle();
      expect(
        tester.widget<ConsentCheckbox>(find.byType(ConsentCheckbox)).value,
        true,
      );
      await tap(
        tester,
        find.widgetWithText(OutlinedButton, 'Kebijakan Privasi'),
      );
      expect(Get.currentRoute, Routes.PRIVACY_POLICY);
      Get.back();
      await tester.pumpAndSettle();
      await tap(tester, find.text('Lanjutkan'));
      expect(StorageService.termsPrivacyAccepted, true);
      expect(find.text('Home test'), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.text('Home test'))).canPop(),
        false,
      );
    },
  );

  testWidgets(
    'Unaccepted session resumes at consent and cannot open Home directly',
    (tester) async {
      await mount(tester, route: Routes.SPLASH);
      expect(Get.currentRoute, Routes.TERMS_PRIVACY_CONSENT);
      Get.offAllNamed(Routes.HOME);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, Routes.TERMS_PRIVACY_CONSENT);
      expect(StorageService.termsPrivacyAccepted, false);
    },
  );

  testWidgets('Accepted session resumes at Home', (tester) async {
    await StorageService.acceptTermsPrivacy();
    await StorageService.init();
    await mount(tester, route: Routes.SPLASH);
    expect(Get.currentRoute, Routes.HOME);
  });

  testWidgets('Leaving does not record consent and clears the session', (
    tester,
  ) async {
    await mount(tester);
    await tap(tester, find.text('Keluar'));
    expect(StorageService.hasToken, false);
    expect(StorageService.termsPrivacyAccepted, false);
    expect(Get.currentRoute, Routes.LOGIN);
  });

  test('Consent is isolated per account and survives logout', () async {
    await StorageService.acceptTermsPrivacy();
    await StorageService.clearAuth();
    expect(StorageService.termsPrivacyAccepted, false);
    await StorageService.setToken('second-token');
    await StorageService.setUserJson('{"id":2}');
    expect(StorageService.termsPrivacyAccepted, false);
    await StorageService.setUserJson('{"id":1}');
    expect(StorageService.termsPrivacyAccepted, true);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        'terms_privacy_accepted_1',
      ),
      true,
    );
  });

  testWidgets('Missing account identity shows an error, never enters Home', (
    tester,
  ) async {
    await StorageService.setUserJson('{}');
    await mount(tester);
    await tap(tester, find.byType(ConsentCheckbox));
    await tap(tester, find.text('Lanjutkan'));
    expect(Get.currentRoute, Routes.TERMS_PRIVACY_CONSENT);
    expect(
      find.text('Informasi akun tidak tersedia. Keluar lalu masuk kembali.'),
      findsOneWidget,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('Successful registration must pass through consent before Home', (
    tester,
  ) async {
    await StorageService.clearAuth();
    await mount(tester, route: Routes.LOGIN);
    final controller = RegisterController();
    addTearDown(controller.onClose);
    controller.nameController.text = 'Test user';
    controller.prodiController.text = 'Sistem Informasi';
    controller.emailController.text = 'test@example.com';
    controller.passwordController.text = 'test-password';
    controller.passwordConfirmController.text = 'test-password';
    for (final age in ['14', '41']) {
      controller.usiaController.text = age;
      await controller.register();
      expect(controller.errorMessage.value, contains('15 dan 40'));
    }
    controller.usiaController.text = '15';
    await http.runWithClient(
      () async {
        await controller.register();
      },
      () => MockClient((request) async {
        expect(request.url.path.endsWith('/auth/register'), true);
        expect(request.headers.containsKey('authorization'), false);
        final body = jsonDecode(request.body) as Map;
        expect(body['usia'], 15);
        for (final field in ['nim', 'fakultas', 'initials']) {
          expect(body.containsKey(field), isFalse);
        }
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'token': 'new-token',
              'user': {'id': 7, 'name': 'Test user'},
            },
          }),
          201,
        );
      }),
    );
    await tester.pumpAndSettle();
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.TERMS_PRIVACY_CONSENT);
    expect(StorageService.termsPrivacyAccepted, false);
    await tap(tester, find.byType(ConsentCheckbox));
    await tap(tester, find.text('Lanjutkan'));
    expect(Get.currentRoute, Routes.HOME);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        'terms_privacy_accepted_7',
      ),
      true,
    );
  });

  for (final accepted in [false, true]) {
    testWidgets('Login routes according to persisted consent: $accepted', (
      tester,
    ) async {
      if (accepted) await StorageService.acceptTermsPrivacy();
      await StorageService.clearAuth();
      await mount(tester, route: Routes.LOGIN);
      final controller = LoginController();
      addTearDown(controller.onClose);
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'test-password';
      await http.runWithClient(
        () async {
          await controller.login();
        },
        () => MockClient(
          (_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'token': 'login-token',
                'user': {'id': 1},
              },
            }),
            200,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        Get.currentRoute,
        accepted ? Routes.HOME : Routes.TERMS_PRIVACY_CONSENT,
      );
    });
  }

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Legal pages fit 320px, text $scale, dark=$dark', (
        tester,
      ) async {
        await mount(
          tester,
          dark: dark,
          scale: scale,
          size: const Size(320, 568),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Lanjutkan').hitTestable(), findsOneWidget);
        for (final label in ['Syarat & Ketentuan', 'Kebijakan Privasi']) {
          await tap(tester, find.widgetWithText(OutlinedButton, label));
          await tester.ensureVisible(find.text('rivan@rivan.my.id'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          Get.back();
          await tester.pumpAndSettle();
        }
      });
    }
  }

  testWidgets(
    'Legal documents are readable without a session; consent requires login',
    (tester) async {
      await StorageService.clearAuth();
      await mount(tester, route: Routes.PRIVACY_POLICY);
      expect(Get.currentRoute, Routes.PRIVACY_POLICY);
      Get.offAllNamed(Routes.TERMS_PRIVACY_CONSENT);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, Routes.LOGIN);
    },
  );

  if (captureEnabled) {
    testWidgets('Capture legal previews', (tester) async {
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
        for (final route in [
          Routes.TERMS_PRIVACY_CONSENT,
          Routes.PRIVACY_POLICY,
        ]) {
          if (Get.currentRoute != route) {
            Get.offAllNamed(route);
            await tester.pumpAndSettle();
          }
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
              'build/legal-${dark ? 'dark' : 'light'}${route.replaceAll('/', '-')}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    });
  }
}
