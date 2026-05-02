import '../models/device.dart';
import '../models/device_activity.dart';

/// Smart Home Repository
/// 
/// Handles fetching devices and sending commands
class SmartHomeRepository {
  // In-memory state for mock
  List<SmartDevice> _devices = [];

  /// Get all devices for the current user
  Future<List<SmartDevice>> getDevices() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Initialize with mock data if empty
    if (_devices.isEmpty) {
      _devices = DevicesMock.getMockDevices();
    }
    
    return _devices;
  }

  /// Toggle device power on/off
  Future<SmartDevice> togglePower(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _devices.indexWhere((d) => d.deviceId == deviceId);
    if (index == -1) {
      throw Exception('Device not found');
    }
    
    final device = _devices[index];
    final updated = device.copyWith(isPowerOn: !device.isPowerOn);
    _devices[index] = updated;
    
    return updated;
  }

  /// Change device mode
  Future<SmartDevice> changeMode(String deviceId, DeviceMode mode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _devices.indexWhere((d) => d.deviceId == deviceId);
    if (index == -1) {
      throw Exception('Device not found');
    }
    
    final device = _devices[index];
    final updated = device.copyWith(mode: mode);
    _devices[index] = updated;
    
    return updated;
  }

  /// Send generic command to device
  Future<bool> sendCommand(String deviceId, String command, dynamic value) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock: Always succeed
    // Debug: print('[SmartHome] Command to $deviceId -> $command=$value');
    return true;
  }

  /// Get device details by ID
  Future<SmartDevice> getDeviceDetails(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final device = _devices.firstWhere(
      (d) => d.deviceId == deviceId,
      orElse: () => throw Exception('Device not found'),
    );
    
    return device;
  }

  /// Add a new device
  Future<SmartDevice> addDevice({
    required String deviceName,
    required String provider,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final newDevice = SmartDevice(
      deviceId: '${provider.toLowerCase()}.new.${DateTime.now().millisecondsSinceEpoch}',
      provider: provider,
      deviceName: deviceName,
      isActive: true,
      filterLife: 100,
      isPowerOn: false,
      mode: DeviceMode.auto,
    );
    _devices.add(newDevice);
    return newDevice;
  }

  /// Rename a device
  Future<SmartDevice> renameDevice(String deviceId, String newName) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _devices.indexWhere((d) => d.deviceId == deviceId);
    if (index == -1) throw Exception('Device not found');

    final updated = _devices[index].copyWith(deviceName: newName);
    _devices[index] = updated;
    return updated;
  }

  /// Get device activity history
  Future<List<DeviceActivity>> getDeviceActivities(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generate mock activities for last 24 hours
    final now = DateTime.now();
    final activities = <DeviceActivity>[
      DeviceActivity(
        id: 'act_1',
        deviceId: deviceId,
        activityType: ActivityType.powerOn,
        description: 'Device powered on',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      DeviceActivity(
        id: 'act_2',
        deviceId: deviceId,
        activityType: ActivityType.modeChange,
        description: 'Mode changed to Auto',
        timestamp: now.subtract(const Duration(hours: 4)),
        metadata: {'previous_mode': 'manual', 'new_mode': 'auto'},
      ),
      DeviceActivity(
        id: 'act_3',
        deviceId: deviceId,
        activityType: ActivityType.statusUpdate,
        description: 'Filter life: 85% remaining',
        timestamp: now.subtract(const Duration(hours: 8)),
        metadata: {'filter_life': 85},
      ),
      DeviceActivity(
        id: 'act_4',
        deviceId: deviceId,
        activityType: ActivityType.powerOff,
        description: 'Device powered off',
        timestamp: now.subtract(const Duration(hours: 12)),
      ),
      DeviceActivity(
        id: 'act_5',
        deviceId: deviceId,
        activityType: ActivityType.powerOn,
        description: 'Device powered on',
        timestamp: now.subtract(const Duration(hours: 18)),
      ),
      DeviceActivity(
        id: 'act_6',
        deviceId: deviceId,
        activityType: ActivityType.modeChange,
        description: 'Mode changed to Turbo',
        timestamp: now.subtract(const Duration(hours: 20)),
        metadata: {'previous_mode': 'auto', 'new_mode': 'turbo'},
      ),
    ];
    
    return activities;
  }
}
