import 'package:flutter/material.dart';

/// AQI Data Point Model
/// 
/// Represents a single AQI reading at a specific time
class AQIDataPoint {
  final DateTime timestamp;
  final int aqi;
  final double pm25;
  final double pm10;
  final double? o3;
  final double? no2;
  final double? so2;
  final double? co;
  final String status;

  const AQIDataPoint({
    required this.timestamp,
    required this.aqi,
    required this.pm25,
    required this.pm10,
    this.o3,
    this.no2,
    this.so2,
    this.co,
    required this.status,
  });

  /// Get AQI status color
  Color getStatusColor() {
    if (aqi <= 50) return const Color(0xFF4CAF50); // Good
    if (aqi <= 100) return const Color(0xFFFFEB3B); // Moderate
    if (aqi <= 150) return const Color(0xFFFF9800); // Unhealthy for Sensitive
    if (aqi <= 200) return const Color(0xFFF44336); // Unhealthy
    if (aqi <= 300) return const Color(0xFF9C27B0); // Very Unhealthy
    return const Color(0xFF880E4F); // Hazardous
  }

  /// Create from JSON
  factory AQIDataPoint.fromJson(Map<String, dynamic> json) {
    return AQIDataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      aqi: json['aqi'] as int,
      pm25: (json['pm25'] as num).toDouble(),
      pm10: (json['pm10'] as num).toDouble(),
      o3: json['o3'] != null ? (json['o3'] as num).toDouble() : null,
      no2: json['no2'] != null ? (json['no2'] as num).toDouble() : null,
      so2: json['so2'] != null ? (json['so2'] as num).toDouble() : null,
      co: json['co'] != null ? (json['co'] as num).toDouble() : null,
      status: json['status'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'aqi': aqi,
      'pm25': pm25,
      'pm10': pm10,
      'o3': o3,
      'no2': no2,
      'so2': so2,
      'co': co,
      'status': status,
    };
  }

  /// Copy with
  AQIDataPoint copyWith({
    DateTime? timestamp,
    int? aqi,
    double? pm25,
    double? pm10,
    double? o3,
    double? no2,
    double? so2,
    double? co,
    String? status,
  }) {
    return AQIDataPoint(
      timestamp: timestamp ?? this.timestamp,
      aqi: aqi ?? this.aqi,
      pm25: pm25 ?? this.pm25,
      pm10: pm10 ?? this.pm10,
      o3: o3 ?? this.o3,
      no2: no2 ?? this.no2,
      so2: so2 ?? this.so2,
      co: co ?? this.co,
      status: status ?? this.status,
    );
  }
}

/// Time Range for AQI History
enum TimeRange {
  today,
  week,
  month;

  String get displayName {
    switch (this) {
      case TimeRange.today:
        return '24 Hours';
      case TimeRange.week:
        return '7 Days';
      case TimeRange.month:
        return '30 Days';
    }
  }

  Duration get duration {
    switch (this) {
      case TimeRange.today:
        return const Duration(days: 1);
      case TimeRange.week:
        return const Duration(days: 7);
      case TimeRange.month:
        return const Duration(days: 30);
    }
  }
}
