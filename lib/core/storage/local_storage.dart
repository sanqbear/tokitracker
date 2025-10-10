import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// SharedPreferences-based local storage
/// Replacement for Preference.java in legacy app
/// Used for simple key-value storage (settings, user preferences, etc.)
@singleton
class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // ============== String ==============

  /// Save string value
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Get string with default value
  String getStringOrDefault(String key, String defaultValue) {
    return _prefs.getString(key) ?? defaultValue;
  }

  // ============== Int ==============

  /// Save int value
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Get int value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Get int with default value
  int getIntOrDefault(String key, int defaultValue) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  // ============== Bool ==============

  /// Save bool value
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get bool value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Get bool with default value
  bool getBoolOrDefault(String key, bool defaultValue) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  // ============== Double ==============

  /// Save double value
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Get double with default value
  double getDoubleOrDefault(String key, double defaultValue) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  // ============== StringList ==============

  /// Save string list
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// Get string list
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Get string list with default value
  List<String> getStringListOrDefault(String key, List<String> defaultValue) {
    return _prefs.getStringList(key) ?? defaultValue;
  }

  // ============== Common ==============

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Remove key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all data
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  /// Reload preferences from storage
  Future<void> reload() async {
    await _prefs.reload();
  }

  // ============== Legacy App Compatibility ==============

  /// Get home directory (legacy: homeDir)
  String? getHomeDir() {
    return getString('homeDir');
  }

  /// Set home directory
  Future<bool> setHomeDir(String path) async {
    return await setString('homeDir', path);
  }

  /// Get base URL (legacy: url)
  String? getBaseUrl() {
    return getString('url');
  }

  /// Set base URL
  Future<bool> setBaseUrl(String url) async {
    return await setString('url', url);
  }

  /// Get dark mode setting
  bool isDarkMode() {
    return getBoolOrDefault('darkMode', false);
  }

  /// Set dark mode
  Future<bool> setDarkMode(bool isDark) async {
    return await setBool('darkMode', isDark);
  }

  /// Check if first time launch
  bool isFirstTime() {
    return getBoolOrDefault('firstTime', true);
  }

  /// Set first time launch completed
  Future<bool> setFirstTimeCompleted() async {
    return await setBool('firstTime', false);
  }

  /// Get user cookie (sessionCookie from User entity)
  String? getUserCookie() {
    return getString('sessionCookie');
  }

  /// Set user cookie
  Future<bool> setUserCookie(String cookie) async {
    return await setString('sessionCookie', cookie);
  }

  /// Get username
  String? getUsername() {
    return getString('username');
  }

  /// Set username
  Future<bool> setUsername(String username) async {
    return await setString('username', username);
  }

  /// Check if user is logged in (has valid session cookie)
  bool isLoggedIn() {
    final cookie = getUserCookie();
    return cookie != null && cookie.isNotEmpty;
  }

  /// Clear user session
  Future<void> clearUserSession() async {
    await remove('sessionCookie');
    await remove('username');
  }

  /// Get user agent
  String? getUserAgent() {
    return getString('userAgent');
  }

  /// Set user agent
  Future<bool> setUserAgent(String userAgent) async {
    return await setString('userAgent', userAgent);
  }
}
