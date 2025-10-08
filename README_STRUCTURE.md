# Project Structure

This document provides an overview of the tokitracker project structure following Clean Architecture principles.

## Directory Overview

```
lib/
├── core/                   # Core functionality shared across features
│   ├── constants/          # App-wide constants (API, app settings)
│   ├── error/             # Error handling (exceptions, failures)
│   ├── network/           # Network client configuration
│   ├── storage/           # Local storage utilities
│   └── utils/             # Utility functions
│
├── features/              # Feature modules (feature-first architecture)
│   ├── authentication/    # User authentication
│   ├── home/             # Main screen, updates, rankings
│   ├── manga/            # Manga details, episodes, comments
│   ├── viewer/           # Manga viewer (multiple view modes)
│   ├── search/           # Search functionality
│   ├── download/         # Download management
│   ├── favorites/        # Bookmarks and favorites
│   └── settings/         # App settings
│
├── config/               # App configuration
│   ├── routes/          # Navigation configuration (GoRouter)
│   └── themes/          # Theme configuration (light/dark mode)
│
├── injection_container.dart  # Dependency injection setup
└── main.dart                 # App entry point
```

## Feature Module Structure

Each feature follows Clean Architecture with three layers:

```
feature/
├── data/
│   ├── datasources/      # Remote and local data sources
│   ├── models/          # Data models (JSON serialization)
│   └── repositories/    # Repository implementations
│
├── domain/
│   ├── entities/        # Business entities (pure Dart)
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic use cases
│
└── presentation/
    ├── bloc/            # State management (BLoC)
    ├── pages/           # Screen widgets
    └── widgets/         # Reusable UI components
```

## Dependency Flow

```
Presentation → Domain ← Data
```

- **Presentation** depends on Domain
- **Data** depends on Domain
- **Domain** has no dependencies (pure Dart)

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Generate code (for DI, JSON serialization):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Key Technologies

- **State Management**: BLoC (flutter_bloc)
- **Dependency Injection**: GetIt + Injectable
- **Network**: Dio
- **Local Storage**: Hive + SharedPreferences
- **Navigation**: GoRouter
- **HTML Parsing**: html package
- **Image Caching**: cached_network_image

## Reference

See [PROJECT.md](../PROJECT.md) for detailed architecture documentation.
