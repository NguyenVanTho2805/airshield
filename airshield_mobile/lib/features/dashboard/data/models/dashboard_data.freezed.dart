// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) {
  return _DashboardData.fromJson(json);
}

/// @nodoc
mixin _$DashboardData {
  int get aqi => throw _privateConstructorUsedError;
  String get aqiStatus => throw _privateConstructorUsedError;
  String get aqiColor => throw _privateConstructorUsedError;
  List<Pollutant> get pollutants => throw _privateConstructorUsedError;
  String get healthRecommendation => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this DashboardData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardDataCopyWith<DashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardDataCopyWith<$Res> {
  factory $DashboardDataCopyWith(
    DashboardData value,
    $Res Function(DashboardData) then,
  ) = _$DashboardDataCopyWithImpl<$Res, DashboardData>;
  @useResult
  $Res call({
    int aqi,
    String aqiStatus,
    String aqiColor,
    List<Pollutant> pollutants,
    String healthRecommendation,
    String location,
    DateTime lastUpdated,
  });
}

/// @nodoc
class _$DashboardDataCopyWithImpl<$Res, $Val extends DashboardData>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aqi = null,
    Object? aqiStatus = null,
    Object? aqiColor = null,
    Object? pollutants = null,
    Object? healthRecommendation = null,
    Object? location = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _value.copyWith(
            aqi: null == aqi
                ? _value.aqi
                : aqi // ignore: cast_nullable_to_non_nullable
                      as int,
            aqiStatus: null == aqiStatus
                ? _value.aqiStatus
                : aqiStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            aqiColor: null == aqiColor
                ? _value.aqiColor
                : aqiColor // ignore: cast_nullable_to_non_nullable
                      as String,
            pollutants: null == pollutants
                ? _value.pollutants
                : pollutants // ignore: cast_nullable_to_non_nullable
                      as List<Pollutant>,
            healthRecommendation: null == healthRecommendation
                ? _value.healthRecommendation
                : healthRecommendation // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardDataImplCopyWith<$Res>
    implements $DashboardDataCopyWith<$Res> {
  factory _$$DashboardDataImplCopyWith(
    _$DashboardDataImpl value,
    $Res Function(_$DashboardDataImpl) then,
  ) = __$$DashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int aqi,
    String aqiStatus,
    String aqiColor,
    List<Pollutant> pollutants,
    String healthRecommendation,
    String location,
    DateTime lastUpdated,
  });
}

/// @nodoc
class __$$DashboardDataImplCopyWithImpl<$Res>
    extends _$DashboardDataCopyWithImpl<$Res, _$DashboardDataImpl>
    implements _$$DashboardDataImplCopyWith<$Res> {
  __$$DashboardDataImplCopyWithImpl(
    _$DashboardDataImpl _value,
    $Res Function(_$DashboardDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aqi = null,
    Object? aqiStatus = null,
    Object? aqiColor = null,
    Object? pollutants = null,
    Object? healthRecommendation = null,
    Object? location = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _$DashboardDataImpl(
        aqi: null == aqi
            ? _value.aqi
            : aqi // ignore: cast_nullable_to_non_nullable
                  as int,
        aqiStatus: null == aqiStatus
            ? _value.aqiStatus
            : aqiStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        aqiColor: null == aqiColor
            ? _value.aqiColor
            : aqiColor // ignore: cast_nullable_to_non_nullable
                  as String,
        pollutants: null == pollutants
            ? _value._pollutants
            : pollutants // ignore: cast_nullable_to_non_nullable
                  as List<Pollutant>,
        healthRecommendation: null == healthRecommendation
            ? _value.healthRecommendation
            : healthRecommendation // ignore: cast_nullable_to_non_nullable
                  as String,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardDataImpl implements _DashboardData {
  const _$DashboardDataImpl({
    required this.aqi,
    required this.aqiStatus,
    required this.aqiColor,
    required final List<Pollutant> pollutants,
    required this.healthRecommendation,
    required this.location,
    required this.lastUpdated,
  }) : _pollutants = pollutants;

  factory _$DashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardDataImplFromJson(json);

  @override
  final int aqi;
  @override
  final String aqiStatus;
  @override
  final String aqiColor;
  final List<Pollutant> _pollutants;
  @override
  List<Pollutant> get pollutants {
    if (_pollutants is EqualUnmodifiableListView) return _pollutants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pollutants);
  }

  @override
  final String healthRecommendation;
  @override
  final String location;
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'DashboardData(aqi: $aqi, aqiStatus: $aqiStatus, aqiColor: $aqiColor, pollutants: $pollutants, healthRecommendation: $healthRecommendation, location: $location, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardDataImpl &&
            (identical(other.aqi, aqi) || other.aqi == aqi) &&
            (identical(other.aqiStatus, aqiStatus) ||
                other.aqiStatus == aqiStatus) &&
            (identical(other.aqiColor, aqiColor) ||
                other.aqiColor == aqiColor) &&
            const DeepCollectionEquality().equals(
              other._pollutants,
              _pollutants,
            ) &&
            (identical(other.healthRecommendation, healthRecommendation) ||
                other.healthRecommendation == healthRecommendation) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    aqi,
    aqiStatus,
    aqiColor,
    const DeepCollectionEquality().hash(_pollutants),
    healthRecommendation,
    location,
    lastUpdated,
  );

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      __$$DashboardDataImplCopyWithImpl<_$DashboardDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardDataImplToJson(this);
  }
}

abstract class _DashboardData implements DashboardData {
  const factory _DashboardData({
    required final int aqi,
    required final String aqiStatus,
    required final String aqiColor,
    required final List<Pollutant> pollutants,
    required final String healthRecommendation,
    required final String location,
    required final DateTime lastUpdated,
  }) = _$DashboardDataImpl;

  factory _DashboardData.fromJson(Map<String, dynamic> json) =
      _$DashboardDataImpl.fromJson;

  @override
  int get aqi;
  @override
  String get aqiStatus;
  @override
  String get aqiColor;
  @override
  List<Pollutant> get pollutants;
  @override
  String get healthRecommendation;
  @override
  String get location;
  @override
  DateTime get lastUpdated;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Pollutant _$PollutantFromJson(Map<String, dynamic> json) {
  return _Pollutant.fromJson(json);
}

/// @nodoc
mixin _$Pollutant {
  String get name => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this Pollutant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Pollutant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PollutantCopyWith<Pollutant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PollutantCopyWith<$Res> {
  factory $PollutantCopyWith(Pollutant value, $Res Function(Pollutant) then) =
      _$PollutantCopyWithImpl<$Res, Pollutant>;
  @useResult
  $Res call({String name, double value, String unit, String status});
}

/// @nodoc
class _$PollutantCopyWithImpl<$Res, $Val extends Pollutant>
    implements $PollutantCopyWith<$Res> {
  _$PollutantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Pollutant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? value = null,
    Object? unit = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PollutantImplCopyWith<$Res>
    implements $PollutantCopyWith<$Res> {
  factory _$$PollutantImplCopyWith(
    _$PollutantImpl value,
    $Res Function(_$PollutantImpl) then,
  ) = __$$PollutantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double value, String unit, String status});
}

/// @nodoc
class __$$PollutantImplCopyWithImpl<$Res>
    extends _$PollutantCopyWithImpl<$Res, _$PollutantImpl>
    implements _$$PollutantImplCopyWith<$Res> {
  __$$PollutantImplCopyWithImpl(
    _$PollutantImpl _value,
    $Res Function(_$PollutantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Pollutant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? value = null,
    Object? unit = null,
    Object? status = null,
  }) {
    return _then(
      _$PollutantImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PollutantImpl implements _Pollutant {
  const _$PollutantImpl({
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
  });

  factory _$PollutantImpl.fromJson(Map<String, dynamic> json) =>
      _$$PollutantImplFromJson(json);

  @override
  final String name;
  @override
  final double value;
  @override
  final String unit;
  @override
  final String status;

  @override
  String toString() {
    return 'Pollutant(name: $name, value: $value, unit: $unit, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PollutantImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, value, unit, status);

  /// Create a copy of Pollutant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PollutantImplCopyWith<_$PollutantImpl> get copyWith =>
      __$$PollutantImplCopyWithImpl<_$PollutantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PollutantImplToJson(this);
  }
}

abstract class _Pollutant implements Pollutant {
  const factory _Pollutant({
    required final String name,
    required final double value,
    required final String unit,
    required final String status,
  }) = _$PollutantImpl;

  factory _Pollutant.fromJson(Map<String, dynamic> json) =
      _$PollutantImpl.fromJson;

  @override
  String get name;
  @override
  double get value;
  @override
  String get unit;
  @override
  String get status;

  /// Create a copy of Pollutant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PollutantImplCopyWith<_$PollutantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
