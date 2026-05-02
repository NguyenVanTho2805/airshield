import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User Model
/// 
/// Represents authenticated user data
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    DateTime? createdAt,
    @Default('') String bio,
    String? phoneNumber,
    @Default(3) int aqiSensitivityLevel, // 1-5, 3 is moderate
    @Default(100) int customAqiThreshold, // Custom alert threshold
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Auth Response Model
/// 
/// Contains tokens and user data from login/register
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    String? refreshToken,
    required User user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

/// Login Request
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

/// Register Request
@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String name,
    required String email,
    required String password,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
