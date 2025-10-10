import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'injection_container.config.dart';
import 'config/routes/app_router.dart';
import 'core/storage/local_storage.dart';
import 'core/network/http_client.dart';

/// Service Locator instance
/// Use this to access dependencies throughout the app
/// Example: final httpClient = sl<HttpClient>();
final sl = GetIt.instance;

/// Configure dependency injection
/// This must be called in main() before runApp()
/// @param cookieJar Pre-initialized CookieJar instance
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies(CookieJar cookieJar) async {
  // Register CookieJar manually (initialized in main.dart)
  sl.registerSingleton<CookieJar>(cookieJar);

  // Register HttpClient manually (depends on CookieJar)
  sl.registerSingleton<HttpClient>(HttpClient(cookieJar));

  // Initialize auto-generated dependencies
  await sl.init();

  // Manually register AppRouter since it's not auto-discovered
  // (it's in a separate config directory)
  sl.registerSingleton<AppRouter>(AppRouter(sl<LocalStorage>()));
}
