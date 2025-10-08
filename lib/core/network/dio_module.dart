import 'package:cookie_jar/cookie_jar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

/// Dio and related dependencies module
@module
abstract class DioModule {
  /// Provide CookieJar for persistent cookies
  @lazySingleton
  Future<CookieJar> provideCookieJar() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    // Use PersistCookieJar for persistent storage
    return PersistCookieJar(
      storage: FileStorage('$appDocPath/.cookies/'),
    );
  }

  /// Provide Connectivity instance
  @lazySingleton
  Connectivity provideConnectivity() => Connectivity();
}
