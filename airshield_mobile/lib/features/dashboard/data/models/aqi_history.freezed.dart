// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aqi_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AqiHistoryItem _$AqiHistoryItemFromJson(Map<String, dynamic> json) {
  return _AqiHistoryItem.fromJson(json);
}

/// @nodoc
mixin _$AqiHistoryItem {
  int get aqi => throw _privateConstructorUsedError;
  double? get pm25 => throw _privateConstructorUsedError;
  DateTime get recordedAt => throw _privateConstructorUsedError;

  /// Serializes this AqiHistoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AqiHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AqiHistoryItemCopyWith<AqiHistoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AqiHistoryItemCopyWith<$Res> {
  factory $AqiHistoryItemCopyWith(
    AqiHistoryItem value,
    $Res Function(AqiHistoryItem) then,
  ) = _$AqiHistoryItemCopyWithImpl<$Res, AqiHistoryItem>;
  @useResult
  $Res call({int aqi, double? pm25, DateTime recordedAt});
}

/// @nodoc
class _$AqiHistoryItemCopyWithImpl<$Res, $Val extends AqiHistoryItem>
    implements $AqiHistoryItemCopyWith<$Res> {
  _$AqiHistoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AqiHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aqi = null,
    Object? pm25 = freezed,
    Object? recordedAt = null,
  }) {
    return _then(
      _value.copyWith(
            aqi: null == aqi
                ? _value.aqi
                : aqi // ignore: cast_nullable_to_non_nullable
                      as int,
            pm25: freezed == pm25
                ? _value.pm25
                : pm25 // ignore: cast_nullable_to_non_nullable
                      as double?,
            recordedAt: null == recordedAt
                ? _value.recordedAt
                : recordedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AqiHistoryItemImplCopyWith<$Res>
    implements $AqiHistoryItemCopyWith<$Res> {
  factory _$$AqiHistoryItemImplCopyWith(
    _$AqiHistoryItemImpl value,
    $Res Function(_$AqiHistoryItemImpl) then,
  ) = __$$AqiHistoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int aqi, double? pm25, DateTime recordedAt});
}

/// @nodoc
class __$$AqiHistoryItemImplCopyWithImpl<$Res>
    extends _$AqiHistoryItemCopyWithImpl<$Res, _$AqiHistoryItemImpl>
    implements _$$AqiHistoryItemImplCopyWith<$Res> {
  __$$AqiHistoryItemImplCopyWithImpl(
    _$AqiHistoryItemImpl _value,
    $Res Function(_$AqiHistoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AqiHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aqi = null,
    Object? pm25 = freezed,
    Object? recordedAt = null,
  }) {
    return _then(
      _$AqiHistoryItemImpl(
        aqi: null == aqi
            ? _value.aqi
            : aqi // ignore: cast_nullable_to_non_nullable
                  as int,
        pm25: freezed == pm25
            ? _value.pm25
            : pm25 // ignore: cast_nullable_to_non_nullable
                  as double?,
        recordedAt: null == recordedAt
            ? _value.recordedAt
            : recordedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AqiHistoryItemImpl implements _AqiHistoryItem {
  const _$AqiHistoryItemImpl({
    required this.aqi,
    this.pm25,
    required this.recordedAt,
  });

  factory _$AqiHistoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$AqiHistoryItemImplFromJson(json);

  @override
  final int aqi;
  @override
  final double? pm25;
  @override
  final DateTime recordedAt;

  @override
  String toString() {
    return 'AqiHistoryItem(aqi: $aqi, pm25: $pm25, recordedAt: $recordedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AqiHistoryItemImpl &&
            (identical(other.aqi, aqi) || other.aqi == aqi) &&
            (identical(other.pm25, pm25) || other.pm25 == pm25) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, aqi, pm25, recordedAt);

  /// Create a copy of AqiHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AqiHistoryItemImplCopyWith<_$AqiHistoryItemImpl> get copyWith =>
      __$$AqiHistoryItemImplCopyWithImpl<_$AqiHistoryItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AqiHistoryItemImplToJson(this);
  }
}

abstract class _AqiHistoryItem implements AqiHistoryItem {
  const factory _AqiHistoryItem({
    required final int aqi,
    final double? pm25,
    required final DateTime recordedAt,
  }) = _$AqiHistoryItemImpl;

  factory _AqiHistoryItem.fromJson(Map<String, dynamic> json) =
      _$AqiHistoryItemImpl.fromJson;

  @override
  int get aqi;
  @override
  double? get pm25;
  @override
  DateTime get recordedAt;

  /// Create a copy of AqiHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AqiHistoryItemImplCopyWith<_$AqiHistoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AqiHistoryResponse _$AqiHistoryResponseFromJson(Map<String, dynamic> json) {
  return _AqiHistoryResponse.fromJson(json);
}

/// @nodoc
mixin _$AqiHistoryResponse {
  String get stationName => throw _privateConstructorUsedError;
  List<AqiHistoryItem> get data => throw _privateConstructorUsedError;

  /// Serializes this AqiHistoryResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AqiHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AqiHistoryResponseCopyWith<AqiHistoryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AqiHistoryResponseCopyWith<$Res> {
  factory $AqiHistoryResponseCopyWith(
    AqiHistoryResponse value,
    $Res Function(AqiHistoryResponse) then,
  ) = _$AqiHistoryResponseCopyWithImpl<$Res, AqiHistoryResponse>;
  @useResult
  $Res call({String stationName, List<AqiHistoryItem> data});
}

/// @nodoc
class _$AqiHistoryResponseCopyWithImpl<$Res, $Val extends AqiHistoryResponse>
    implements $AqiHistoryResponseCopyWith<$Res> {
  _$AqiHistoryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AqiHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stationName = null, Object? data = null}) {
    return _then(
      _value.copyWith(
            stationName: null == stationName
                ? _value.stationName
                : stationName // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<AqiHistoryItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AqiHistoryResponseImplCopyWith<$Res>
    implements $AqiHistoryResponseCopyWith<$Res> {
  factory _$$AqiHistoryResponseImplCopyWith(
    _$AqiHistoryResponseImpl value,
    $Res Function(_$AqiHistoryResponseImpl) then,
  ) = __$$AqiHistoryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String stationName, List<AqiHistoryItem> data});
}

/// @nodoc
class __$$AqiHistoryResponseImplCopyWithImpl<$Res>
    extends _$AqiHistoryResponseCopyWithImpl<$Res, _$AqiHistoryResponseImpl>
    implements _$$AqiHistoryResponseImplCopyWith<$Res> {
  __$$AqiHistoryResponseImplCopyWithImpl(
    _$AqiHistoryResponseImpl _value,
    $Res Function(_$AqiHistoryResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AqiHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stationName = null, Object? data = null}) {
    return _then(
      _$AqiHistoryResponseImpl(
        stationName: null == stationName
            ? _value.stationName
            : stationName // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<AqiHistoryItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AqiHistoryResponseImpl implements _AqiHistoryResponse {
  const _$AqiHistoryResponseImpl({
    required this.stationName,
    required final List<AqiHistoryItem> data,
  }) : _data = data;

  factory _$AqiHistoryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AqiHistoryResponseImplFromJson(json);

  @override
  final String stationName;
  final List<AqiHistoryItem> _data;
  @override
  List<AqiHistoryItem> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'AqiHistoryResponse(stationName: $stationName, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AqiHistoryResponseImpl &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    stationName,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of AqiHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AqiHistoryResponseImplCopyWith<_$AqiHistoryResponseImpl> get copyWith =>
      __$$AqiHistoryResponseImplCopyWithImpl<_$AqiHistoryResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AqiHistoryResponseImplToJson(this);
  }
}

abstract class _AqiHistoryResponse implements AqiHistoryResponse {
  const factory _AqiHistoryResponse({
    required final String stationName,
    required final List<AqiHistoryItem> data,
  }) = _$AqiHistoryResponseImpl;

  factory _AqiHistoryResponse.fromJson(Map<String, dynamic> json) =
      _$AqiHistoryResponseImpl.fromJson;

  @override
  String get stationName;
  @override
  List<AqiHistoryItem> get data;

  /// Create a copy of AqiHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AqiHistoryResponseImplCopyWith<_$AqiHistoryResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
