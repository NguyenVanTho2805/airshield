import 'package:freezed_annotation/freezed_annotation.dart';

part 'aqi_history.freezed.dart';
part 'aqi_history.g.dart';

/// AQI History Item
/// 
/// Represents a single data point in AQI history (hourly reading)
@freezed
class AqiHistoryItem with _$AqiHistoryItem {
  const factory AqiHistoryItem({
    required int aqi,
    double? pm25,
    required DateTime recordedAt,
  }) = _AqiHistoryItem;

  factory AqiHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$AqiHistoryItemFromJson(json);
}

/// AQI History Response
/// 
/// Contains 24h history data from a station
@freezed
class AqiHistoryResponse with _$AqiHistoryResponse {
  const factory AqiHistoryResponse({
    required String stationName,
    required List<AqiHistoryItem> data,
  }) = _AqiHistoryResponse;

  factory AqiHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$AqiHistoryResponseFromJson(json);
}

/// Mock data generator for AQI history
class AqiHistoryMock {
  /// Generate 24 hours of mock AQI data
  static AqiHistoryResponse getMockHistory() {
    final now = DateTime.now();
    final data = <AqiHistoryItem>[];
    
    // Generate 24 data points (1 per hour)
    for (int i = 23; i >= 0; i--) {
      // Create realistic AQI fluctuation
      // Morning: lower (30-50), Afternoon: higher (50-80), Evening: moderate (40-60)
      int baseAqi;
      final hour = (now.hour - i) % 24;
      
      if (hour >= 6 && hour < 10) {
        baseAqi = 35 + (hour * 3); // Morning rush
      } else if (hour >= 10 && hour < 16) {
        baseAqi = 55 + ((hour - 10) * 4); // Afternoon peak
      } else if (hour >= 16 && hour < 20) {
        baseAqi = 70 - ((hour - 16) * 5); // Evening decline
      } else {
        baseAqi = 40; // Night baseline
      }
      
      // Add some randomness (±10)
      final variance = (i % 7) - 3;
      final aqi = (baseAqi + variance).clamp(25, 100);
      
      data.add(AqiHistoryItem(
        aqi: aqi,
        pm25: aqi * 0.4, // Approximate PM2.5
        recordedAt: now.subtract(Duration(hours: i)),
      ));
    }
    
    return AqiHistoryResponse(
      stationName: 'Hanoi, Vietnam',
      data: data,
    );
  }
}
