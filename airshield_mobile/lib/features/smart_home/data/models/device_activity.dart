/// Device Activity Model
/// 
/// Represents an activity log entry for a smart device
class DeviceActivity {
  final String id;
  final String deviceId;
  final ActivityType activityType;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const DeviceActivity({
    required this.id,
    required this.deviceId,
    required this.activityType,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  /// Create from JSON
  factory DeviceActivity.fromJson(Map<String, dynamic> json) {
    return DeviceActivity(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      activityType: ActivityType.fromString(json['activity_type'] as String),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'activity_type': activityType.name,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Copy with
  DeviceActivity copyWith({
    String? id,
    String? deviceId,
    ActivityType? activityType,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return DeviceActivity(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      activityType: activityType ?? this.activityType,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Activity Type Enum
enum ActivityType {
  powerOn,
  powerOff,
  modeChange,
  filterReplacement,
  maintenance,
  alert,
  statusUpdate;

  String get displayName {
    switch (this) {
      case ActivityType.powerOn:
        return 'Power On';
      case ActivityType.powerOff:
        return 'Power Off';
      case ActivityType.modeChange:
        return 'Mode Changed';
      case ActivityType.filterReplacement:
        return 'Filter Replaced';
      case ActivityType.maintenance:
        return 'Maintenance';
      case ActivityType.alert:
        return 'Alert';
      case ActivityType.statusUpdate:
        return 'Status Update';
    }
  }

  static ActivityType fromString(String value) {
    switch (value) {
      case 'power_on':
        return ActivityType.powerOn;
      case 'power_off':
        return ActivityType.powerOff;
      case 'mode_change':
        return ActivityType.modeChange;
      case 'filter_replacement':
        return ActivityType.filterReplacement;
      case 'maintenance':
        return ActivityType.maintenance;
      case 'alert':
        return ActivityType.alert;
      case 'status_update':
        return ActivityType.statusUpdate;
      default:
        return ActivityType.statusUpdate;
    }
  }
}
