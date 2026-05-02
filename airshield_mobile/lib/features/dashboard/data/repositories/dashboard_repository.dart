import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/location_service.dart';
import '../models/dashboard_data.dart';
import '../models/aqi_data_point.dart';
import '../models/aqi_forecast.dart';

/// Dashboard Repository Interface
/// 
/// Abstract contract for dashboard data operations
abstract class IDashboardRepository {
  Future<DashboardData> getDashboardData();
  Future<List<Pollutant>> getPollutants();
  Future<int> getCurrentAqi();
  Future<AqiForecastResponse> getAqiForecast();
}

/// Dashboard Repository Implementation
/// 
/// Handles API calls for dashboard/AQI data
class DashboardRepository implements IDashboardRepository {
  final ApiClient? _apiClient;
  final bool _useMockData;
  final LocationService _locationService;

  /// Constructor với ApiClient thật
  DashboardRepository({ApiClient? apiClient, LocationService? locationService})
      : _apiClient = apiClient,
        _useMockData = apiClient == null,
        _locationService = locationService ?? LocationService();

  /// Factory constructor để sử dụng mock data (cho demo/testing)
  factory DashboardRepository.mock() {
    return DashboardRepository();
  }

  @override
  Future<DashboardData> getDashboardData() async {
    // Nếu không có ApiClient, trả về mock data
    if (_useMockData) {
      return getMockData();
    }
    
    try {
      final loc = await _locationService.getCurrentLocation();
      final response = await _apiClient!.dio.get(
        '/api/v1/air-quality/current',
        queryParameters: {
          'latitude': loc.latitude,
          'longitude': loc.longitude,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Parse response from air-quality endpoint
        final aqi = data['aqi'] as int;
        final statusInfo = AqiStatusHelper.getStatusForAqi(aqi);
        
        // Create pollutants from available data
        final pollutants = <Pollutant>[
          Pollutant(
            name: 'PM2.5',
            value: (data['pm25'] as num?)?.toDouble() ?? 0.0,
            unit: 'μg/m³',
            status: aqi <= 50 ? 'good' : (aqi <= 100 ? 'moderate' : 'unhealthy'),
          ),
        ];
        
        return DashboardData(
          aqi: aqi,
          aqiStatus: statusInfo['label'] as String,
          aqiColor: statusInfo['color'] as String,
          pollutants: pollutants,
          healthRecommendation: statusInfo['recommendation'] as String,
          location: data['station_name'] ?? 'Unknown',
          lastUpdated: DateTime.tryParse(data['recorded_at'] ?? '') ?? DateTime.now(),
        );
      } else {
        throw Exception('Failed to fetch dashboard data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<Pollutant>> getPollutants() async {
    if (_useMockData) {
      return getMockData().pollutants;
    }
    
    try {
      final loc = await _locationService.getCurrentLocation();
      final response = await _apiClient!.dio.get(
        '/api/v1/air-quality/current',
        queryParameters: {
          'latitude': loc.latitude,
          'longitude': loc.longitude,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((p) => Pollutant.fromJson(p)).toList();
      } else {
        throw Exception('Failed to fetch pollutants: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<int> getCurrentAqi() async {
    if (_useMockData) {
      return getMockData().aqi;
    }
    
    try {
      final loc = await _locationService.getCurrentLocation();
      final response = await _apiClient!.dio.get(
        '/api/v1/air-quality/current',
        queryParameters: {
          'latitude': loc.latitude,
          'longitude': loc.longitude,
        },
      );

      if (response.statusCode == 200) {
        return response.data['aqi'] as int;
      } else {
        throw Exception('Failed to fetch AQI: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<AqiForecastResponse> getAqiForecast() async {
    if (_useMockData) {
      return AqiForecastMock.getMockForecast();
    }
    
    try {
      final loc = await _locationService.getCurrentLocation();
      final response = await _apiClient!.dio.get(
        '/api/v1/air-quality/forecast',
        queryParameters: {
          'latitude': loc.latitude,
          'longitude': loc.longitude,
        },
      );
      
      if (response.statusCode == 200) {
        return AqiForecastResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch forecast: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get mock data for testing/demo purposes
  static DashboardData getMockData() {
    return DashboardData(
      aqi: 42,
      aqiStatus: 'Good',
      aqiColor: '#4CAF50',
      pollutants: [
        const Pollutant(name: 'PM2.5', value: 12.0, unit: 'μg/m³', status: 'good'),
        const Pollutant(name: 'PM10', value: 25.0, unit: 'μg/m³', status: 'good'),
        const Pollutant(name: 'CO', value: 0.5, unit: 'ppm', status: 'good'),
        const Pollutant(name: 'NO₂', value: 15.0, unit: 'ppb', status: 'moderate'),
      ],
      healthRecommendation: 'Air quality is good. Perfect for outdoor activities!',
      location: 'Hanoi, Vietnam',
      lastUpdated: DateTime.now(),
    );
  }

  /// Get AQI history for a time range
  Future<List<AQIDataPoint>> getAQIHistory(TimeRange timeRange) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate mock historical data
    final now = DateTime.now();
    final List<AQIDataPoint> dataPoints = [];
    final int numPoints;
    final Duration interval;

    switch (timeRange) {
      case TimeRange.today:
        numPoints = 24; // Hourly for 24 hours
        interval = const Duration(hours: 1);
        break;
      case TimeRange.week:
        numPoints = 7; // Daily for 7 days
        interval = const Duration(days: 1);
        break;
      case TimeRange.month:
        numPoints = 30; // Daily for 30 days
        interval = const Duration(days: 1);
        break;
    }

    // Generate realistic fluctuating AQI data
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    double baseAQI = 35.0 + (random % 40); // Base between 35-75

    for (int i = numPoints - 1; i >= 0; i--) {
      final timestamp = now.subtract(interval * i);

      // Add some realistic variation
      final variation = (i % 5) * 5 - 10; // -10 to +10
      final timeOfDayFactor = timeRange == TimeRange.today
          ? _getTimeOfDayFactor(timestamp.hour)
          : 0.0;

      final aqi = (baseAQI + variation + timeOfDayFactor).clamp(10, 200).toInt();
      final status = _getAQIStatus(aqi);

      // Pollutant values correlate with AQI
      final pm25 = (aqi * 0.5).clamp(5, 150).toDouble();
      final pm10 = (aqi * 0.8).clamp(10, 250).toDouble();

      dataPoints.add(AQIDataPoint(
        timestamp: timestamp,
        aqi: aqi,
        pm25: pm25,
        pm10: pm10,
        o3: (aqi * 0.3).clamp(0, 100).toDouble(),
        no2: (aqi * 0.2).clamp(0, 80).toDouble(),
        so2: (aqi * 0.15).clamp(0, 60).toDouble(),
        co: (aqi * 0.01).clamp(0, 5).toDouble(),
        status: status,
      ));
    }

    return dataPoints;
  }

  /// Get time of day factor for realistic AQI variation
  double _getTimeOfDayFactor(int hour) {
    // Higher AQI in morning rush hour (7-9) and evening (17-19)
    if ((hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19)) {
      return 15.0;
    }
    // Lower at night
    if (hour >= 0 && hour <= 5) {
      return -10.0;
    }
    return 0.0;
  }

  /// Get AQI status string
  String _getAQIStatus(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
}
