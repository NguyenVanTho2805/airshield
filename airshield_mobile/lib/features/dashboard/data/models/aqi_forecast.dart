import 'package:freezed_annotation/freezed_annotation.dart';

part 'aqi_forecast.freezed.dart';
part 'aqi_forecast.g.dart';

@freezed
class AqiForecastItem with _$AqiForecastItem {
  const factory AqiForecastItem({
    required int aqi,
    required DateTime recordedAt,
    @Default(true) bool isForecast,
  }) = _AqiForecastItem;

  factory AqiForecastItem.fromJson(Map<String, dynamic> json) =>
      _$AqiForecastItemFromJson(json);
}

@freezed
class AqiForecastResponse with _$AqiForecastResponse {
  const factory AqiForecastResponse({
    required List<AqiForecastItem> data,
  }) = _AqiForecastResponse;

  factory AqiForecastResponse.fromJson(Map<String, dynamic> json) =>
      _$AqiForecastResponseFromJson(json);
}

class AqiForecastMock {
  static AqiForecastResponse getMockForecast() {
    final now = DateTime.now();
    final data = <AqiForecastItem>[];
    
    // Generate 24 data points (1 per hour) for the next 24h
    for (int i = 1; i <= 24; i++) {
        // Mock some values
      int baseAqi = 40;
      final hour = (now.hour + i) % 24;
      if (hour >= 6 && hour < 10) {
        baseAqi = 40 + (hour * 2);
      } else if (hour >= 10 && hour < 16) {
        baseAqi = 50 + ((hour - 10) * 3);
      } else {
        baseAqi = 45;
      }
      
      data.add(AqiForecastItem(
        aqi: baseAqi,
        recordedAt: now.add(Duration(hours: i)),
      ));
    }
    
    return AqiForecastResponse(
      data: data,
    );
  }
}
