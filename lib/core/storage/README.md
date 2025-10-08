# Storage Module

This module provides local storage functionality for the application, replacing the legacy `Preference.java` and supporting offline data storage.

## Components

### HiveStorage (`hive_storage.dart`)
Hive-based storage for complex objects (offline manga data, download queue, etc.)

**Features:**
- Store and retrieve complex objects
- Type-safe storage with generic methods
- Support for lists and custom objects
- Persistent storage across app restarts

**Usage:**
```dart
final hiveStorage = sl<HiveStorage>();

// Save data
await hiveStorage.save('key', {'name': 'Naruto', 'id': 123});

// Get data
final data = hiveStorage.get<Map<String, dynamic>>('key');

// Save list
await hiveStorage.saveList('favorites', [1, 2, 3, 4, 5]);

// Get list
final favorites = hiveStorage.getList<int>('favorites');

// Check if key exists
if (hiveStorage.containsKey('key')) {
  // Key exists
}

// Clear all data
await hiveStorage.clear();
```

**Box Management:**
```dart
// Get specific box
final mangaBox = await hiveStorage.getBox<Manga>('manga_box');

// Save to specific box
await mangaBox.put('naruto', Manga(...));

// Get from specific box
final manga = mangaBox.get('naruto');
```

### LocalStorage (`local_storage.dart`)
SharedPreferences-based storage for simple key-value pairs (settings, user preferences)

**Features:**
- String, int, bool, double, string list support
- Default value support
- Legacy app compatibility methods
- Type-safe getters and setters

**Usage:**
```dart
final localStorage = sl<LocalStorage>();

// String
await localStorage.setString('username', 'user123');
final username = localStorage.getString('username');

// Int
await localStorage.setInt('page', 5);
final page = localStorage.getInt('page');

// Bool
await localStorage.setBool('darkMode', true);
final isDark = localStorage.getBool('darkMode');

// With default values
final theme = localStorage.getStringOrDefault('theme', 'light');
final pageSize = localStorage.getIntOrDefault('pageSize', 20);

// Legacy app compatibility
await localStorage.setHomeDir('/storage/emulated/0/TokiTracker');
final homeDir = localStorage.getHomeDir();

await localStorage.setBaseUrl('https://example.com');
final baseUrl = localStorage.getBaseUrl();

// Dark mode
await localStorage.setDarkMode(true);
final isDarkMode = localStorage.isDarkMode();

// First time check
if (localStorage.isFirstTime()) {
  // Show onboarding
  await localStorage.setFirstTimeCompleted();
}
```

### FileManager (`file_manager.dart`)
File system manager for downloads, cache, and file operations

**Features:**
- Directory and file operations
- Size calculations
- Manga-specific directory management
- Cache management

**Usage:**
```dart
final fileManager = sl<FileManager>();

// Get directories
final docsDir = await fileManager.getDocumentsDirectory();
final tempDir = await fileManager.getTemporaryDirectory();

// Create directory
await fileManager.createDirectory('/path/to/directory');

// Check existence
final exists = await fileManager.fileExists('/path/to/file.txt');

// File operations
await fileManager.copyFile('/source.txt', '/destination.txt');
await fileManager.moveFile('/old.txt', '/new.txt');

// Read/Write
final content = await fileManager.readFileAsString('/file.txt');
await fileManager.writeStringToFile('/file.txt', 'content');

// Manga directories (legacy compatibility)
final mangaDir = await fileManager.getMangaDownloadDirectory(homeDir);
final titleDir = await fileManager.getMangaTitleDirectory(homeDir, titleId);
final episodeDir = await fileManager.getMangaEpisodeDirectory(homeDir, titleId, episodeId);

// Size calculations
final fileSize = await fileManager.getFileSize('/file.txt');
final dirSize = await fileManager.getDirectorySize('/directory');
print(fileManager.formatBytes(fileSize)); // "1.5 MB"

// List files
final files = await fileManager.listFiles('/directory', recursive: true);
final dirs = await fileManager.listDirectories('/directory');

// Clear cache
await fileManager.clearCache();
```

## Storage Structure

### HiveStorage
- Main box: `tokitracker_box` (defined in AppConstants)
- Used for: offline manga data, download queue, favorites, history

### LocalStorage (SharedPreferences)
- Used for: app settings, user preferences, simple flags
- Legacy keys:
  - `homeDir`: Download directory path
  - `url`: Base URL
  - `darkMode`: Dark mode preference
  - `firstTime`: First launch flag

### File System
```
Documents/
├── manga/              # Downloaded manga
│   ├── {titleId}/
│   │   ├── {episodeId}/
│   │   │   ├── page_001.jpg
│   │   │   ├── page_002.jpg
│   │   │   └── ...
│   │   └── title.json  # Title metadata
│   └── ...
└── .cookies/           # Persistent cookies
```

## Legacy App Mapping

| Legacy (Java) | Flutter (Dart) |
|--------------|----------------|
| `Preference.java` | `local_storage.dart` |
| `SharedPreferences` | `LocalStorage` |
| File operations (manual) | `FileManager` |
| Offline data storage | `HiveStorage` |

## Initialization

Storage is initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveStorage = HiveStorage();
  await hiveStorage.init();

  // Configure DI (includes SharedPreferences)
  await configureDependencies();

  runApp(const MyApp());
}
```

## Type Adapters

When storing custom objects in Hive, register type adapters:

```dart
// In hive_storage.dart init()
Hive.registerAdapter(MangaAdapter());
Hive.registerAdapter(TitleAdapter());
```

Generate adapters with build_runner:
```bash
flutter pub run build_runner build
```
