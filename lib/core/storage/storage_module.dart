import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage module for dependency injection
@module
abstract class StorageModule {
  /// Provide SharedPreferences instance
  @preResolve
  @singleton
  Future<SharedPreferences> provideSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }
}
