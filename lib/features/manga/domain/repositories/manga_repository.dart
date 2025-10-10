import 'package:dartz/dartz.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';

abstract class MangaRepository {
  /// Fetch title detail with episodes
  Future<Either<Failure, TitleDetail>> fetchTitleDetail({
    required int id,
    required BaseMode baseMode,
  });

  /// Toggle server-side bookmark
  Future<Either<Failure, bool>> toggleBookmark({
    required String bookmarkLink,
    required bool currentStatus,
  });

  /// Add title to local favorites
  Future<Either<Failure, void>> addToFavorites(TitleDetail title);

  /// Remove title from local favorites
  Future<Either<Failure, void>> removeFromFavorites(int titleId);

  /// Check if title is in favorites
  Future<Either<Failure, bool>> isFavorite(int titleId);

  /// Add title to recent list
  Future<Either<Failure, void>> addToRecent(TitleDetail title);
}
