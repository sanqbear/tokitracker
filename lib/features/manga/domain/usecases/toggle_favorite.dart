import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';

@injectable
class ToggleFavorite {
  final MangaRepository repository;

  ToggleFavorite(this.repository);

  Future<Either<Failure, bool>> call({
    required TitleDetail title,
    required bool currentStatus,
  }) async {
    if (currentStatus) {
      final result = await repository.removeFromFavorites(title.id);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(false),
      );
    } else {
      final result = await repository.addToFavorites(title);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(true),
      );
    }
  }
}
