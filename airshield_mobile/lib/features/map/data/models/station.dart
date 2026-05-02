import 'package:freezed_annotation/freezed_annotation.dart';

part 'station.freezed.dart';
part 'station.g.dart';

/// Air Quality Station Model
/// 
/// Represents a monitoring station with location and current AQI
@freezed
class AqiStation with _$AqiStation {
  const AqiStation._();
  
  const factory AqiStation({
    required int id,
    required String name,
    required double latitude,
    required double longitude,
    required int aqi,
    String? source,
    bool? isActive,
  }) = _AqiStation;

  factory AqiStation.fromJson(Map<String, dynamic> json) =>
      _$AqiStationFromJson(json);

  /// Get AQI status text
  String get aqiStatus {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  /// Get AQI color hex
  String get aqiColor {
    if (aqi <= 50) return '#4CAF50';
    if (aqi <= 100) return '#FFEB3B';
    if (aqi <= 150) return '#FF9800';
    if (aqi <= 200) return '#F44336';
    if (aqi <= 300) return '#9C27B0';
    return '#7B1FA2';
  }
}

/// Mock data for stations
class StationsMock {
  static List<AqiStation> getMockStations() {
    return [
      const AqiStation(
        id: 1,
        name: 'Hanoi - Hoan Kiem',
        latitude: 21.0285,
        longitude: 105.8542,
        aqi: 42,
        source: 'iqair',
      ),
      const AqiStation(
        id: 2,
        name: 'Hanoi - Cau Giay',
        latitude: 21.0356,
        longitude: 105.7948,
        aqi: 58,
        source: 'iqair',
      ),
      const AqiStation(
        id: 3,
        name: 'Ho Chi Minh City',
        latitude: 10.7769,
        longitude: 106.7009,
        aqi: 75,
        source: 'iqair',
      ),
      const AqiStation(
        id: 4,
        name: 'Da Nang',
        latitude: 16.0544,
        longitude: 108.2022,
        aqi: 35,
        source: 'pamair',
      ),
    ];
  }
}
