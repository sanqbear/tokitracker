import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';

@injectable
class ToggleBookmark {
  final MangaRepository repository;

  ToggleBookmark(this.repository);

  Future<Either<Failure, bool>> call({
    required String bookmarkLink,
    required bool currentStatus,
  }) async {
    return await repository.toggleBookmark(
      bookmarkLink: bookmarkLink,
      currentStatus: currentStatus,
    );
  }
}
