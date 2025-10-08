# Dependency Injection

This document explains the dependency injection setup using GetIt and Injectable.

## Registered Dependencies

The following dependencies are automatically registered:

### Core - Network
- ✅ `HttpClient` (Singleton)
- ✅ `CookieJar` (LazySingleton)
- ✅ `Connectivity` (LazySingleton)
- ✅ `NetworkInfo` / `NetworkInfoImpl` (LazySingleton)
- ✅ `CaptchaInterceptor` (Factory)
- ✅ `ErrorInterceptor` (Factory)
- ✅ `LoggingInterceptor` (Factory)

### Core - Storage
- ✅ `HiveStorage` (Singleton)
- ✅ `LocalStorage` (Singleton)
- ✅ `FileManager` (Singleton)
- ✅ `SharedPreferences` (Singleton, PreResolved)

### Config - Routes
- ✅ `AppRouter` (Singleton)
- ✅ `RouteGuard` (Factory)

### Modules
- ✅ `StorageModule`
- ✅ `DioModule`

## Dependency Lifecycle

### Singleton
Created once and shared across the entire app lifecycle.
- `HttpClient`
- `HiveStorage`
- `LocalStorage`
- `FileManager`
- `AppRouter`

### LazySingleton
Created once when first accessed, then shared.
- `CookieJar`
- `Connectivity`
- `NetworkInfo`

### Factory
New instance created every time it's requested.
- Interceptors (CaptchaInterceptor, ErrorInterceptor, LoggingInterceptor)
- `RouteGuard`

### PreResolved (Singleton)
Resolved immediately during initialization (async).
- `SharedPreferences`

## Usage

### Access Dependencies

```dart
import 'package:tokitracker/injection_container.dart';

// Get singleton instance
final httpClient = sl<HttpClient>();
final localStorage = sl<LocalStorage>();
final router = sl<AppRouter>();

// Get factory instance (new instance each time)
final guard = sl<RouteGuard>();
```

### In Constructors

```dart
class MyRepository {
  final HttpClient httpClient;
  final LocalStorage localStorage;

  MyRepository(this.httpClient, this.localStorage);
}

// Usage
final repo = MyRepository(
  sl<HttpClient>(),
  sl<LocalStorage>(),
);
```

### With Injectable Annotation

```dart
@injectable
class MyService {
  final HttpClient httpClient;
  final LocalStorage localStorage;

  MyService(this.httpClient, this.localStorage);
}

// After build_runner, access with:
final service = sl<MyService>();
```

## Initialization

Dependencies are initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveStorage = HiveStorage();
  await hiveStorage.init();

  // Configure all dependencies
  await configureDependencies();

  runApp(const MyApp());
}
```

## All Verified Registrations

Based on generated code:

| Type | Lifecycle | Module |
|------|-----------|--------|
| CaptchaInterceptor | Factory | - |
| ErrorInterceptor | Factory | - |
| LoggingInterceptor | Factory | - |
| FileManager | Singleton | - |
| HiveStorage | Singleton | - |
| SharedPreferences | Singleton (PreResolved) | StorageModule |
| CookieJar | LazySingleton (Async) | DioModule |
| Connectivity | LazySingleton | DioModule |
| HttpClient | Singleton (Async) | - |
| LocalStorage | Singleton | - |
| AppRouter | Singleton | - |
| RouteGuard | Factory | - |
| NetworkInfo | LazySingleton | - |

## Adding New Dependencies

1. Annotate your class:

```dart
@singleton  // or @lazySingleton, @injectable (factory)
class MyNewService {
  final HttpClient httpClient;

  MyNewService(this.httpClient);
}
```

2. Run code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Access the dependency:

```dart
final myService = sl<MyNewService>();
```

## Modules

### StorageModule

Provides:
- `SharedPreferences` (async singleton)

### DioModule

Provides:
- `CookieJar` (lazy singleton with persistent storage)
- `Connectivity` (lazy singleton)

## Testing

For testing, you can reset and register mock dependencies:

```dart
void main() {
  setUp(() {
    // Reset GetIt
    sl.reset();

    // Register mocks
    sl.registerSingleton<HttpClient>(MockHttpClient());
    sl.registerSingleton<LocalStorage>(MockLocalStorage());
  });

  test('my test', () {
    // Test code
  });
}
```

## Troubleshooting

### Dependency not found
- Ensure the class is annotated with `@injectable`, `@singleton`, or `@lazySingleton`
- Run build_runner to regenerate code
- Check that the dependency is imported in files that use it

### Circular dependencies
- Use `@lazySingleton` instead of `@singleton`
- Refactor to break the circular dependency

### Async dependencies
- Use `@preResolve` for async factories in modules
- Access with `await getAsync<T>()` in other dependencies
