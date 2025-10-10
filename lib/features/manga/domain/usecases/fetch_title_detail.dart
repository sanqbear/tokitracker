import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';

@injectable
class FetchTitleDetail {
  final MangaRepository repository;

  FetchTitleDetail(this.repository);

  Future<Either<Failure, TitleDetail>> call({
    required int id,
    required BaseMode baseMode,
  }) async {
    return await repository.fetchTitleDetail(
      id: id,
      baseMode: baseMode,
    );
  }
}
