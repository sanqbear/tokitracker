# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**tokitracker** is a Flutter application targeting multiple platforms (Android, iOS, Linux, macOS, Windows, Web). The project appears to be related to manga tracking/viewing functionality.
The purpose of this project is to rewrite the Android legacy app (MangaViewAndroid) by referencing it located in the `references/`.

- **SDK**: Dart ^3.9.2
- **Main Dependencies**: flutter, cupertino_icons
- **Dev Dependencies**: flutter_test, flutter_lints

## Development Commands

### Running the App
```bash
flutter run                    # Run on connected device/emulator
flutter run -d <device-id>     # Run on specific device
flutter run --release          # Run in release mode
```

### Testing
```bash
flutter test                           # Run all tests
flutter test test/widget_test.dart     # Run specific test file
flutter test --coverage                # Run tests with coverage
```

### Building
```bash
# Android
flutter build apk                      # Build APK
flutter build appbundle                # Build App Bundle

# iOS
flutter build ios                      # Build iOS app
flutter build ipa                      # Build IPA for distribution

# Desktop
flutter build windows                  # Build Windows app
flutter build linux                    # Build Linux app
flutter build macos                    # Build macOS app

# Web
flutter build web                      # Build web app
```

### Code Quality
```bash
flutter analyze                        # Run static analysis
flutter pub get                        # Install dependencies
flutter pub upgrade                    # Upgrade dependencies
flutter clean                          # Clean build artifacts
```

### Hot Reload
When running in debug mode, use:
- `r` - Hot reload (fast incremental update)
- `R` - Hot restart (full restart with state reset)

## Architecture

### Current Structure
- **lib/main.dart**: Entry point with standard Flutter counter demo app (MyApp, MyHomePage)
- **test/widget_test.dart**: Basic widget test for counter functionality
- **references/MangaViewAndroid**: Git submodule containing Android reference implementation (마나토끼 전용 뷰어/다운로더)

### Code Style
- Uses `flutter_lints` package for recommended lint rules (configured in `analysis_options.yaml`)
- Material Design is enabled (`uses-material-design: true`)

### Reference Implementation
The `references/MangaViewAndroid` submodule points to a Korean manga viewer/downloader app. This suggests the Flutter app may be intended as a cross-platform rewrite or port of similar functionality. When implementing manga-related features, reference this Android implementation for UI/UX patterns and feature requirements.

### Multi-Platform Considerations
The project scaffolding includes platform-specific directories for Android, iOS, Linux, macOS, Windows, and web. When adding platform-specific features, use Flutter's platform channels if needed, and ensure cross-platform compatibility where possible.
