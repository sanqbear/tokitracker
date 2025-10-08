import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';

/// File system manager for handling file operations
/// Used for manga downloads, cache management, etc.
@singleton
class FileManager {
  /// Get application documents directory
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get application support directory
  Future<Directory> getSupportDirectory() async {
    return await getApplicationSupportDirectory();
  }

  /// Get temporary directory
  Future<Directory> getTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Get external storage directory (Android only)
  Future<Directory?> getExternalStorageDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    }
    return null;
  }

  /// Create directory if not exists
  Future<Directory> createDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Check if directory exists
  Future<bool> directoryExists(String path) async {
    return await Directory(path).exists();
  }

  /// Check if file exists
  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Delete directory
  Future<void> deleteDirectory(String path, {bool recursive = false}) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      await directory.delete(recursive: recursive);
    }
  }

  /// Delete file
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Get directory size in bytes
  Future<int> getDirectorySize(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      return 0;
    }

    int totalSize = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  /// List files in directory
  Future<List<File>> listFiles(String path, {bool recursive = false}) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      return [];
    }

    final files = <File>[];
    await for (final entity in directory.list(recursive: recursive)) {
      if (entity is File) {
        files.add(entity);
      }
    }
    return files;
  }

  /// List directories in directory
  Future<List<Directory>> listDirectories(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      return [];
    }

    final directories = <Directory>[];
    await for (final entity in directory.list(recursive: false)) {
      if (entity is Directory) {
        directories.add(entity);
      }
    }
    return directories;
  }

  /// Copy file
  Future<File> copyFile(String source, String destination) async {
    final sourceFile = File(source);
    return await sourceFile.copy(destination);
  }

  /// Move file
  Future<File> moveFile(String source, String destination) async {
    final sourceFile = File(source);
    return await sourceFile.rename(destination);
  }

  /// Read file as string
  Future<String> readFileAsString(String path) async {
    final file = File(path);
    return await file.readAsString();
  }

  /// Write string to file
  Future<File> writeStringToFile(String path, String content) async {
    final file = File(path);
    return await file.writeAsString(content);
  }

  /// Read file as bytes
  Future<List<int>> readFileAsBytes(String path) async {
    final file = File(path);
    return await file.readAsBytes();
  }

  /// Write bytes to file
  Future<File> writeBytesToFile(String path, List<int> bytes) async {
    final file = File(path);
    return await file.writeAsBytes(bytes);
  }

  /// Get manga download directory
  /// Legacy app: homeDir + /manga
  Future<Directory> getMangaDownloadDirectory(String homeDir) async {
    final path = '$homeDir/manga';
    return await createDirectory(path);
  }

  /// Get manga title directory
  /// Legacy app: homeDir + /manga/titleId
  Future<Directory> getMangaTitleDirectory(String homeDir, int titleId) async {
    final path = '$homeDir/manga/$titleId';
    return await createDirectory(path);
  }

  /// Get manga episode directory
  /// Legacy app: homeDir + /manga/titleId/episodeId
  Future<Directory> getMangaEpisodeDirectory(
    String homeDir,
    int titleId,
    int episodeId,
  ) async {
    final path = '$homeDir/manga/$titleId/$episodeId';
    return await createDirectory(path);
  }

  /// Clear cache directory
  Future<void> clearCache() async {
    final tempDir = await getTemporaryDirectory();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
      await tempDir.create();
    }
  }

  /// Format bytes to human readable string
  String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
