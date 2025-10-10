// import 'package:cookie_jar/cookie_jar.dart'; // Moved to main.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
// import 'package:path_provider/path_provider.dart'; // Moved to main.dart

/// Dio and related dependencies module
@module
abstract class DioModule {
  /// Provide CookieJar for persistent cookies
  /// NOTE: CookieJar is now initialized in main.dart and registered manually
  /// in injection_container.dart to avoid async dependency chain
  // @lazySingleton
  // Future<CookieJar> provideCookieJar() async {
  //   final appDocDir = await getApplicationDocumentsDirectory();
  //   final appDocPath = appDocDir.path;
  //   // Use PersistCookieJar for persistent storage
  //   return PersistCookieJar(
  //     storage: FileStorage('$appDocPath/.cookies/'),
  //   );
  // }

  /// Provide Connectivity instance
  @lazySingleton
  Connectivity provideConnectivity() => Connectivity();
}
