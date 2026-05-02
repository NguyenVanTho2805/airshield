import 'package:flutter/material.dart';

/// Notification Model
/// 
/// Represents a notification with type, message, and metadata
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  /// Get notification icon
  IconData getIcon() {
    switch (type) {
      case NotificationType.aqiAlert:
        return Icons.warning_amber;
      case NotificationType.deviceStatus:
        return Icons.devices;
      case NotificationType.automation:
        return Icons.auto_awesome;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  /// Get notification color
  Color getColor() {
    switch (type) {
      case NotificationType.aqiAlert:
        return const Color(0xFFF44336);
      case NotificationType.deviceStatus:
        return const Color(0xFF2196F3);
      case NotificationType.automation:
        return const Color(0xFF4CAF50);
      case NotificationType.system:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Create from JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'data': data,
    };
  }

  /// Copy with
  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

/// Notification Type Enum
enum NotificationType {
  aqiAlert,
  deviceStatus,
  automation,
  system;

  String get displayName {
    switch (this) {
      case NotificationType.aqiAlert:
        return 'AQI Alert';
      case NotificationType.deviceStatus:
        return 'Device Status';
      case NotificationType.automation:
        return 'Automation';
      case NotificationType.system:
        return 'System';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'aqi_alert':
        return NotificationType.aqiAlert;
      case 'device_status':
        return NotificationType.deviceStatus;
      case 'automation':
        return NotificationType.automation;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
}
