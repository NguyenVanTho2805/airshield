import 'package:flutter/material.dart';

/// App Localizations
/// 
/// Simple localization for English and Vietnamese
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'app_name': 'AirShield',
      'cancel': 'Cancel',
      'save': 'Save',
      'close': 'Close',
      'retry': 'Retry',
      'loading': 'Loading...',
      
      // Navigation
      'home': 'Home',
      'map': 'Map',
      'devices': 'Devices',
      'profile': 'Profile',
      
      // Dashboard
      'air_quality_index': 'Air Quality Index',
      'pollutants': 'Pollutants',
      'health_recommendation': 'Health Recommendation',
      'quick_actions': 'Quick Actions',
      'air_purifier': 'Air Purifier',
      'aqi_map': 'AQI Map',
      
      // Map
      'aqi_map_title': 'AQI Map',
      
      // Smart Home
      'smart_devices': 'Smart Devices',
      'power_on_to_select_mode': 'Power on to select mode',
      'filter_life': 'Filter Life',
      
      // Profile
      'profile': 'Profile',
      'settings': 'Settings',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'help_support': 'Help & Support',
      'logout': 'Logout',
      'premium_member': 'Premium Member',
      'member_since': 'Member Since',
      
      // Settings
      'notifications': 'Notifications',
      'enable_notifications': 'Enable Notifications',
      'receive_alerts_updates': 'Receive alerts and updates',
      'aqi_alerts': 'AQI Alerts',
      'notify_aqi_changes': 'Notify when air quality changes',
      'device_alerts': 'Device Alerts',
      'notify_devices_attention': 'Notify when devices need attention',
      'appearance': 'Appearance',
      'theme': 'Theme',
      'dark': 'Dark',
      'light': 'Light',
      'system': 'System',
      'general': 'General',
      'language': 'Language',
      'english': 'English',
      'vietnamese': 'Vietnamese',
      'app_version': 'App Version',
      'select_theme': 'Select Theme',
      'select_language': 'Select Language',
      
      // Notifications
      'no_notifications': 'No notifications',
      'no_notifications_message': 'You\'re all caught up!',
      'mark_as_read': 'Mark as read',
      'mark_all_as_read': 'Mark all as read',
      'clear_all': 'Clear all',
      'delete': 'Delete',
      'simulate_notification': 'Simulate Notification',
      'select_notification_type': 'Select notification type to simulate',
      'simulate': 'Simulate',
      'confirm_clear_all': 'Clear all notifications?',
      'confirm_clear_all_message': 'This will permanently delete all notifications.',
      
      // Notification Types
      'aqi_alert': 'AQI Alert',
      'device_status': 'Device Status',
      'automation': 'Automation',
      'system': 'System',
      'filter_reminder': 'Filter Reminder',
      
      // Profile Management
      'edit_profile': 'Edit Profile',
      'update_your_information': 'Update your information',
      'health_preferences': 'Health Preferences',
      'manage_health_conditions': 'Manage health conditions',
      'saved_locations': 'Saved Locations',
      'manage_your_locations': 'Manage your locations',
      'choose_avatar': 'Choose Avatar',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'profile_updated_successfully': 'Profile updated successfully',
      'failed_to_pick_image': 'Failed to pick image',
      
      // Health Preferences
      'aqi_sensitivity_level': 'AQI Sensitivity Level',
      'how_sensitive_to_air': 'How sensitive are you to air quality?',
      'custom_alert_threshold': 'Custom Alert Threshold',
      'get_notified_when_aqi_exceeds': 'Get notified when AQI exceeds',
      'save_preferences': 'Save Preferences',
      'low': 'Low',
      'high': 'High',
      
      // Saved Locations
      'no_saved_locations': 'No saved locations',
      'add_favorite_locations_message': 'Add your favorite locations to quickly check AQI',
      'add_location': 'Add Location',
      'set_as_default': 'Set as default',
      'new_location': 'New Location',
      'tap_to_edit': 'Tap to edit',
    },
    'vi': {
      // Common
      'app_name': 'AirShield',
      'cancel': 'Hủy',
      'save': 'Lưu',
      'close': 'Đóng',
      'retry': 'Thử lại',
      'loading': 'Đang tải...',
      
      // Navigation
      'home': 'Trang chủ',
      'map': 'Bản đồ',
      'devices': 'Thiết bị',
      'profile': 'Hồ sơ',
      
      // Dashboard
      'air_quality_index': 'Chỉ số chất lượng không khí',
      'pollutants': 'Chất ô nhiễm',
      'health_recommendation': 'Khuyến nghị sức khỏe',
      'quick_actions': 'Thao tác nhanh',
      'air_purifier': 'Máy lọc không khí',
      'aqi_map': 'Bản đồ AQI',
      
      // Map
      'aqi_map_title': 'Bản đồ AQI',
      
      // Smart Home
      'smart_devices': 'Thiết bị thông minh',
      'power_on_to_select_mode': 'Bật nguồn để chọn chế độ',
      'filter_life': 'Tuổi thọ bộ lọc',
      
      // Profile
      'profile': 'Hồ sơ',
      'settings': 'Cài đặt',
      'about': 'Giới thiệu',
      'privacy_policy': 'Chính sách bảo mật',
      'help_support': 'Trợ giúp & Hỗ trợ',
      'logout': 'Đăng xuất',
      'premium_member': 'Thành viên cao cấp',
      'member_since': 'Thành viên từ',
      
      // Settings
      'notifications': 'Thông báo',
      'enable_notifications': 'Bật thông báo',
      'receive_alerts_updates': 'Nhận cảnh báo và cập nhật',
      'aqi_alerts': 'Cảnh báo AQI',
      'notify_aqi_changes': 'Thông báo khi chất lượng không khí thay đổi',
      'device_alerts': 'Cảnh báo thiết bị',
      'notify_devices_attention': 'Thông báo khi thiết bị cần chú ý',
      'appearance': 'Giao diện',
      'theme': 'Chủ đề',
      'dark': 'Tối',
      'light': 'Sáng',
      'system': 'Hệ thống',
      'general': 'Chung',
      'language': 'Ngôn ngữ',
      'english': 'Tiếng Anh',
      'vietnamese': 'Tiếng Việt',
      'app_version': 'Phiên bản',
      'select_theme': 'Chọn chủ đề',
      'select_language': 'Chọn ngôn ngữ',
      
      // Notifications
      'no_notifications': 'Không có thông báo',
      'no_notifications_message': 'Bạn đã xem hết!',
      'mark_as_read': 'Đánh dấu đã đọc',
      'mark_all_as_read': 'Đánh dấu tất cả đã đọc',
      'clear_all': 'Xóa tất cả',
      'delete': 'Xóa',
      'simulate_notification': 'Mô phỏng Thông báo',
      'select_notification_type': 'Chọn loại thông báo để mô phỏng',
      'simulate': 'Mô phỏng',
      'confirm_clear_all': 'Xóa tất cả thông báo?',
      'confirm_clear_all_message': 'Hành động này sẽ xóa vĩnh viễn tất cả thông báo.',
      
      // Notification Types
      'aqi_alert': 'Cảnh báo AQI',
      'device_status': 'Trạng thái thiết bị',
      'automation': 'Tự động hóa',
      'system': 'Hệ thống',
      'filter_reminder': 'Nhắc thay lọc',
      
      // Profile Management
      'edit_profile': 'Chỉnh sửa hồ sơ',
      'update_your_information': 'Cập nhật thông tin của bạn',
      'health_preferences': 'Tùy chọn sức khỏe',
      'manage_health_conditions': 'Quản lý tình trạng sức khỏe',
      'saved_locations': 'Vị trí đã lưu',
      'manage_your_locations': 'Quản lý vị trí của bạn',
      'choose_avatar': 'Chọn ảnh đại diện',
      'camera': 'Máy ảnh',
      'gallery': 'Thư viện',
      'profile_updated_successfully': 'Cập nhật hồ sơ thành công',
      'failed_to_pick_image': 'Không thể chọn ảnh',
      
      // Health Preferences
      'aqi_sensitivity_level': 'Mức độ nhạy cảm AQI',
      'how_sensitive_to_air': 'Bạn nhạy cảm với chất lượng không khí như thế nào?',
      'custom_alert_threshold': 'Ngưỡng cảnh báo tùy chỉnh',
      'get_notified_when_aqi_exceeds': 'Nhận thông báo khi AQI vượt quá',
      'save_preferences': 'Lưu tùy chọn',
      'low': 'Thấp',
      'high': 'Cao',
      
      // Saved Locations
      'no_saved_locations': 'Chưa có vị trí đã lưu',
      'add_favorite_locations_message': 'Thêm vị trí yêu thích để kiểm tra AQI nhanh chóng',
      'add_location': 'Thêm vị trí',
      'set_as_default': 'Đặt làm mặc định',
      'new_location': 'Vị trí mới',
      'tap_to_edit': 'Nhấn để chỉnh sửa',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Convenience getters
  String get appName => translate('app_name');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get close => translate('close');
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get dark => translate('dark');
  String get light => translate('light');
  String get system => translate('system');
  String get language => translate('language');
  String get english => translate('english');
  String get vietnamese => translate('vietnamese');
  String get selectTheme => translate('select_theme');
  String get selectLanguage => translate('select_language');
  
  // Notifications
  String get notifications => translate('notifications');
  String get noNotifications => translate('no_notifications');
  String get noNotificationsMessage => translate('no_notifications_message');
  String get markAsRead => translate('mark_as_read');
  String get markAllAsRead => translate('mark_all_as_read');
  String get clearAll => translate('clear_all');
  String get delete => translate('delete');
  String get aqiAlert => translate('aqi_alert');
  String get deviceStatus => translate('device_status');
  String get automation => translate('automation');
  String get systemNotification => translate('system');
  
  // Profile Management
  String get editProfile => translate('edit_profile');
  String get healthPreferences => translate('health_preferences');
  String get savedLocations => translate('saved_locations');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
