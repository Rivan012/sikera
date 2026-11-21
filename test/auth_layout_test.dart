import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/modules/auth/login/login_controller.dart';
import 'package:sikera/app/modules/auth/login/login_page.dart';
import 'package:sikera/app/modules/auth/register/register_controller.dart';
import 'package:sikera/app/modules/auth/register/register_page.dart';
import 'package:sikera/app/routes/app_pages.dart';

class _CountingLoginController extends LoginController {
  int loginCalls = 0;

  @override
  Future<void> login() async {
    loginCalls++;
    isLoading.value = true;
  }
}

class _CountingRegisterController extends RegisterController {
  int registerCalls = 0;

  @override
  Future<void> register() async {
    registerCalls++;
    isLoading.value = true;
  }
}

void main() {
  final captureKey = GlobalKey();
  const registerFields = [
    'register-name',
    'register-initials',
    'register-age',
    'register-nim',
    'register-program',
    'register-faculty',
    'register-email',
    'register-password',
    'register-password-confirm',
  ];
  setUp(() {
    Get.testMode = true;
    Get.put(LoginController());
    Get.put(RegisterController());
  });
  tearDown(Get.reset);

  Future<void> mount(
    WidgetTester tester,
    Widget page,
    bool dark, {
    double width = 320,
    double height = 568,
    double textScale = 2,
    double keyboardInset = 0,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    tester.view.viewInsets = FakeViewPadding(bottom: keyboardInset);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        defaultTransition: Transition.noTransition,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: RepaintBoundary(key: captureKey, child: child!),
        ),
        home: page,
        getPages: [
          GetPage(
            name: Routes.LOGIN,
            page: () => const Scaffold(body: Text('Login destination')),
          ),
          GetPage(
            name: Routes.REGISTER,
            page: () => const Scaffold(body: Text('Registration destination')),
          ),
          GetPage(
            name: Routes.TERMS_OF_SERVICE,
            page: () => const Scaffold(body: Text('Terms destination')),
          ),
          GetPage(
            name: Routes.PRIVACY_POLICY,
            page: () => const Scaffold(body: Text('Privacy destination')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('Password keyboard Done submits once while login is pending', (
    tester,
  ) async {
    await Get.delete<LoginController>();
    final controller = _CountingLoginController();
    Get.put<LoginController>(controller);
    await mount(
      tester,
      const LoginPage(),
      false,
      width: 390,
      height: 844,
      textScale: 1,
    );
    final email = find.byKey(const ValueKey('login-email'));
    final password = find.byKey(const ValueKey('login-password'));
    for (final field in [(email, 'Email'), (password, 'Kata sandi')]) {
      expect(
        find.ancestor(
          of: field.$1,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.label == field.$2,
          ),
        ),
        findsOneWidget,
      );
    }
    await tapVisible(tester, password);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(controller.loginCalls, 1);
    tester.widget<TextField>(password).onSubmitted!('');
    expect(controller.loginCalls, 1);
    await tester.pump();
    expect(tester.widget<TextField>(password).readOnly, isTrue);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
    controller.isLoading.value = false;
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Confirmation keyboard Done submits once while registration is pending',
    (tester) async {
      await Get.delete<RegisterController>();
      final controller = _CountingRegisterController();
      Get.put<RegisterController>(controller);
      await mount(
        tester,
        const RegisterPage(),
        false,
        width: 390,
        height: 844,
        textScale: 1,
      );
      final confirm = find.byKey(const ValueKey('register-password-confirm'));
      await tapVisible(tester, confirm);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(controller.registerCalls, 1);
      tester.widget<TextField>(confirm).onSubmitted!('');
      expect(controller.registerCalls, 1);
      await tester.pump();
      final field = tester.widget<TextField>(confirm);
      expect(field.readOnly || field.enabled == false, isTrue);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
      controller.isLoading.value = false;
      await tester.pumpAndSettle();
    },
  );

  for (final dark in [false, true]) {
    for (final layout in [(390.0, 844.0), (1280.0, 900.0)]) {
      testWidgets('Login fits ${layout.$1}px, dark=$dark', (tester) async {
        await mount(
          tester,
          const LoginPage(),
          dark,
          width: layout.$1,
          height: layout.$2,
          textScale: 1,
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(TextField), findsNWidgets(2));
        final login = Get.find<LoginController>();
        expect(login.emailController.text, isEmpty);
        expect(login.passwordController.text, isEmpty);
        await tapVisible(tester, find.byTooltip('Tampilkan kata sandi'));
        expect(login.isPasswordHidden.value, isFalse);
        final submit = find.byType(ElevatedButton);
        await tester.ensureVisible(submit);
        await tester.pumpAndSettle();
        final bounds = tester.getRect(submit);
        expect(bounds.left, greaterThanOrEqualTo(0));
        expect(bounds.right, lessThanOrEqualTo(layout.$1));
        expect(bounds.height, greaterThanOrEqualTo(44));
        await tapVisible(tester, find.text('Daftar Mahasiswa'));
        expect(Get.currentRoute, Routes.REGISTER);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Registration fits ${layout.$1}px, dark=$dark', (
        tester,
      ) async {
        await mount(
          tester,
          const RegisterPage(),
          dark,
          width: layout.$1,
          height: layout.$2,
          textScale: 1,
        );
        expect(tester.takeException(), isNull);
        for (final key in registerFields) {
          final field = find.byKey(ValueKey(key));
          expect(field, findsOneWidget);
          final bounds = tester.getRect(field);
          expect(bounds.left, greaterThanOrEqualTo(0));
          expect(bounds.right, lessThanOrEqualTo(layout.$1));
        }
        final submit = find.widgetWithText(
          ElevatedButton,
          'Daftar Akun Sekarang',
        );
        await tester.ensureVisible(submit);
        await tester.pumpAndSettle();
        expect(tester.getSize(submit).height, greaterThanOrEqualTo(44));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Login remains reachable above keyboard, dark=$dark', (
      tester,
    ) async {
      await mount(
        tester,
        const LoginPage(),
        dark,
        width: 390,
        height: 844,
        textScale: 1,
        keyboardInset: 320,
      );
      final password = find.byKey(const ValueKey('login-password'));
      await tapVisible(tester, password);
      final submit = find.byType(ElevatedButton);
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      final bounds = tester.getRect(submit);
      expect(bounds.top, greaterThanOrEqualTo(0));
      expect(bounds.bottom, lessThanOrEqualTo(844 - 320));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Login error stays inline and clears when editing, dark=$dark',
      (tester) async {
        const message = 'Email atau kata sandi tidak cocok. Coba lagi.';
        final controller = Get.find<LoginController>();
        controller.errorMessage.value = message;
        await mount(tester, const LoginPage(), dark);
        expect(find.text(message), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(message),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics && widget.properties.liveRegion == true,
            ),
          ),
          findsOneWidget,
        );
        final email = find.byKey(const ValueKey('login-email'));
        await tester.ensureVisible(email);
        await tester.pumpAndSettle();
        await tester.enterText(email, 'mahasiswa@example.test');
        await tester.pumpAndSettle();
        expect(controller.errorMessage.value, isEmpty);
        expect(find.text(message), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Auth loading states remain legible, dark=$dark', (
      tester,
    ) async {
      final login = Get.find<LoginController>();
      final register = Get.find<RegisterController>();
      for (final page in [const LoginPage(), const RegisterPage()]) {
        await mount(tester, page, dark);
        login.isLoading.value = page is LoginPage;
        register.isLoading.value = page is RegisterPage;
        await tester.pump();
        final spinner = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(spinner.semanticsLabel, isNotEmpty);
        expect(
          spinner.color,
          Theme.of(
            tester.element(find.byType(CircularProgressIndicator)),
          ).colorScheme.onSurface,
        );
        expect(tester.takeException(), isNull);
        login.isLoading.value = false;
        register.isLoading.value = false;
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Login fits 320px at 200% text, dark=$dark', (tester) async {
      await mount(tester, const LoginPage(), dark);
      expect(tester.takeException(), isNull);
      await tapVisible(tester, find.byTooltip('Tampilkan kata sandi'));
      expect(Get.find<LoginController>().isPasswordHidden.value, isFalse);
      expect(find.byTooltip('Sembunyikan kata sandi'), findsOneWidget);
      await tapVisible(tester, find.text('Daftar Mahasiswa'));
      expect(Get.currentRoute, Routes.REGISTER);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Registration form fits 320px at 200% text, dark=$dark', (
      tester,
    ) async {
      final controller = Get.find<RegisterController>();
      controller.selectedAgama.value = 'Kristen Protestan';
      await mount(tester, const RegisterPage(), dark);
      expect(tester.takeException(), isNull);
      await tapVisible(tester, find.text('Laki-laki'));
      expect(controller.selectedGender.value, 'L');
      await tapVisible(tester, find.byTooltip('Tampilkan kata sandi'));
      expect(controller.isPasswordHidden.value, isFalse);
      expect(find.byTooltip('Sembunyikan kata sandi'), findsOneWidget);
      final submit = find.widgetWithText(
        ElevatedButton,
        'Daftar Akun Sekarang',
      );
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      expect(tester.getSize(submit).height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Registration shows a server error next to its field until edited',
    (tester) async {
      await mount(tester, const RegisterPage(), true);
      final controller = Get.find<RegisterController>();
      controller.nameController.text = 'Mahasiswa Uji';
      controller.emailController.text = 'test@example.com';
      controller.prodiController.text = 'Teknik';
      controller.usiaController.text = '40';
      controller.passwordController.text = 'password123';
      controller.passwordConfirmController.text = 'password123';

      await http.runWithClient(
        controller.register,
        () => MockClient(
          (_) async => http.Response(
            '{"errors":{"email":["Alamat email sudah digunakan."]}}',
            422,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      await tester.pumpAndSettle();
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();
      final email = find.byKey(const ValueKey('register-email'));
      expect(
        tester.widget<TextField>(email).decoration?.errorText,
        'Alamat email sudah digunakan.',
      );
      await tester.ensureVisible(email);
      await tester.enterText(email, 'other@example.com');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(email).decoration?.errorText, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Login interactive controls: validation and legal links', (
    tester,
  ) async {
    await mount(
      tester,
      const LoginPage(),
      false,
      width: 390,
      height: 844,
      textScale: 1,
    );
    final controller = Get.find<LoginController>();

    // Empty submit shows inline validation message
    await tapVisible(tester, find.byType(ElevatedButton));
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    expect(controller.errorMessage.value, contains('wajib diisi'));
    expect(find.textContaining('wajib diisi'), findsOneWidget);

    // Invalid email format shows inline format message
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'tanpa-at',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'rahasia123',
    );
    await tapVisible(tester, find.byType(ElevatedButton));
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    expect(controller.errorMessage.value, contains('Email belum valid'));

    // Legal links navigate cleanly
    await tapVisible(tester, find.text('Syarat & Ketentuan'));
    expect(Get.currentRoute, Routes.TERMS_OF_SERVICE);
    Get.back();
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Kebijakan Privasi'));
    expect(Get.currentRoute, Routes.PRIVACY_POLICY);
    Get.back();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Register interactive controls: dropdowns, validation, legal links, and back to login',
    (tester) async {
      await mount(
        tester,
        const RegisterPage(),
        false,
        width: 390,
        height: 844,
        textScale: 1,
      );
      final controller = Get.find<RegisterController>();

      // Pendidikan Terakhir dropdown updates state
      await tapVisible(tester, find.text('SMA/SMK/MA/Sederajat'));
      await tester.tap(find.text('Sarjana (S1)').last);
      await tester.pumpAndSettle();
      expect(controller.selectedPendidikan.value, 'Sarjana (S1)');

      // Empty submit shows inline error banner
      await tapVisible(
        tester,
        find.widgetWithText(ElevatedButton, 'Daftar Akun Sekarang'),
      );
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();
      expect(controller.errorMessage.value, contains('wajib diisi'));

      // Legal links navigate cleanly
      await tapVisible(tester, find.text('Syarat & Ketentuan'));
      expect(Get.currentRoute, Routes.TERMS_OF_SERVICE);
      Get.back();
      await tester.pumpAndSettle();

      // Secondary action returns to Login
      await tapVisible(tester, find.text('Masuk ke Akun'));
      expect(Get.currentRoute, Routes.LOGIN);
      expect(tester.takeException(), isNull);
    },
  );

  if (Platform.environment['SIKERA_CAPTURE_LOGIN'] == '1') {
    testWidgets('Capture login and register pages for visual review', (
      tester,
    ) async {
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      final font = File('C:/Windows/Fonts/arial.ttf');
      if (font.existsSync()) {
        await (FontLoader('Roboto')..addFont(
              Future.value(ByteData.sublistView(font.readAsBytesSync())),
            ))
            .load();
      }
      for (final dark in [false, true]) {
        for (final layout in [
          ('mobile', 390.0, 844.0),
          ('desktop', 1280.0, 900.0),
        ]) {
          await mount(
            tester,
            const LoginPage(),
            dark,
            width: layout.$2,
            height: layout.$3,
            textScale: 1,
          );
          final controller = Get.find<LoginController>();
          expect(controller.emailController.text, isEmpty);
          expect(controller.passwordController.text, isEmpty);
          await tester.runAsync(
            () => precacheImage(
              const AssetImage('assets/logo/sikera_logo_putih.png'),
              captureKey.currentContext!,
            ),
          );
          await tester.pumpAndSettle();
          final boundary =
              captureKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              'build/login-review-${dark ? 'dark' : 'light'}-${layout.$1}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
          expect(tester.takeException(), isNull);

          await mount(
            tester,
            const RegisterPage(),
            dark,
            width: layout.$2,
            height: layout.$3,
            textScale: 1,
          );
          await tester.pumpAndSettle();
          final regBoundary =
              captureKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await regBoundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              'build/register-review-${dark ? 'dark' : 'light'}-${layout.$1}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
          expect(tester.takeException(), isNull);
        }
      }
    });
  }
}
