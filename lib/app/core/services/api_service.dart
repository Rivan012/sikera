import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../routes/app_pages.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int statusCode;
  final bool isMalformed;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.statusCode,
    this.isMalformed = false,
  });
}

class ApiService {
  ApiService._();

  static Map<String, String> _buildHeaders({bool auth = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<ApiResponse<dynamic>> get(
    String endpoint, {
    bool auth = true,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await http
          .get(uri, headers: _buildHeaders(auth: auth))
          .timeout(const Duration(seconds: 25));
      return _handleResponse(response, auth: auth);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Server belum merespons. Silakan coba lagi.',
        statusCode: 0,
      );
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Koneksi internet bermasalah. Periksa koneksi Anda.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan sistem: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 25));
      return _handleResponse(response, auth: auth);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message:
            'Server belum merespons. Permintaan mungkin sudah diproses; periksa hasil sebelum mengirim ulang.',
        statusCode: 0,
      );
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Koneksi internet bermasalah. Periksa koneksi Anda.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan sistem: $e',
        statusCode: 500,
      );
    }
  }

  static ApiResponse<dynamic> _handleResponse(
    http.Response response, {
    required bool auth,
  }) {
    if (auth && response.statusCode == 401) {
      StorageService.clearAuth();
      if (Get.currentRoute != Routes.LOGIN) {
        Get.offAllNamed(Routes.LOGIN);
      }
    }
    try {
      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: decoded is Map && decoded.containsKey('success')
              ? decoded['success'] == true
              : true,
          message: decoded is Map ? decoded['message']?.toString() : null,
          data: decoded is Map && decoded.containsKey('data')
              ? decoded['data']
              : decoded,
          statusCode: response.statusCode,
        );
      } else {
        String? errorMsg;
        if (decoded is Map) {
          if (decoded['errors'] is Map) {
            final errorsMap = decoded['errors'] as Map;
            final errorList = <String>[];
            errorsMap.forEach((key, value) {
              if (value is List) {
                errorList.addAll(value.map((e) => e.toString()));
              } else {
                errorList.add(value.toString());
              }
            });
            if (errorList.isNotEmpty) {
              errorMsg = errorList.join('\n');
            }
          }
          errorMsg ??= decoded['message']?.toString();
        }

        if (errorMsg != null) {
          if (errorMsg.contains('users.nim') ||
              errorMsg.contains('UNIQUE constraint failed: users.nim')) {
            errorMsg =
                'NIM ini sudah terdaftar. Silakan gunakan NIM lain atau masuk ke akun Anda.';
          } else if (errorMsg.contains('users.email') ||
              errorMsg.contains('UNIQUE constraint failed: users.email')) {
            errorMsg =
                'Email ini sudah terdaftar. Silakan masuk menggunakan akun Anda.';
          } else if (errorMsg.contains('SQLSTATE')) {
            errorMsg =
                'Terjadi kendala pada basis data server. Silakan coba beberapa saat lagi.';
          }
        }

        return ApiResponse(
          success: false,
          message:
              errorMsg ?? 'Permintaan gagal (Kode: ${response.statusCode})',
          data: decoded,
          statusCode: response.statusCode,
        );
      }
    } catch (_) {
      return ApiResponse(
        success: false,
        message: 'Respon server tidak valid.',
        statusCode: response.statusCode,
        isMalformed: true,
      );
    }
  }
}
