import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/webtoon_home_data.dart';
import '../repositories/home_repository.dart';

/// Use case for fetching webtoon home page data
@injectable
class FetchWebtoonHomeData {
  final HomeRepository repository;

  FetchWebtoonHomeData(this.repository);

  /// Execute the use case
  /// Returns `Either<Failure, WebtoonHomeData>`
  Future<Either<Failure, WebtoonHomeData>> call() async {
    return await repository.fetchWebtoonHomeData();
  }
}
