import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/comic_home_data.dart';
import '../entities/webtoon_home_data.dart';

/// Repository interface for home screen data
abstract class HomeRepository {
  /// Fetch comic/manga home page data
  /// Returns ComicHomeData with recent manga, rankings, etc.
  Future<Either<Failure, ComicHomeData>> fetchComicHomeData();

  /// Fetch webtoon home page data
  /// Returns WebtoonHomeData with 8 ranking sections
  Future<Either<Failure, WebtoonHomeData>> fetchWebtoonHomeData();
}
