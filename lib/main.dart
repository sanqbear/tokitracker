import 'package:flutter/material.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'core/storage/hive_storage.dart';
import 'injection_container.dart';
import 'config/routes/app_router.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  final hiveStorage = HiveStorage();
  await hiveStorage.init();

  // Initialize CookieJar (needed for HttpClient)
  final appDocDir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage('${appDocDir.path}/.cookies/'),
  );

  // Configure dependency injection with pre-initialized CookieJar
  await configureDependencies(cookieJar);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get router from dependency injection
    final appRouter = sl<AppRouter>();

    return MaterialApp.router(
      title: 'TokiTracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
