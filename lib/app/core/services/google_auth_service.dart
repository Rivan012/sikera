import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'api_service.dart';

class GoogleAuthResult {
  final bool success;
  final bool canceled;
  final String? token;
  final Map<String, dynamic>? user;
  final String? message;

  const GoogleAuthResult._({
    required this.success,
    this.canceled = false,
    this.token,
    this.user,
    this.message,
  });

  factory GoogleAuthResult.success({
    required String token,
    required Map<String, dynamic> user,
    String? message,
  }) {
    return GoogleAuthResult._(
      success: true,
      token: token,
      user: user,
      message: message,
    );
  }

  factory GoogleAuthResult.canceled() {
    return const GoogleAuthResult._(success: false, canceled: true);
  }

  factory GoogleAuthResult.failure(String message) {
    return GoogleAuthResult._(success: false, message: message);
  }
}

class GoogleOAuthConfig {
  final String clientId;
  final String redirectUri;
  final String callbackUrlScheme;

  const GoogleOAuthConfig({
    required this.clientId,
    required this.redirectUri,
    required this.callbackUrlScheme,
  });
}

class PkcePair {
  final String codeVerifier;
  final String codeChallenge;

  const PkcePair({
    required this.codeVerifier,
    required this.codeChallenge,
  });

  factory PkcePair.generate([Random? random]) {
    final rng = random ?? Random.secure();
    final verifierBytes = List<int>.generate(32, (_) => rng.nextInt(256));
    final verifier = base64UrlEncode(verifierBytes).replaceAll('=', '');
    final challengeBytes = sha256.convert(utf8.encode(verifier)).bytes;
    final challenge = base64UrlEncode(challengeBytes).replaceAll('=', '');
    return PkcePair(codeVerifier: verifier, codeChallenge: challenge);
  }
}

abstract class GoogleOAuthBrowserAdapter {
  Future<String> authenticate({
    required Uri authorizationUri,
    required String callbackUrlScheme,
    required Uri redirectUri,
  });
}

class _DefaultGoogleOAuthBrowserAdapter implements GoogleOAuthBrowserAdapter {
  @override
  Future<String> authenticate({
    required Uri authorizationUri,
    required String callbackUrlScheme,
    required Uri redirectUri,
  }) {
    final options = callbackUrlScheme == 'https'
        ? FlutterWebAuth2Options(
            httpsHost: redirectUri.host,
            httpsPath: redirectUri.path,
          )
        : const FlutterWebAuth2Options();

    return FlutterWebAuth2.authenticate(
      url: authorizationUri.toString(),
      callbackUrlScheme: callbackUrlScheme,
      options: options,
    );
  }
}

class GoogleAuthService {
  GoogleAuthService._();

  static const String _googleClientSuffix = '.apps.googleusercontent.com';
  static const String _defaultRedirectPath = '/oauth2redirect';
  static final RegExp _schemePattern = RegExp(r'^[a-z][a-z\d+.-]*$');

  static GoogleOAuthBrowserAdapter _browserAdapter =
      _DefaultGoogleOAuthBrowserAdapter();
  static String? _lastAccessToken;

  @visibleForTesting
  static set browserAdapter(GoogleOAuthBrowserAdapter value) =>
      _browserAdapter = value;

  @visibleForTesting
  static void resetAdapter() {
    _browserAdapter = _DefaultGoogleOAuthBrowserAdapter();
    _lastAccessToken = null;
  }

  /// Resolves platform-specific Google OAuth 2.0 public client settings.
  @visibleForTesting
  static GoogleOAuthConfig? resolveConfig() {
    final String clientId;
    final String explicitRedirectUri;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      clientId = _firstNonEmpty([
        ApiConstants.googleAndroidClientId,
        ApiConstants.googleClientId,
      ]);
      explicitRedirectUri = _firstNonEmpty([
        ApiConstants.googleAndroidRedirectUri,
        ApiConstants.googleRedirectUri,
      ]);
    } else if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      clientId = _firstNonEmpty([
        ApiConstants.googleIosClientId,
        ApiConstants.googleClientId,
      ]);
      explicitRedirectUri = _firstNonEmpty([
        ApiConstants.googleIosRedirectUri,
        ApiConstants.googleRedirectUri,
      ]);
    } else {
      clientId = ApiConstants.googleClientId;
      explicitRedirectUri = ApiConstants.googleRedirectUri;
    }

    if (clientId.isEmpty || _looksLikePlaceholder(clientId)) {
      return null;
    }

    final redirectUri = explicitRedirectUri.isNotEmpty
        ? explicitRedirectUri
        : deriveRedirectUri(clientId);
    if (redirectUri == null || redirectUri.isEmpty) {
      return null;
    }

    final parsedRedirect = Uri.tryParse(redirectUri);
    final scheme = parsedRedirect?.scheme.toLowerCase() ?? '';
    if (parsedRedirect == null || !_schemePattern.hasMatch(scheme)) {
      return null;
    }

    return GoogleOAuthConfig(
      clientId: clientId,
      redirectUri: redirectUri,
      callbackUrlScheme: scheme,
    );
  }

  /// Derives the standard Google reversed client ID redirect URI
  /// (`com.googleusercontent.apps.<prefix>:/oauth2redirect`).
  @visibleForTesting
  static String? deriveRedirectUri(String clientId) {
    final trimmed = clientId.trim();
    if (!trimmed.toLowerCase().endsWith(_googleClientSuffix)) {
      return null;
    }
    final prefix = trimmed
        .substring(0, trimmed.length - _googleClientSuffix.length)
        .toLowerCase();
    if (prefix.isEmpty) return null;
    return 'com.googleusercontent.apps.$prefix:$_defaultRedirectPath';
  }

  static Future<GoogleAuthResult> signIn() async {
    final config = resolveConfig();
    if (config == null) {
      return GoogleAuthResult.failure(
        'Konfigurasi OAuth Google belum lengkap di file .env. Isi GOOGLE_ANDROID_CLIENT_ID atau GOOGLE_IOS_CLIENT_ID lalu coba lagi.',
      );
    }

    final parsedRedirect = Uri.parse(config.redirectUri);
    final pkce = PkcePair.generate();
    final state = _generateRandomToken(24);
    final nonce = _generateRandomToken(24);

    final authorizationUri = Uri.parse(ApiConstants.googleAuthEndpoint).replace(
      queryParameters: {
        'client_id': config.clientId,
        'redirect_uri': config.redirectUri,
        'response_type': 'code',
        'scope': 'openid email profile',
        'code_challenge': pkce.codeChallenge,
        'code_challenge_method': 'S256',
        'state': state,
        'nonce': nonce,
        'prompt': 'select_account',
      },
    );

    final String callbackUrl;
    try {
      callbackUrl = await _browserAdapter.authenticate(
        authorizationUri: authorizationUri,
        callbackUrlScheme: config.callbackUrlScheme,
        redirectUri: parsedRedirect,
      );
    } on PlatformException catch (e) {
      final code = e.code.toUpperCase();
      if (code == 'CANCELED' || code == 'CANCELLED') {
        return GoogleAuthResult.canceled();
      }
      return GoogleAuthResult.failure(
        'Gagal membuka halaman masuk Google di perangkat ini. Pastikan browser tersedia lalu coba lagi.',
      );
    } on UnsupportedError {
      return GoogleAuthResult.failure(
        'Masuk dengan Google belum didukung pada perangkat ini. Gunakan email dan kata sandi.',
      );
    } on MissingPluginException {
      return GoogleAuthResult.failure(
        'Layanan masuk dengan Google belum aktif pada perangkat ini. Gunakan email dan kata sandi.',
      );
    } catch (_) {
      return GoogleAuthResult.failure(
        'Gagal menghubungkan akun Google. Silakan coba lagi.',
      );
    }

    final callbackUri = Uri.tryParse(callbackUrl);
    if (callbackUri == null) {
      return GoogleAuthResult.failure(
        'Respon otorisasi Google tidak valid. Silakan coba lagi.',
      );
    }

    final oauthError = callbackUri.queryParameters['error']?.trim();
    if (oauthError != null && oauthError.isNotEmpty) {
      if (oauthError == 'access_denied') {
        return GoogleAuthResult.canceled();
      }
      return GoogleAuthResult.failure(_mapGoogleOAuthError(oauthError));
    }

    final returnedState = callbackUri.queryParameters['state']?.trim();
    if (returnedState == null || returnedState != state) {
      return GoogleAuthResult.failure(
        'Verifikasi keamanan sesi Google gagal (state tidak cocok). Silakan coba lagi.',
      );
    }

    final authCode = callbackUri.queryParameters['code']?.trim();
    if (authCode == null || authCode.isEmpty) {
      return GoogleAuthResult.failure(
        'Kode otorisasi Google tidak ditemukan. Silakan coba lagi.',
      );
    }

    final tokenExchange = await _exchangeAuthorizationCode(
      config: config,
      authCode: authCode,
      codeVerifier: pkce.codeVerifier,
      expectedNonce: nonce,
    );
    if (!tokenExchange.success || tokenExchange.idToken == null) {
      return GoogleAuthResult.failure(
        tokenExchange.message ??
            'Gagal menukar kode otorisasi dengan Google API. Silakan coba lagi.',
      );
    }

    _lastAccessToken = tokenExchange.accessToken;

    final response = await ApiService.post(
      ApiConstants.login,
      body: {'id_token': tokenExchange.idToken},
      auth: false,
    );

    if (response.success && response.data is Map) {
      final data = response.data as Map;
      final token = data['token'];
      final rawUser = data['user'];

      if (token is String &&
          token.trim().isNotEmpty &&
          rawUser is Map &&
          (int.tryParse('${rawUser['id']}') ?? 0) > 0) {
        return GoogleAuthResult.success(
          token: token,
          user: Map<String, dynamic>.from(rawUser),
          message: response.message,
        );
      }

      return GoogleAuthResult.failure(
        'Sesi akun Google belum tersedia dari server. Coba lagi atau masuk dengan email dan kata sandi.',
      );
    }

    if (response.statusCode == 404 || response.statusCode == 405) {
      return GoogleAuthResult.failure(
        'Layanan masuk dengan Google belum aktif di server SIKERA. Gunakan email dan kata sandi untuk sementara.',
      );
    }

    return GoogleAuthResult.failure(
      response.message ??
          'Gagal masuk dengan Google. Periksa koneksi internet lalu coba lagi.',
    );
  }

  static Future<void> signOut() async {
    final accessToken = _lastAccessToken;
    _lastAccessToken = null;
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      await http
          .post(
            Uri.parse(ApiConstants.googleRevokeEndpoint),
            headers: const {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'token': accessToken},
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Best-effort revocation; local session still clears on logout.
    }
  }

  static Future<_GoogleTokenResult> _exchangeAuthorizationCode({
    required GoogleOAuthConfig config,
    required String authCode,
    required String codeVerifier,
    required String expectedNonce,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.googleTokenEndpoint),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'client_id': config.clientId,
              'code': authCode,
              'code_verifier': codeVerifier,
              'grant_type': 'authorization_code',
              'redirect_uri': config.redirectUri,
            },
          )
          .timeout(const Duration(seconds: 25));

      Map<String, dynamic>? body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      } catch (_) {}

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final idToken = body?['id_token']?.toString().trim();
        final accessToken = body?['access_token']?.toString().trim();
        if (idToken == null || idToken.isEmpty) {
          return const _GoogleTokenResult.failure(
            'Token verifikasi Google (id_token) tidak diterima. Pastikan scope openid aktif.',
          );
        }

        if (!_verifyNonceIfPresent(idToken, expectedNonce)) {
          return const _GoogleTokenResult.failure(
            'Verifikasi keamanan token Google gagal (nonce tidak cocok). Silakan coba lagi.',
          );
        }

        return _GoogleTokenResult.success(
          idToken: idToken,
          accessToken: accessToken,
        );
      }

      final error = body?['error']?.toString() ?? '';
      final description = body?['error_description']?.toString() ?? '';
      if (description.toLowerCase().contains('client_secret')) {
        return const _GoogleTokenResult.failure(
          'Client ID Google di .env tampaknya bertipe Web (meminta client_secret). Gunakan OAuth Client ID tipe Android/iOS untuk login PKCE mobile.',
        );
      }

      return _GoogleTokenResult.failure(
        _mapGoogleOAuthError(error, description: description),
      );
    } on TimeoutException {
      return const _GoogleTokenResult.failure(
        'Server Google belum merespons. Periksa koneksi internet lalu coba lagi.',
      );
    } on SocketException {
      return const _GoogleTokenResult.failure(
        'Koneksi internet bermasalah saat menghubungi Google API.',
      );
    } catch (_) {
      return const _GoogleTokenResult.failure(
        'Gagal menukar token dengan Google API. Silakan coba lagi.',
      );
    }
  }

  static bool _verifyNonceIfPresent(String idToken, String expectedNonce) {
    final segments = idToken.split('.');
    if (segments.length != 3) return true;
    try {
      final normalized = base64Url.normalize(segments[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is Map && payload.containsKey('nonce')) {
        return payload['nonce']?.toString() == expectedNonce;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  static String _mapGoogleOAuthError(
    String error, {
    String description = '',
  }) {
    switch (error.toLowerCase()) {
      case 'invalid_client':
      case 'unauthorized_client':
      case 'redirect_uri_mismatch':
        return 'Konfigurasi OAuth Google tidak cocok dengan Google Cloud Console. Periksa Client ID, custom URI scheme, dan redirect URI di file .env.';
      case 'invalid_grant':
        return 'Kode otorisasi Google sudah kedaluwarsa atau tidak valid. Silakan coba masuk kembali.';
      default:
        if (description.toLowerCase().contains('redirect_uri')) {
          return 'Redirect URI Google OAuth tidak cocok dengan konfigurasi di Google Cloud Console.';
        }
        return 'Autentikasi Google ditolak oleh Google API. Periksa konfigurasi OAuth Anda lalu coba lagi.';
    }
  }

  static String _generateRandomToken(int byteLength) {
    final rng = Random.secure();
    final bytes = List<int>.generate(byteLength, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  static bool _looksLikePlaceholder(String value) {
    final lower = value.toLowerCase();
    return lower.contains('your_') ||
        lower.contains('isi_') ||
        (value.startsWith('<') && value.endsWith('>'));
  }
}

class _GoogleTokenResult {
  final bool success;
  final String? idToken;
  final String? accessToken;
  final String? message;

  const _GoogleTokenResult._({
    required this.success,
    this.idToken,
    this.accessToken,
    this.message,
  });

  const _GoogleTokenResult.success({
    required String idToken,
    String? accessToken,
  }) : this._(
         success: true,
         idToken: idToken,
         accessToken: accessToken,
       );

  const _GoogleTokenResult.failure(String message)
    : this._(success: false, message: message);
}
