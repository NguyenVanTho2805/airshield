import 'package:equatable/equatable.dart';

/// Smart Device Model
/// 
/// Represents an IoT device like Air Purifier
class SmartDevice extends Equatable {
  final String deviceId;
  final String provider;
  final String deviceName;
  final bool isActive;
  final int filterLife;
  final bool isPowerOn;
  final DeviceMode mode;

  const SmartDevice({
    required this.deviceId,
    required this.provider,
    required this.deviceName,
    this.isActive = true,
    this.filterLife = 100,
    this.isPowerOn = false,
    this.mode = DeviceMode.auto,
  });

  /// Get provider display name
  String get providerDisplayName {
    switch (provider.toLowerCase()) {
      case 'xiaomi':
        return 'Xiaomi';
      case 'samsung':
        return 'Samsung';
      case 'philips':
        return 'Philips';
      case 'dyson':
        return 'Dyson';
      default:
        return provider;
    }
  }

  /// Get filter status text
  String get filterStatus {
    if (filterLife >= 70) return 'Good';
    if (filterLife >= 30) return 'Fair';
    return 'Replace Soon';
  }

  /// Get filter status color hex
  String get filterStatusColor {
    if (filterLife >= 70) return '#4CAF50';
    if (filterLife >= 30) return '#FF9800';
    return '#F44336';
  }

  SmartDevice copyWith({
    String? deviceId,
    String? provider,
    String? deviceName,
    bool? isActive,
    int? filterLife,
    bool? isPowerOn,
    DeviceMode? mode,
  }) {
    return SmartDevice(
      deviceId: deviceId ?? this.deviceId,
      provider: provider ?? this.provider,
      deviceName: deviceName ?? this.deviceName,
      isActive: isActive ?? this.isActive,
      filterLife: filterLife ?? this.filterLife,
      isPowerOn: isPowerOn ?? this.isPowerOn,
      mode: mode ?? this.mode,
    );
  }

  factory SmartDevice.fromJson(Map<String, dynamic> json) {
    return SmartDevice(
      deviceId: json['device_id'] as String,
      provider: json['provider'] as String,
      deviceName: json['device_name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      filterLife: json['current_filter_life'] as int? ?? 100,
      isPowerOn: json['is_power_on'] as bool? ?? false,
      mode: DeviceMode.fromString(json['mode'] as String? ?? 'auto'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'provider': provider,
      'device_name': deviceName,
      'is_active': isActive,
      'current_filter_life': filterLife,
      'is_power_on': isPowerOn,
      'mode': mode.name,
    };
  }

  @override
  List<Object?> get props => [deviceId, provider, deviceName, isActive, filterLife, isPowerOn, mode];
}

enum DeviceMode {
  auto,
  turbo,
  sleep,
  manual;

  String getDisplayName() {
    switch (this) {
      case DeviceMode.auto:
        return 'Auto';
      case DeviceMode.turbo:
        return 'Turbo';
      case DeviceMode.sleep:
        return 'Sleep';
      case DeviceMode.manual:
        return 'Manual';
    }
  }

  String get icon {
    switch (this) {
      case DeviceMode.auto:
        return '🔄';
      case DeviceMode.turbo:
        return '💨';
      case DeviceMode.sleep:
        return '🌙';
      case DeviceMode.manual:
        return '⚙️';
    }
  }

  static DeviceMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'turbo':
        return DeviceMode.turbo;
      case 'sleep':
        return DeviceMode.sleep;
      case 'manual':
        return DeviceMode.manual;
      default:
        return DeviceMode.auto;
    }
  }
}

/// Mock data for devices
class DevicesMock {
  static List<SmartDevice> getMockDevices() {
    return [
      const SmartDevice(
        deviceId: 'xiaomi.air.p3.living',
        provider: 'xiaomi',
        deviceName: 'Air Purifier - Living Room',
        isActive: true,
        filterLife: 85,
        isPowerOn: true,
        mode: DeviceMode.auto,
      ),
      const SmartDevice(
        deviceId: 'samsung.air.ax60.bedroom',
        provider: 'samsung',
        deviceName: 'Air Purifier - Bedroom',
        isActive: true,
        filterLife: 62,
        isPowerOn: false,
        mode: DeviceMode.sleep,
      ),
    ];
  }
}
