# TokiTracker Setup Guide

This guide helps you set up the TokiTracker development environment.

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (included with Flutter)
- Android Studio / VS Code with Flutter extensions
- Git

## Installation Steps

### 1. Clone the Repository

```bash
git clone <repository-url>
cd tokitracker
```

### 2. Initialize Submodules

The project includes the legacy Android app as a reference:

```bash
git submodule init
git submodule update
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Generate Code

Generate dependency injection and serialization code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `lib/injection_container.config.dart` - Dependency injection configuration
- `*.g.dart` files - JSON serialization code (when models are added)
- `*.adapter.dart` files - Hive type adapters (when models are added)

### 5. Verify Setup

Check that everything is working:

```bash
flutter doctor
flutter analyze
flutter test
```

### 6. Run the App

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>

# Run in debug mode (default)
flutter run

# Run in release mode
flutter run --release
```

## Development Workflow

### Running the App

```bash
# Debug mode with hot reload
flutter run

# Profile mode (for performance testing)
flutter run --profile

# Release mode
flutter run --release
```

### Code Generation

When you add new models, entities, or injectable classes:

```bash
# Generate code once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes and auto-generate
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage
```

### Linting

```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

## Project Structure

```
lib/
├── core/              # Core functionality
│   ├── constants/     # Constants
│   ├── error/         # Error handling
│   ├── network/       # HTTP client
│   └── storage/       # Local storage
├── features/          # Feature modules
│   ├── authentication/
│   ├── home/
│   ├── manga/
│   ├── viewer/
│   ├── search/
│   ├── download/
│   ├── favorites/
│   └── settings/
├── config/            # App configuration
│   ├── routes/        # Navigation
│   └── themes/        # Theming
├── injection_container.dart  # DI setup
└── main.dart          # Entry point
```

## Common Commands

### Dependency Management

```bash
# Add a package
flutter pub add package_name

# Add a dev dependency
flutter pub add --dev package_name

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

### Building

```bash
# Build APK (Android)
flutter build apk

# Build App Bundle (Android)
flutter build appbundle

# Build iOS
flutter build ios

# Build Web
flutter build web
```

### Cleaning

```bash
# Clean build artifacts
flutter clean

# Re-download dependencies
flutter pub get

# Regenerate code
flutter pub run build_runner build --delete-conflicting-outputs
```

## Code Generation Details

### Injectable (Dependency Injection)

Mark classes with annotations:

```dart
@singleton      // Single instance throughout app
@lazySingleton  // Single instance, created on first access
@injectable     // New instance each time (factory)
```

Example:

```dart
@injectable
class MyRepository {
  final HttpClient httpClient;
  MyRepository(this.httpClient);
}
```

### JSON Serialization

Mark model classes:

```dart
@JsonSerializable()
class MangaModel {
  final int id;
  final String name;

  MangaModel({required this.id, required this.name});

  factory MangaModel.fromJson(Map<String, dynamic> json) =>
      _$MangaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MangaModelToJson(this);
}
```

### Hive Type Adapters

Mark Hive models:

```dart
@HiveType(typeId: 0)
class MangaBox extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;
}
```

## Troubleshooting

### Build runner fails

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Missing dependencies

```bash
# Ensure all dependencies are installed
flutter pub get

# Update to latest compatible versions
flutter pub upgrade
```

### Platform-specific issues

**Android:**
- Check `android/app/build.gradle` for correct SDK versions
- Ensure Android SDK is installed

**iOS:**
- Run `pod install` in `ios/` directory
- Check Xcode version compatibility

**Windows:**
- Ensure Visual Studio with C++ tools is installed

### Hot reload not working

- Restart the app: `R` in terminal
- Full restart: Stop and rerun `flutter run`

## Configuration

### API Base URL

Update in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### Storage Directory

First-time setup will prompt for storage directory selection.

## Documentation

- [PROJECT.md](PROJECT.md) - Architecture overview
- [CLAUDE.md](CLAUDE.md) - Development guidelines
- [README_STRUCTURE.md](README_STRUCTURE.md) - Project structure
- Module READMEs:
  - [core/network/README.md](lib/core/network/README.md)
  - [core/storage/README.md](lib/core/storage/README.md)
  - [config/routes/README.md](lib/config/routes/README.md)
  - [core/di/README.md](lib/core/di/README.md)

## Next Steps

1. Review [PROJECT.md](PROJECT.md) for architecture details
2. Read [CLAUDE.md](CLAUDE.md) for development guidelines
3. Start implementing features from Phase 2 (see PROJECT.md)

## Getting Help

- Check documentation files
- Review legacy Android app in `references/MangaViewAndroid`
- Open an issue for bugs or questions
