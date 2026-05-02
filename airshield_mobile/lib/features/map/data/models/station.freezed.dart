// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AqiStation _$AqiStationFromJson(Map<String, dynamic> json) {
  return _AqiStation.fromJson(json);
}

/// @nodoc
mixin _$AqiStation {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  int get aqi => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;

  /// Serializes this AqiStation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AqiStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AqiStationCopyWith<AqiStation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AqiStationCopyWith<$Res> {
  factory $AqiStationCopyWith(
    AqiStation value,
    $Res Function(AqiStation) then,
  ) = _$AqiStationCopyWithImpl<$Res, AqiStation>;
  @useResult
  $Res call({
    int id,
    String name,
    double latitude,
    double longitude,
    int aqi,
    String? source,
    bool? isActive,
  });
}

/// @nodoc
class _$AqiStationCopyWithImpl<$Res, $Val extends AqiStation>
    implements $AqiStationCopyWith<$Res> {
  _$AqiStationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AqiStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? aqi = null,
    Object? source = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            aqi: null == aqi
                ? _value.aqi
                : aqi // ignore: cast_nullable_to_non_nullable
                      as int,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AqiStationImplCopyWith<$Res>
    implements $AqiStationCopyWith<$Res> {
  factory _$$AqiStationImplCopyWith(
    _$AqiStationImpl value,
    $Res Function(_$AqiStationImpl) then,
  ) = __$$AqiStationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    double latitude,
    double longitude,
    int aqi,
    String? source,
    bool? isActive,
  });
}

/// @nodoc
class __$$AqiStationImplCopyWithImpl<$Res>
    extends _$AqiStationCopyWithImpl<$Res, _$AqiStationImpl>
    implements _$$AqiStationImplCopyWith<$Res> {
  __$$AqiStationImplCopyWithImpl(
    _$AqiStationImpl _value,
    $Res Function(_$AqiStationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AqiStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? aqi = null,
    Object? source = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _$AqiStationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        aqi: null == aqi
            ? _value.aqi
            : aqi // ignore: cast_nullable_to_non_nullable
                  as int,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AqiStationImpl extends _AqiStation {
  const _$AqiStationImpl({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.aqi,
    this.source,
    this.isActive,
  }) : super._();

  factory _$AqiStationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AqiStationImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final int aqi;
  @override
  final String? source;
  @override
  final bool? isActive;

  @override
  String toString() {
    return 'AqiStation(id: $id, name: $name, latitude: $latitude, longitude: $longitude, aqi: $aqi, source: $source, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AqiStationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.aqi, aqi) || other.aqi == aqi) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    latitude,
    longitude,
    aqi,
    source,
    isActive,
  );

  /// Create a copy of AqiStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AqiStationImplCopyWith<_$AqiStationImpl> get copyWith =>
      __$$AqiStationImplCopyWithImpl<_$AqiStationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AqiStationImplToJson(this);
  }
}

abstract class _AqiStation extends AqiStation {
  const factory _AqiStation({
    required final int id,
    required final String name,
    required final double latitude,
    required final double longitude,
    required final int aqi,
    final String? source,
    final bool? isActive,
  }) = _$AqiStationImpl;
  const _AqiStation._() : super._();

  factory _AqiStation.fromJson(Map<String, dynamic> json) =
      _$AqiStationImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  int get aqi;
  @override
  String? get source;
  @override
  bool? get isActive;

  /// Create a copy of AqiStation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AqiStationImplCopyWith<_$AqiStationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
