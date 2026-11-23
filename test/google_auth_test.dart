import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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

class _FakeBrowserAdapter implements GoogleOAuthBrowserAdapter {
  final Future<String> Function({
    required Uri authorizationUri,
    required String callbackUrlScheme,
    required Uri redirectUri,
  })
  onAuthenticate;

  _FakeBrowserAdapter(this.onAuthenticate);

  @override
  Future<String> authenticate({
    required Uri authorizationUri,
    required String callbackUrlScheme,
    required Uri redirectUri,
  }) {
    return onAuthenticate(
      authorizationUri: authorizationUri,
      callbackUrlScheme: callbackUrlScheme,
      redirectUri: redirectUri,
    );
  }
}

String _buildFakeJwt(Map<String, dynamic> payload) {
  final header = base64UrlEncode(
    utf8.encode(jsonEncode({'alg': 'RS256', 'typ': 'JWT'})),
  ).replaceAll('=', '');
  final body = base64UrlEncode(
    utf8.encode(jsonEncode(payload)),
  ).replaceAll('=', '');
  return '$header.$body.fake-signature';
}

void main() {
  const androidClientId = '1234567890-androidapp.apps.googleusercontent.com';
  const expectedDerivedScheme =
      'com.googleusercontent.apps.1234567890-androidapp';
  const expectedDerivedRedirectUri = '$expectedDerivedScheme:/oauth2redirect';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    dotenv.loadFromString(
      envString: 'GOOGLE_ANDROID_CLIENT_ID=$androidClientId\n',
      isOptional: true,
    );
    Get.testMode = true;
    Get.put(LoginController());
    Get.put(RegisterController());
  });

  tearDown(() {
    GoogleAuthService.resetAdapter();
    dotenv.clean();
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

  group('GoogleAuthService (Direct Google OAuth 2.0 + PKCE)', () {
    test('PkcePair generates RFC 7636 compliant S256 verifier & challenge', () {
      final pair = PkcePair.generate();
      expect(pair.codeVerifier.length, greaterThanOrEqualTo(43));
      expect(pair.codeVerifier.contains('='), isFalse);
      expect(pair.codeChallenge.contains('='), isFalse);

      final recomputed = base64UrlEncode(
        sha256.convert(utf8.encode(pair.codeVerifier)).bytes,
      ).replaceAll('=', '');
      expect(pair.codeChallenge, recomputed);
    });

    test('resolveConfig derives reversed client ID redirect URI from .env', () {
      final config = GoogleAuthService.resolveConfig();
      expect(config, isNotNull);
      expect(config!.clientId, androidClientId);
      expect(config.redirectUri, expectedDerivedRedirectUri);
      expect(config.callbackUrlScheme, expectedDerivedScheme);
    });

    test('resolveConfig honors explicit GOOGLE_ANDROID_REDIRECT_URI', () {
      dotenv.loadFromString(
        envString:
            'GOOGLE_ANDROID_CLIENT_ID=$androidClientId\n'
            'GOOGLE_ANDROID_REDIRECT_URI=com.sikera.app.sikera:/oauth2redirect\n',
        isOptional: true,
      );

      final config = GoogleAuthService.resolveConfig();
      expect(config, isNotNull);
      expect(config!.redirectUri, 'com.sikera.app.sikera:/oauth2redirect');
      expect(config.callbackUrlScheme, 'com.sikera.app.sikera');
    });

    test('resolveConfig uses GOOGLE_IOS_CLIENT_ID on iOS', () {
      const iosClientId = '999888777-iosapp.apps.googleusercontent.com';
      dotenv.loadFromString(
        envString: 'GOOGLE_IOS_CLIENT_ID=$iosClientId\n',
        isOptional: true,
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        final config = GoogleAuthService.resolveConfig();
        expect(config, isNotNull);
        expect(config!.clientId, iosClientId);
        expect(
          config.redirectUri,
          'com.googleusercontent.apps.999888777-iosapp:/oauth2redirect',
        );
        expect(
          config.callbackUrlScheme,
          'com.googleusercontent.apps.999888777-iosapp',
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('returns config error when .env has no Google Client ID', () async {
      dotenv.loadFromString(envString: '', isOptional: true);

      final result = await GoogleAuthService.signIn();
      expect(result.success, isFalse);
      expect(result.canceled, isFalse);
      expect(result.message, contains('.env'));
    });

    test(
      'runs full PKCE flow to Google API then exchanges id_token with SIKERA login',
      () async {
        late Uri capturedAuthUri;
        late String capturedCallbackScheme;
        late Map<String, String> capturedTokenBody;
        late Uri capturedLoginUrl;
        late Map<String, dynamic> capturedLoginBody;
        String? capturedJwt;
        String? revokedToken;

        GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
          required authorizationUri,
          required callbackUrlScheme,
          required redirectUri,
        }) async {
          capturedAuthUri = authorizationUri;
          capturedCallbackScheme = callbackUrlScheme;
          final state = authorizationUri.queryParameters['state']!;
          return '$redirectUri?code=auth-code-xyz&state=$state';
        });

        final result = await http.runWithClient(
          () async {
            final res = await GoogleAuthService.signIn();
            await GoogleAuthService.signOut();
            return res;
          },
          () => MockClient((request) async {
            if (request.url.host == 'oauth2.googleapis.com' &&
                request.url.path == '/token') {
              expect(request.method, 'POST');
              capturedTokenBody = Uri.splitQueryString(request.body);
              final nonce = capturedAuthUri.queryParameters['nonce']!;
              capturedJwt = _buildFakeJwt({
                'aud': androidClientId,
                'nonce': nonce,
                'email': 'aisyah@unib.ac.id',
              });
              return http.Response(
                jsonEncode({
                  'access_token': 'ya29.google-access-token',
                  'expires_in': 3599,
                  'token_type': 'Bearer',
                  'id_token': capturedJwt,
                }),
                200,
                headers: {'content-type': 'application/json'},
              );
            }

            if (request.url.host == 'oauth2.googleapis.com' &&
                request.url.path == '/revoke') {
              revokedToken = Uri.splitQueryString(request.body)['token'];
              return http.Response('', 200);
            }

            expect(request.method, 'POST');
            expect(request.headers.containsKey('Authorization'), isFalse);
            capturedLoginUrl = request.url;
            capturedLoginBody =
                jsonDecode(request.body) as Map<String, dynamic>;
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

        expect(capturedAuthUri.host, 'accounts.google.com');
        expect(capturedAuthUri.path, '/o/oauth2/v2/auth');
        expect(capturedAuthUri.queryParameters['client_id'], androidClientId);
        expect(
          capturedAuthUri.queryParameters['redirect_uri'],
          expectedDerivedRedirectUri,
        );
        expect(capturedAuthUri.queryParameters['response_type'], 'code');
        expect(
          capturedAuthUri.queryParameters['scope'],
          'openid email profile',
        );
        expect(
          capturedAuthUri.queryParameters['code_challenge_method'],
          'S256',
        );
        expect(capturedAuthUri.queryParameters['prompt'], 'select_account');
        expect(capturedCallbackScheme, expectedDerivedScheme);

        expect(capturedTokenBody['client_id'], androidClientId);
        expect(capturedTokenBody['code'], 'auth-code-xyz');
        expect(capturedTokenBody['grant_type'], 'authorization_code');
        expect(capturedTokenBody['redirect_uri'], expectedDerivedRedirectUri);
        expect(capturedTokenBody['code_verifier'], isNotEmpty);
        expect(capturedTokenBody.containsKey('client_secret'), isFalse);

        final recomputedChallenge = base64UrlEncode(
          sha256.convert(utf8.encode(capturedTokenBody['code_verifier']!)).bytes,
        ).replaceAll('=', '');
        expect(
          capturedAuthUri.queryParameters['code_challenge'],
          recomputedChallenge,
        );

        expect(capturedLoginUrl.path, '/api/v1/auth/login');
        expect(capturedLoginBody, {'id_token': capturedJwt});
        expect(revokedToken, 'ya29.google-access-token');

        expect(result.success, isTrue);
        expect(result.canceled, isFalse);
        expect(result.token, '9|google-sanctum-token');
        final userModel = UserModel.fromJson(result.user!);
        expect(userModel.id, 42);
        expect(
          userModel.avatar,
          'https://lh3.googleusercontent.com/avatar.png',
        );
      },
    );

    test('returns canceled when user closes browser auth tab', () async {
      GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
        required authorizationUri,
        required callbackUrlScheme,
        required redirectUri,
      }) async {
        throw PlatformException(code: 'CANCELED', message: 'User canceled');
      });

      final result = await GoogleAuthService.signIn();
      expect(result.success, isFalse);
      expect(result.canceled, isTrue);
      expect(result.message, isNull);
    });

    test('returns canceled when Google redirects with access_denied', () async {
      GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
        required authorizationUri,
        required callbackUrlScheme,
        required redirectUri,
      }) async {
        return '$redirectUri?error=access_denied';
      });

      final result = await GoogleAuthService.signIn();
      expect(result.success, isFalse);
      expect(result.canceled, isTrue);
    });

    test('rejects callback with mismatched state parameter', () async {
      GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
        required authorizationUri,
        required callbackUrlScheme,
        required redirectUri,
      }) async {
        return '$redirectUri?code=auth-code-xyz&state=tampered-state';
      });

      final result = await GoogleAuthService.signIn();
      expect(result.success, isFalse);
      expect(result.canceled, isFalse);
      expect(result.message, contains('state tidak cocok'));
    });

    test('rejects ID token with mismatched nonce claim', () async {
      GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
        required authorizationUri,
        required callbackUrlScheme,
        required redirectUri,
      }) async {
        final state = authorizationUri.queryParameters['state']!;
        return '$redirectUri?code=auth-code-xyz&state=$state';
      });

      final result = await http.runWithClient(
        GoogleAuthService.signIn,
        () => MockClient((request) async {
          expect(request.url.host, 'oauth2.googleapis.com');
          return http.Response(
            jsonEncode({
              'id_token': _buildFakeJwt({'nonce': 'wrong-nonce'}),
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      expect(result.success, isFalse);
      expect(result.message, contains('nonce tidak cocok'));
    });

    test(
      'explains Web Client ID mistake when Google requires client_secret',
      () async {
        GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
          required authorizationUri,
          required callbackUrlScheme,
          required redirectUri,
        }) async {
          final state = authorizationUri.queryParameters['state']!;
          return '$redirectUri?code=auth-code-xyz&state=$state';
        });

        final result = await http.runWithClient(
          GoogleAuthService.signIn,
          () => MockClient((_) async {
            return http.Response(
              jsonEncode({
                'error': 'invalid_request',
                'error_description': 'client_secret is missing.',
              }),
              400,
              headers: {'content-type': 'application/json'},
            );
          }),
        );

        expect(result.success, isFalse);
        expect(result.message, contains('client_secret'));
        expect(result.message, contains('Android/iOS'));
      },
    );

    test('returns honest message when server endpoint returns 404', () async {
      GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
        required authorizationUri,
        required callbackUrlScheme,
        required redirectUri,
      }) async {
        final state = authorizationUri.queryParameters['state']!;
        return '$redirectUri?code=auth-code-xyz&state=$state';
      });

      final result = await http.runWithClient(
        GoogleAuthService.signIn,
        () => MockClient((request) async {
          if (request.url.host == 'oauth2.googleapis.com') {
            return http.Response(
              jsonEncode({'id_token': 'valid-id-token-123'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response(
            '{"message":"Not Found"}',
            404,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      expect(result.success, isFalse);
      expect(result.canceled, isFalse);
      expect(result.message, contains('belum aktif di server SIKERA'));
    });

    test(
      'returns honest message when platform does not support web auth',
      () async {
        GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
          required authorizationUri,
          required callbackUrlScheme,
          required redirectUri,
        }) async {
          throw UnsupportedError('Unsupported platform');
        });

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
      GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
        required authorizationUri,
        required callbackUrlScheme,
        required redirectUri,
      }) async {
        final state = authorizationUri.queryParameters['state']!;
        return '$redirectUri?code=auth-code-123&state=$state';
      });

      await mount(tester, const LoginPage());
      final googleBtn = find.byKey(const ValueKey('google-login-button'));
      await tester.ensureVisible(googleBtn);
      await tester.pumpAndSettle();

      await http.runWithClient(
        () async {
          await tester.tap(googleBtn);
          await tester.pumpAndSettle();
        },
        () => MockClient((request) async {
          if (request.url.host == 'oauth2.googleapis.com') {
            return http.Response(
              jsonEncode({'id_token': 'token-abc'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
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
      GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
        required authorizationUri,
        required callbackUrlScheme,
        required redirectUri,
      }) async {
        throw PlatformException(code: 'CANCELED', message: 'Canceled');
      });

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
      GoogleAuthService.browserAdapter = _FakeBrowserAdapter(({
        required authorizationUri,
        required callbackUrlScheme,
        required redirectUri,
      }) async {
        final state = authorizationUri.queryParameters['state']!;
        return '$redirectUri?code=auth-code-123&state=$state';
      });

      await mount(tester, const RegisterPage());
      final googleBtn = find.byKey(const ValueKey('google-register-button'));
      await tester.ensureVisible(googleBtn);
      await tester.pumpAndSettle();

      await http.runWithClient(
        () async {
          await tester.tap(googleBtn);
          await tester.pumpAndSettle();
        },
        () => MockClient((request) async {
          if (request.url.host == 'oauth2.googleapis.com') {
            return http.Response(
              jsonEncode({'id_token': 'token-abc'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
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
