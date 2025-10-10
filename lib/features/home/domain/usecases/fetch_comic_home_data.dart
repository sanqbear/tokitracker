import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/comic_home_data.dart';
import '../repositories/home_repository.dart';

/// Use case for fetching comic/manga home page data
@injectable
class FetchComicHomeData {
  final HomeRepository repository;

  FetchComicHomeData(this.repository);

  /// Execute the use case
  /// Returns Either<Failure, ComicHomeData>
  Future<Either<Failure, ComicHomeData>> call() async {
    return await repository.fetchComicHomeData();
  }
}
