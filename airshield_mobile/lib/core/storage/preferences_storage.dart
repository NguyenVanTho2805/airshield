import 'package:shared_preferences/shared_preferences.dart';

/// Preferences Storage
/// 
/// Wrapper for SharedPreferences to store theme and language preferences
class PreferencesStorage {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';

  SharedPreferences? _prefs;

  /// Initialize preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs?.setString(_themeKey, themeMode);
  }

  /// Get theme mode
  String? getThemeMode() {
    return _prefs?.getString(_themeKey);
  }

  /// Save language code
  Future<void> saveLanguageCode(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
  }

  /// Get language code
  String? getLanguageCode() {
    return _prefs?.getString(_languageKey);
  }

  /// Clear all preferences
  Future<void> clear() async {
    await _prefs?.clear();
  }
}
