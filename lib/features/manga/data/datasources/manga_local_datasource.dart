import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/storage/local_storage.dart';
import 'package:tokitracker/features/manga/data/models/title_detail_model.dart';

@injectable
class MangaLocalDataSource {
  final LocalStorage localStorage;

  MangaLocalDataSource(this.localStorage);

  /// Add to favorites
  Future<void> addToFavorites(TitleDetailModel title) async {
    // TODO: Implement using Hive or SharedPreferences
    // For now, simple implementation
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(int titleId) async {
    // TODO: Implement using Hive or SharedPreferences
  }

  /// Check if favorite
  Future<bool> isFavorite(int titleId) async {
    // TODO: Implement using Hive or SharedPreferences
    return false;
  }

  /// Get all favorites
  Future<List<TitleDetailModel>> getFavorites() async {
    // TODO: Implement using Hive or SharedPreferences
    return [];
  }

  /// Add to recent
  Future<void> addToRecent(TitleDetailModel title) async {
    // TODO: Implement using Hive or SharedPreferences
  }

  /// Get recent
  Future<List<TitleDetailModel>> getRecent() async {
    // TODO: Implement using Hive or SharedPreferences
    return [];
  }
}
