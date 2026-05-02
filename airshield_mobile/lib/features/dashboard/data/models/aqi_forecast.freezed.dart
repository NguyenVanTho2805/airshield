// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aqi_forecast.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AqiForecastItem _$AqiForecastItemFromJson(Map<String, dynamic> json) {
  return _AqiForecastItem.fromJson(json);
}

/// @nodoc
mixin _$AqiForecastItem {
  int get aqi => throw _privateConstructorUsedError;
  DateTime get recordedAt => throw _privateConstructorUsedError;
  bool get isForecast => throw _privateConstructorUsedError;

  /// Serializes this AqiForecastItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AqiForecastItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AqiForecastItemCopyWith<AqiForecastItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AqiForecastItemCopyWith<$Res> {
  factory $AqiForecastItemCopyWith(
    AqiForecastItem value,
    $Res Function(AqiForecastItem) then,
  ) = _$AqiForecastItemCopyWithImpl<$Res, AqiForecastItem>;
  @useResult
  $Res call({int aqi, DateTime recordedAt, bool isForecast});
}

/// @nodoc
class _$AqiForecastItemCopyWithImpl<$Res, $Val extends AqiForecastItem>
    implements $AqiForecastItemCopyWith<$Res> {
  _$AqiForecastItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AqiForecastItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aqi = null,
    Object? recordedAt = null,
    Object? isForecast = null,
  }) {
    return _then(
      _value.copyWith(
            aqi: null == aqi
                ? _value.aqi
                : aqi // ignore: cast_nullable_to_non_nullable
                      as int,
            recordedAt: null == recordedAt
                ? _value.recordedAt
                : recordedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isForecast: null == isForecast
                ? _value.isForecast
                : isForecast // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AqiForecastItemImplCopyWith<$Res>
    implements $AqiForecastItemCopyWith<$Res> {
  factory _$$AqiForecastItemImplCopyWith(
    _$AqiForecastItemImpl value,
    $Res Function(_$AqiForecastItemImpl) then,
  ) = __$$AqiForecastItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int aqi, DateTime recordedAt, bool isForecast});
}

/// @nodoc
class __$$AqiForecastItemImplCopyWithImpl<$Res>
    extends _$AqiForecastItemCopyWithImpl<$Res, _$AqiForecastItemImpl>
    implements _$$AqiForecastItemImplCopyWith<$Res> {
  __$$AqiForecastItemImplCopyWithImpl(
    _$AqiForecastItemImpl _value,
    $Res Function(_$AqiForecastItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AqiForecastItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aqi = null,
    Object? recordedAt = null,
    Object? isForecast = null,
  }) {
    return _then(
      _$AqiForecastItemImpl(
        aqi: null == aqi
            ? _value.aqi
            : aqi // ignore: cast_nullable_to_non_nullable
                  as int,
        recordedAt: null == recordedAt
            ? _value.recordedAt
            : recordedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isForecast: null == isForecast
            ? _value.isForecast
            : isForecast // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AqiForecastItemImpl implements _AqiForecastItem {
  const _$AqiForecastItemImpl({
    required this.aqi,
    required this.recordedAt,
    this.isForecast = true,
  });

  factory _$AqiForecastItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$AqiForecastItemImplFromJson(json);

  @override
  final int aqi;
  @override
  final DateTime recordedAt;
  @override
  @JsonKey()
  final bool isForecast;

  @override
  String toString() {
    return 'AqiForecastItem(aqi: $aqi, recordedAt: $recordedAt, isForecast: $isForecast)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AqiForecastItemImpl &&
            (identical(other.aqi, aqi) || other.aqi == aqi) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt) &&
            (identical(other.isForecast, isForecast) ||
                other.isForecast == isForecast));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, aqi, recordedAt, isForecast);

  /// Create a copy of AqiForecastItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AqiForecastItemImplCopyWith<_$AqiForecastItemImpl> get copyWith =>
      __$$AqiForecastItemImplCopyWithImpl<_$AqiForecastItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AqiForecastItemImplToJson(this);
  }
}

abstract class _AqiForecastItem implements AqiForecastItem {
  const factory _AqiForecastItem({
    required final int aqi,
    required final DateTime recordedAt,
    final bool isForecast,
  }) = _$AqiForecastItemImpl;

  factory _AqiForecastItem.fromJson(Map<String, dynamic> json) =
      _$AqiForecastItemImpl.fromJson;

  @override
  int get aqi;
  @override
  DateTime get recordedAt;
  @override
  bool get isForecast;

  /// Create a copy of AqiForecastItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AqiForecastItemImplCopyWith<_$AqiForecastItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AqiForecastResponse _$AqiForecastResponseFromJson(Map<String, dynamic> json) {
  return _AqiForecastResponse.fromJson(json);
}

/// @nodoc
mixin _$AqiForecastResponse {
  List<AqiForecastItem> get data => throw _privateConstructorUsedError;

  /// Serializes this AqiForecastResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AqiForecastResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AqiForecastResponseCopyWith<AqiForecastResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AqiForecastResponseCopyWith<$Res> {
  factory $AqiForecastResponseCopyWith(
    AqiForecastResponse value,
    $Res Function(AqiForecastResponse) then,
  ) = _$AqiForecastResponseCopyWithImpl<$Res, AqiForecastResponse>;
  @useResult
  $Res call({List<AqiForecastItem> data});
}

/// @nodoc
class _$AqiForecastResponseCopyWithImpl<$Res, $Val extends AqiForecastResponse>
    implements $AqiForecastResponseCopyWith<$Res> {
  _$AqiForecastResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AqiForecastResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<AqiForecastItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AqiForecastResponseImplCopyWith<$Res>
    implements $AqiForecastResponseCopyWith<$Res> {
  factory _$$AqiForecastResponseImplCopyWith(
    _$AqiForecastResponseImpl value,
    $Res Function(_$AqiForecastResponseImpl) then,
  ) = __$$AqiForecastResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<AqiForecastItem> data});
}

/// @nodoc
class __$$AqiForecastResponseImplCopyWithImpl<$Res>
    extends _$AqiForecastResponseCopyWithImpl<$Res, _$AqiForecastResponseImpl>
    implements _$$AqiForecastResponseImplCopyWith<$Res> {
  __$$AqiForecastResponseImplCopyWithImpl(
    _$AqiForecastResponseImpl _value,
    $Res Function(_$AqiForecastResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AqiForecastResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$AqiForecastResponseImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<AqiForecastItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AqiForecastResponseImpl implements _AqiForecastResponse {
  const _$AqiForecastResponseImpl({required final List<AqiForecastItem> data})
    : _data = data;

  factory _$AqiForecastResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AqiForecastResponseImplFromJson(json);

  final List<AqiForecastItem> _data;
  @override
  List<AqiForecastItem> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'AqiForecastResponse(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AqiForecastResponseImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  /// Create a copy of AqiForecastResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AqiForecastResponseImplCopyWith<_$AqiForecastResponseImpl> get copyWith =>
      __$$AqiForecastResponseImplCopyWithImpl<_$AqiForecastResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AqiForecastResponseImplToJson(this);
  }
}

abstract class _AqiForecastResponse implements AqiForecastResponse {
  const factory _AqiForecastResponse({
    required final List<AqiForecastItem> data,
  }) = _$AqiForecastResponseImpl;

  factory _AqiForecastResponse.fromJson(Map<String, dynamic> json) =
      _$AqiForecastResponseImpl.fromJson;

  @override
  List<AqiForecastItem> get data;

  /// Create a copy of AqiForecastResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AqiForecastResponseImplCopyWith<_$AqiForecastResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
