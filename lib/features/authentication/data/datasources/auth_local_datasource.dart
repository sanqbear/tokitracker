import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_storage.dart';
import '../models/user_model.dart';

/// Authentication local data source
/// Handles local storage of user data
@injectable
class AuthLocalDataSource {
  final HiveStorage hiveStorage;

  static const String _userKey = 'current_user';

  AuthLocalDataSource(this.hiveStorage);

  /// Get cached user
  Future<UserModel?> getCachedUser() async {
    try {
      final userData = hiveStorage.get<Map<dynamic, dynamic>>(_userKey);
      if (userData == null) return null;

      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      final jsonMap = Map<String, dynamic>.from(userData);
      return UserModel.fromJson(jsonMap);
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }

  /// Cache user
  Future<void> cacheUser(UserModel user) async {
    try {
      await hiveStorage.save(_userKey, user.toJson());
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  /// Clear cached user
  Future<void> clearCachedUser() async {
    try {
      await hiveStorage.delete(_userKey);
    } catch (e) {
      throw CacheException('Failed to clear cached user: $e');
    }
  }

  /// Check if user is cached
  Future<bool> hasUser() async {
    try {
      return hiveStorage.containsKey(_userKey);
    } catch (e) {
      return false;
    }
  }
}
