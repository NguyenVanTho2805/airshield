// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  bio: json['bio'] as String? ?? '',
  phoneNumber: json['phoneNumber'] as String?,
  aqiSensitivityLevel: (json['aqiSensitivityLevel'] as num?)?.toInt() ?? 3,
  customAqiThreshold: (json['customAqiThreshold'] as num?)?.toInt() ?? 100,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'bio': instance.bio,
      'phoneNumber': instance.phoneNumber,
      'aqiSensitivityLevel': instance.aqiSensitivityLevel,
      'customAqiThreshold': instance.customAqiThreshold,
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
    };

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_$RegisterRequestImpl _$$RegisterRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RegisterRequestImpl(
  name: json['name'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$RegisterRequestImplToJson(
  _$RegisterRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'password': instance.password,
};
