// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aqi_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AqiHistoryItemImpl _$$AqiHistoryItemImplFromJson(Map<String, dynamic> json) =>
    _$AqiHistoryItemImpl(
      aqi: (json['aqi'] as num).toInt(),
      pm25: (json['pm25'] as num?)?.toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );

Map<String, dynamic> _$$AqiHistoryItemImplToJson(
  _$AqiHistoryItemImpl instance,
) => <String, dynamic>{
  'aqi': instance.aqi,
  'pm25': instance.pm25,
  'recordedAt': instance.recordedAt.toIso8601String(),
};

_$AqiHistoryResponseImpl _$$AqiHistoryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AqiHistoryResponseImpl(
  stationName: json['stationName'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => AqiHistoryItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$AqiHistoryResponseImplToJson(
  _$AqiHistoryResponseImpl instance,
) => <String, dynamic>{
  'stationName': instance.stationName,
  'data': instance.data,
};
