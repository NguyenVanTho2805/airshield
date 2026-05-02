import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_data.freezed.dart';
part 'dashboard_data.g.dart';

/// Dashboard Data Model
/// 
/// Contains all air quality information displayed on the dashboard
@freezed
class DashboardData with _$DashboardData {
  const factory DashboardData({
    required int aqi,
    required String aqiStatus,
    required String aqiColor,
    required List<Pollutant> pollutants,
    required String healthRecommendation,
    required String location,
    required DateTime lastUpdated,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}

/// Pollutant Model
/// 
/// Represents individual pollutant measurements (PM2.5, PM10, CO, NO2, etc.)
@freezed
class Pollutant with _$Pollutant {
  const factory Pollutant({
    required String name,
    required double value,
    required String unit,
    required String status, // good, moderate, unhealthy, etc.
  }) = _Pollutant;

  factory Pollutant.fromJson(Map<String, dynamic> json) =>
      _$PollutantFromJson(json);
}

/// AQI Status Helper
/// 
/// Maps AQI values to status labels and colors
class AqiStatusHelper {
  static const Map<String, Map<String, dynamic>> aqiLevels = {
    'good': {
      'min': 0,
      'max': 50,
      'label': 'Good',
      'color': '#4CAF50',
      'emoji': '🌿',
      'recommendation': 'Air quality is good. Perfect for outdoor activities!',
    },
    'moderate': {
      'min': 51,
      'max': 100,
      'label': 'Moderate',
      'color': '#FFEB3B',
      'emoji': '😐',
      'recommendation': 'Air quality is acceptable. Sensitive individuals should limit prolonged outdoor exertion.',
    },
    'unhealthy_sensitive': {
      'min': 101,
      'max': 150,
      'label': 'Unhealthy for Sensitive Groups',
      'color': '#FF9800',
      'emoji': '😷',
      'recommendation': 'Sensitive groups should reduce outdoor activities. Consider using air purifier indoors.',
    },
    'unhealthy': {
      'min': 151,
      'max': 200,
      'label': 'Unhealthy',
      'color': '#F44336',
      'emoji': '🚫',
      'recommendation': 'Everyone should reduce outdoor activities. Keep windows closed and use air purifier.',
    },
    'very_unhealthy': {
      'min': 201,
      'max': 300,
      'label': 'Very Unhealthy',
      'color': '#9C27B0',
      'emoji': '⚠️',
      'recommendation': 'Health alert! Avoid outdoor activities. Use air purifier and wear mask if going outside.',
    },
    'hazardous': {
      'min': 301,
      'max': 500,
      'label': 'Hazardous',
      'color': '#7B1FA2',
      'emoji': '☠️',
      'recommendation': 'Emergency conditions! Stay indoors with air purifier on maximum. Avoid all outdoor activities.',
    },
  };

  static Map<String, dynamic> getStatusForAqi(int aqi) {
    for (final entry in aqiLevels.entries) {
      final level = entry.value;
      if (aqi >= level['min'] && aqi <= level['max']) {
        return level;
      }
    }
    return aqiLevels['hazardous']!;
  }

  static String getStatusLabel(int aqi) {
    return getStatusForAqi(aqi)['label'] as String;
  }

  static String getStatusColor(int aqi) {
    return getStatusForAqi(aqi)['color'] as String;
  }

  static String getEmoji(int aqi) {
    return getStatusForAqi(aqi)['emoji'] as String;
  }

  static String getRecommendation(int aqi) {
    return getStatusForAqi(aqi)['recommendation'] as String;
  }
}
