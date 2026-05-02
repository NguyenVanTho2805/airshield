// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AqiStationImpl _$$AqiStationImplFromJson(Map<String, dynamic> json) =>
    _$AqiStationImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      aqi: (json['aqi'] as num).toInt(),
      source: json['source'] as String?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$$AqiStationImplToJson(_$AqiStationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'aqi': instance.aqi,
      'source': instance.source,
      'isActive': instance.isActive,
    };
