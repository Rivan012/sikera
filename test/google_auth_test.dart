import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikera/app/core/services/google_auth_service.dart';
import 'package:sikera/app/core/services/storage_service.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/data/models/user_model.dart';
import 'package:sikera/app/modules/auth/login/login_controller.dart';
import 'package:sikera/app/modules/auth/login/login_page.dart';
import 'package:sikera/app/modules/auth/register/register_controller.dart';
import 'package:sikera/app/modules/auth/register/register_page.dart';
import 'package:sikera/app/routes/app_pages.dart';

class _FakeGoogleAdapter implements GoogleSignInAdapter {
  final Future<String?> Function() onAuthenticate;
  int signOutCalls = 0;

  _FakeGoogleAdapter(this.onAuthenticate);

  @override
  Future<String?> authenticate() => onAuthenticate();

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    Get.testMode = true;
    Get.put(LoginController());
    Get.put(RegisterController());
  });

  tearDown(() {
    GoogleAuthService.resetAdapter();
    Get.reset();
  });

  Future<void> mount(
    WidgetTester tester,
    Widget page, {
    bool dark = false,
    double width = 390,
    double height = 844,
    double textScale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
          child: child!,
        ),
        home: page,
        getPages: [
          GetPage(
            name: Routes.HOME,
            page: () => const Scaffold(body: Text('Home destination')),
          ),
          GetPage(
            name: Routes.TERMS_PRIVACY_CONSENT,
            page: () => const Scaffold(body: Text('Consent destination')),
          ),
          GetPage(
            name: Routes.REGISTER,
            page: () => const Scaffold(body: Text('Register destination')),
          ),
          GetPage(
            name: Routes.LOGIN,
            page: () => const Scaffold(body: Text('Login destination')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  group('GoogleAuthService', () {
    test('posts only the ID token to the normal login endpoint', () async {
      GoogleAuthService.adapter = _FakeGoogleAdapter(
        () async => 'valid-id-token-123',
      );

      late Uri capturedUrl;
      late Map<String, dynamic> capturedBody;

      final result = await http.runWithClient(
        GoogleAuthService.signIn,
        () => MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.headers.containsKey('Authorization'), isFalse);
          capturedUrl = request.url;
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Login berhasil!',
              'data': {
                'token': '9|google-sanctum-token',
                'token_type': 'Bearer',
                'user': {
                  'id': 42,
                  'name': 'Aisyah Putri',
                  'email': 'aisyah@unib.ac.id',
                  'avatar': 'https://lh3.googleusercontent.com/avatar.png',
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      expect(capturedUrl.path, '/api/v1/auth/login');
      expect(capturedBody, {'id_token': 'valid-id-token-123'});

      expect(result.success, isTrue);
      expect(result.canceled, isFalse);
      expect(result.token, '9|google-sanctum-token');
      final userModel = UserModel.fromJson(result.user!);
      expect(userModel.id, 42);
      expect(userModel.avatar, 'https://lh3.googleusercontent.com/avatar.png');
    });

    test(
      'returns canceled when user dismisses Google account picker',
      () async {
        GoogleAuthService.adapter = _FakeGoogleAdapter(
          () async => throw const GoogleSignInException(
            code: GoogleSignInExceptionCode.canceled,
            description: 'User canceled',
          ),
        );

        final result = await GoogleAuthService.signIn();
        expect(result.success, isFalse);
        expect(result.canceled, isTrue);
        expect(result.message, isNull);
      },
    );

    test('returns honest message when server endpoint returns 404', () async {
      GoogleAuthService.adapter = _FakeGoogleAdapter(
        () async => 'valid-id-token-123',
      );

      final result = await http.runWithClient(
        GoogleAuthService.signIn,
        () => MockClient(
          (_) async => http.Response(
            '{"message":"Not Found"}',
            404,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      expect(result.success, isFalse);
      expect(result.canceled, isFalse);
      expect(result.message, contains('belum aktif di server SIKERA'));
    });

    test(
      'returns honest message when platform does not support Google Sign-In',
      () async {
        GoogleAuthService.adapter = _FakeGoogleAdapter(
          () async => throw UnsupportedError('Unsupported platform'),
        );

        final result = await GoogleAuthService.signIn();
        expect(result.success, isFalse);
        expect(result.canceled, isFalse);
        expect(result.message, contains('belum didukung'));
      },
    );
  });

  group('Google Auth UI & Mobile Layout', () {
    for (final dark in [false, true]) {
      for (final viewport in [
        (320.0, 568.0, 2.0),
        (390.0, 844.0, 1.0),
        (1280.0, 900.0, 1.0),
      ]) {
        testWidgets(
          'Google button fits Login & Register at ${viewport.$1}px scale=${viewport.$3} dark=$dark',
          (tester) async {
            await mount(
              tester,
              const LoginPage(),
              dark: dark,
              width: viewport.$1,
              height: viewport.$2,
              textScale: viewport.$3,
            );
            expect(tester.takeException(), isNull);
            final loginBtn = find.byKey(const ValueKey('google-login-button'));
            expect(loginBtn, findsOneWidget);
            await tester.ensureVisible(loginBtn);
            await tester.pumpAndSettle();
            final loginRect = tester.getRect(loginBtn);
            expect(loginRect.left, greaterThanOrEqualTo(0));
            expect(loginRect.right, lessThanOrEqualTo(viewport.$1));
            expect(loginRect.height, greaterThanOrEqualTo(44));

            await mount(
              tester,
              const RegisterPage(),
              dark: dark,
              width: viewport.$1,
              height: viewport.$2,
              textScale: viewport.$3,
            );
            expect(tester.takeException(), isNull);
            final registerBtn = find.byKey(
              const ValueKey('google-register-button'),
            );
            expect(registerBtn, findsOneWidget);
            await tester.ensureVisible(registerBtn);
            await tester.pumpAndSettle();
            final registerRect = tester.getRect(registerBtn);
            expect(registerRect.left, greaterThanOrEqualTo(0));
            expect(registerRect.right, lessThanOrEqualTo(viewport.$1));
            expect(registerRect.height, greaterThanOrEqualTo(44));
          },
        );
      }
    }

    testWidgets('LoginPage Google sign-in saves session and navigates', (
      tester,
    ) async {
      GoogleAuthService.adapter = _FakeGoogleAdapter(() async => 'token-abc');

      await mount(tester, const LoginPage());
      final googleBtn = find.byKey(const ValueKey('google-login-button'));
      await tester.ensureVisible(googleBtn);
      await tester.pumpAndSettle();

      await http.runWithClient(
        () async {
          await tester.tap(googleBtn);
          await tester.pumpAndSettle();
        },
        () => MockClient((_) async {
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Login berhasil!',
              'data': {
                'token': '10|token-google',
                'user': {
                  'id': 7,
                  'name': 'Budi Santoso',
                  'email': 'mhs@unib.ac.id',
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      expect(StorageService.getToken(), '10|token-google');
      expect(Get.currentRoute, Routes.TERMS_PRIVACY_CONSENT);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LoginPage Google cancel clears loading without error', (
      tester,
    ) async {
      GoogleAuthService.adapter = _FakeGoogleAdapter(
        () async => throw const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
          description: 'Canceled',
        ),
      );

      await mount(tester, const LoginPage());
      final controller = Get.find<LoginController>();
      final googleBtn = find.byKey(const ValueKey('google-login-button'));
      await tester.ensureVisible(googleBtn);
      await tester.pumpAndSettle();
      await tester.tap(googleBtn);
      await tester.pumpAndSettle();

      expect(controller.isGoogleLoading.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RegisterPage Google 404 shows inline accessible error', (
      tester,
    ) async {
      GoogleAuthService.adapter = _FakeGoogleAdapter(() async => 'token-abc');

      await mount(tester, const RegisterPage());
      final googleBtn = find.byKey(const ValueKey('google-register-button'));
      await tester.ensureVisible(googleBtn);
      await tester.pumpAndSettle();

      await http.runWithClient(
        () async {
          await tester.tap(googleBtn);
          await tester.pumpAndSettle();
        },
        () => MockClient((_) async {
          return http.Response(
            '{"message":"Not Found"}',
            404,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      Get.closeAllSnackbars();
      await tester.pumpAndSettle();

      expect(
        find.textContaining('belum aktif di server SIKERA'),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.textContaining('belum aktif di server SIKERA'),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.liveRegion == true,
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Google loading state disables primary button and shows spinner',
      (tester) async {
        await mount(tester, const LoginPage());
        final controller = Get.find<LoginController>();
        controller.isGoogleLoading.value = true;
        await tester.pump();

        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );
        final spinner = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(spinner.semanticsLabel, isNotEmpty);

        controller.isGoogleLoading.value = false;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
