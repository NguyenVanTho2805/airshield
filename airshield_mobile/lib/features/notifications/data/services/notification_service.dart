import '../models/notification.dart';

/// Notification Service
/// 
/// Mock service for managing notifications (simulates Firebase/local notifications)
class NotificationService {
  final List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  /// Get all notifications
  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Initialize with mock notifications if empty
    if (_notifications.isEmpty) {
      _initializeMockNotifications();
    }
    
    return List.from(_notifications);
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _unreadCount;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _unreadCount = 0;
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => _notifications.first,
    );
    
    if (!notification.isRead) {
      _unreadCount--;
    }
    
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _notifications.clear();
    _unreadCount = 0;
  }

  /// Simulate new notification (for testing)
  Future<AppNotification> simulateNotification(NotificationType type) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final notification = _createMockNotification(type);
    _notifications.insert(0, notification);
    _unreadCount++;
    
    return notification;
  }

  /// Initialize mock notifications
  void _initializeMockNotifications() {
    final now = DateTime.now();
    
    _notifications.addAll([
      AppNotification(
        id: '1',
        type: NotificationType.aqiAlert,
        title: 'High AQI Alert',
        message: 'Air quality has reached unhealthy levels (AQI: 152). Consider using your air purifier.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        data: {'aqi': 152},
      ),
      AppNotification(
        id: '2',
        type: NotificationType.automation,
        title: 'Automation Triggered',
        message: 'Rule "High AQI Alert" triggered. Living Room Purifier turned on.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
        data: {'rule_id': '1', 'device_id': 'device-1'},
      ),
      AppNotification(
        id: '3',
        type: NotificationType.deviceStatus,
        title: 'Device Connected',
        message: 'Living Room Air Purifier has connected successfully.',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        data: {'device_id': 'device-1'},
      ),
      AppNotification(
        id: '4',
        type: NotificationType.system,
        title: 'Welcome to AirShield',
        message: 'Thank you for using AirShield. Monitor your air quality and control your devices from anywhere.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: '5',
        type: NotificationType.aqiAlert,
        title: 'Good Air Quality',
        message: 'Air quality is good (AQI: 42). Perfect for outdoor activities!',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        data: {'aqi': 42},
      ),
    ]);
    
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  /// Create mock notification for simulation
  AppNotification _createMockNotification(NotificationType type) {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();
    
    switch (type) {
      case NotificationType.aqiAlert:
        return AppNotification(
          id: id,
          type: type,
          title: 'AQI Alert',
          message: 'Air quality has changed. Current AQI: 125',
          timestamp: now,
          data: {'aqi': 125},
        );
      case NotificationType.deviceStatus:
        return AppNotification(
          id: id,
          type: type,
          title: 'Device Update',
          message: 'Your device status has changed.',
          timestamp: now,
          data: {'device_id': 'device-1'},
        );
      case NotificationType.automation:
        return AppNotification(
          id: id,
          type: type,
          title: 'Automation Executed',
          message: 'An automation rule was triggered.',
          timestamp: now,
          data: {'rule_id': '1'},
        );
      case NotificationType.system:
        return AppNotification(
          id: id,
          type: type,
          title: 'System Notification',
          message: 'You have a new system update.',
          timestamp: now,
        );
    }
  }
}
