import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import '../storage/secure_storage.dart';

/// API Client for AirShield Backend
///
/// Automatically switches base URL based on platform:
/// - Android Emulator: http://10.0.2.2:8000
/// - iOS Simulator/Web/Desktop: http://localhost:8000
class ApiClient {
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000';
  static const String _defaultBaseUrl = 'http://localhost:8000';

  late final Dio _dio;
  final SecureStorageService _storage;

  ApiClient({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService() {
    _dio = Dio(_createBaseOptions());
    _setupInterceptors();
  }

  /// Get the Dio instance for making HTTP requests
  Dio get dio => _dio;

  /// Create BaseOptions with platform-specific base URL
  BaseOptions _createBaseOptions() {
    return BaseOptions(
      baseUrl: _getBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// Get the appropriate base URL based on platform.
  /// Android emulator routes host-machine localhost via 10.0.2.2.
  String _getBaseUrl() {
    if (kIsWeb) return _defaultBaseUrl;
    if (kDebugMode && Platform.isAndroid) return _androidEmulatorBaseUrl;
    return _defaultBaseUrl;
  }

  /// Setup Dio interceptors for logging, auth, and error handling
  void _setupInterceptors() {
    // Logging Interceptor — debug builds only, headers excluded to protect tokens
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,  // Never log Authorization headers
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint('[API] $object'),
        ),
      );
    }

    // Auth Interceptor - Add token to requests and handle session expiry
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final token = await _storage.getAccessToken();
            if (token != null) {
              // Token expired — clear session so app redirects to login
              await _storage.clearAll();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Update the authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear the authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // ─── HTTP Wrapper Methods ────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
}
