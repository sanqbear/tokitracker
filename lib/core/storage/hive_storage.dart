import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';

/// Hive-based local storage for complex objects
/// Used for offline manga data, download queue, etc.
@singleton
class HiveStorage {
  late Box _mainBox;
  bool _initialized = false;

  /// Initialize Hive storage
  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters here when needed
    // Example: Hive.registerAdapter(MangaAdapter());

    _mainBox = await Hive.openBox(AppConstants.storageBoxName);
    _initialized = true;
  }

  /// Check if storage is initialized
  bool get isInitialized => _initialized;

  /// Save data to storage
  Future<void> save<T>(String key, T value) async {
    await _mainBox.put(key, value);
  }

  /// Get data from storage
  T? get<T>(String key) {
    return _mainBox.get(key) as T?;
  }

  /// Get data with default value
  T getOrDefault<T>(String key, T defaultValue) {
    return _mainBox.get(key, defaultValue: defaultValue) as T;
  }

  /// Delete data from storage
  Future<void> delete(String key) async {
    await _mainBox.delete(key);
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _mainBox.containsKey(key);
  }

  /// Get all keys
  Iterable<dynamic> get keys => _mainBox.keys;

  /// Get all values
  Iterable<dynamic> get values => _mainBox.values;

  /// Clear all data
  Future<void> clear() async {
    await _mainBox.clear();
  }

  /// Get box length
  int get length => _mainBox.length;

  /// Close storage
  Future<void> close() async {
    if (_initialized) {
      await _mainBox.close();
      _initialized = false;
    }
  }

  /// Get a specific box
  Future<Box<T>> getBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }

  /// Save list of items
  Future<void> saveList<T>(String key, List<T> items) async {
    await _mainBox.put(key, items);
  }

  /// Get list of items
  List<T>? getList<T>(String key) {
    final data = _mainBox.get(key);
    if (data is List) {
      return data.cast<T>();
    }
    return null;
  }

  /// Get list with default value
  List<T> getListOrDefault<T>(String key, List<T> defaultValue) {
    final data = _mainBox.get(key);
    if (data is List) {
      return data.cast<T>();
    }
    return defaultValue;
  }
}
