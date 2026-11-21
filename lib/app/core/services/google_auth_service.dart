import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

abstract class GoogleSignInAdapter {
  Future<String?> authenticate();
  Future<void> signOut();
}

class _DefaultGoogleSignInAdapter implements GoogleSignInAdapter {
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: ApiConstants.googleClientId.isNotEmpty
          ? ApiConstants.googleClientId
          : null,
      serverClientId: ApiConstants.googleServerClientId.isNotEmpty
          ? ApiConstants.googleServerClientId
          : null,
    );
    _initialized = true;
  }

  @override
  Future<String?> authenticate() async {
    await _ensureInitialized();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'Platform ini belum mendukung dialog masuk Google secara langsung.',
      );
    }
    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: const ['email', 'profile'],
    );
    return account.authentication.idToken;
  }

  @override
  Future<void> signOut() async {
    if (!_initialized) return;
    await GoogleSignIn.instance.signOut();
  }
}

class GoogleAuthService {
  GoogleAuthService._();

  static GoogleSignInAdapter _adapter = _DefaultGoogleSignInAdapter();

  @visibleForTesting
  static set adapter(GoogleSignInAdapter value) => _adapter = value;

  @visibleForTesting
  static void resetAdapter() => _adapter = _DefaultGoogleSignInAdapter();

  static Future<GoogleAuthResult> signIn() async {
    String? idToken;
    try {
      idToken = (await _adapter.authenticate())?.trim();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return GoogleAuthResult.canceled();
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        return GoogleAuthResult.failure(
          'Konfigurasi masuk dengan Google belum tersedia pada aplikasi ini. Gunakan email dan kata sandi untuk sementara.',
        );
      }
      if (e.code == GoogleSignInExceptionCode.uiUnavailable) {
        return GoogleAuthResult.failure(
          'Layar pemilihan akun Google tidak tersedia saat ini. Coba lagi beberapa saat lagi.',
        );
      }
      return GoogleAuthResult.failure(
        'Gagal menghubungkan akun Google. Periksa koneksi internet lalu coba lagi.',
      );
    } on UnsupportedError {
      return GoogleAuthResult.failure(
        'Masuk dengan Google belum didukung pada perangkat ini. Gunakan email dan kata sandi.',
      );
    } on MissingPluginException {
      return GoogleAuthResult.failure(
        'Layanan masuk dengan Google belum aktif pada perangkat ini. Gunakan email dan kata sandi.',
      );
    } on PlatformException {
      return GoogleAuthResult.failure(
        'Gagal membuka layanan Google pada perangkat ini. Pastikan Google Play Services aktif lalu coba lagi.',
      );
    } catch (_) {
      return GoogleAuthResult.failure(
        'Gagal menghubungkan akun Google. Silakan coba lagi.',
      );
    }

    if (idToken == null || idToken.isEmpty) {
      return GoogleAuthResult.failure(
        'Token verifikasi Google tidak ditemukan. Pastikan konfigurasi OAuth aplikasi sudah lengkap.',
      );
    }

    final response = await ApiService.post(
      ApiConstants.login,
      body: {'id_token': idToken},
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
    try {
      await _adapter.signOut();
    } catch (_) {
      // Abaikan jika Google Sign-In tidak digunakan pada sesi ini.
    }
  }
}
