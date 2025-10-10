import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';

@injectable
class AddToRecent {
  final MangaRepository repository;

  AddToRecent(this.repository);

  Future<Either<Failure, void>> call(TitleDetail title) async {
    return await repository.addToRecent(title);
  }
}
