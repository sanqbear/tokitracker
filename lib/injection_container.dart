import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

/// Service Locator instance
/// Use this to access dependencies throughout the app
/// Example: final httpClient = sl<HttpClient>();
final sl = GetIt.instance;

/// Configure dependency injection
/// This must be called in main() before runApp()
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await sl.init();
}
