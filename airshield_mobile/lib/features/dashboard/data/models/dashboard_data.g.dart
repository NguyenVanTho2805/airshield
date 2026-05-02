// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardDataImpl _$$DashboardDataImplFromJson(Map<String, dynamic> json) =>
    _$DashboardDataImpl(
      aqi: (json['aqi'] as num).toInt(),
      aqiStatus: json['aqiStatus'] as String,
      aqiColor: json['aqiColor'] as String,
      pollutants: (json['pollutants'] as List<dynamic>)
          .map((e) => Pollutant.fromJson(e as Map<String, dynamic>))
          .toList(),
      healthRecommendation: json['healthRecommendation'] as String,
      location: json['location'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$DashboardDataImplToJson(_$DashboardDataImpl instance) =>
    <String, dynamic>{
      'aqi': instance.aqi,
      'aqiStatus': instance.aqiStatus,
      'aqiColor': instance.aqiColor,
      'pollutants': instance.pollutants,
      'healthRecommendation': instance.healthRecommendation,
      'location': instance.location,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

_$PollutantImpl _$$PollutantImplFromJson(Map<String, dynamic> json) =>
    _$PollutantImpl(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$$PollutantImplToJson(_$PollutantImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'unit': instance.unit,
      'status': instance.status,
    };
