import 'package:dio/dio.dart';

import '../models/user.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';

/// Auth Repository Interface
abstract class IAuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
}

/// Auth Repository Implementation
class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  User? _currentUser;

  AuthRepository({
    required ApiClient apiClient,
    SecureStorageService? storage,
  })  : _apiClient = apiClient,
        _storage = storage ?? SecureStorageService();

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/auth/login',
        data: {
          'username': request.email,
          'password': request.password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      return _handleTokenResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      throw AuthException(detail?.toString() ?? 'Invalid email or password');
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/auth/register',
        data: {
          'email': request.email,
          'password': request.password,
          'full_name': request.name,
        },
      );

      return _handleTokenResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      throw AuthException(detail?.toString() ?? 'Registration failed');
    }
  }

  @override
  Future<void> logout() async {
    await _storage.clearAll();
    _apiClient.clearAuthToken();
    _currentUser = null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final token = await _storage.getAccessToken();
    if (token == null) return null;

    try {
      final response = await _apiClient.get('/api/v1/auth/me');
      _currentUser = _userFromJson(response.data as Map<String, dynamic>);
      return _currentUser;
    } on DioException {
      await _storage.clearAll();
      return null;
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Future<AuthResponse> _handleTokenResponse(Map<String, dynamic> data) async {
    final token = data['access_token'] as String;
    final user = _userFromJson(data['user'] as Map<String, dynamic>);

    await _storage.saveAccessToken(token);
    await _storage.saveUserId(user.id);
    _currentUser = user;

    return AuthResponse(accessToken: token, user: user);
  }

  User _userFromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] as String,
      name: (json['full_name'] as String?) ?? '',
      createdAt: DateTime.now(),
    );
  }
}

/// Auth Exception
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
