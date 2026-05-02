// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aqi_forecast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AqiForecastItemImpl _$$AqiForecastItemImplFromJson(
  Map<String, dynamic> json,
) => _$AqiForecastItemImpl(
  aqi: (json['aqi'] as num).toInt(),
  recordedAt: DateTime.parse(json['recordedAt'] as String),
  isForecast: json['isForecast'] as bool? ?? true,
);

Map<String, dynamic> _$$AqiForecastItemImplToJson(
  _$AqiForecastItemImpl instance,
) => <String, dynamic>{
  'aqi': instance.aqi,
  'recordedAt': instance.recordedAt.toIso8601String(),
  'isForecast': instance.isForecast,
};

_$AqiForecastResponseImpl _$$AqiForecastResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AqiForecastResponseImpl(
  data: (json['data'] as List<dynamic>)
      .map((e) => AqiForecastItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$AqiForecastResponseImplToJson(
  _$AqiForecastResponseImpl instance,
) => <String, dynamic>{'data': instance.data};
