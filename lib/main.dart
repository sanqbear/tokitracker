import 'package:flutter/material.dart';
import 'core/storage/hive_storage.dart';
import 'injection_container.dart';
import 'config/routes/app_router.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  final hiveStorage = HiveStorage();
  await hiveStorage.init();

  // Configure dependency injection
  await configureDependencies();

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
