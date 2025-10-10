import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/exceptions.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/core/storage/local_storage.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/data/datasources/manga_local_datasource.dart';
import 'package:tokitracker/features/manga/data/datasources/manga_remote_datasource.dart';
import 'package:tokitracker/features/manga/data/models/title_detail_model.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';

@Injectable(as: MangaRepository)
class MangaRepositoryImpl implements MangaRepository {
  final MangaRemoteDataSource remoteDataSource;
  final MangaLocalDataSource localDataSource;
  final LocalStorage localStorage;

  MangaRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.localStorage,
  );

  @override
  Future<Either<Failure, TitleDetail>> fetchTitleDetail({
    required int id,
    required BaseMode baseMode,
  }) async {
    try {
      final titleDetail = await remoteDataSource.fetchTitleDetail(
        id: id,
        baseMode: baseMode,
      );
      return Right(titleDetail);
    } on CaptchaRequiredException catch (e) {
      return Left(CaptchaFailure(e.captchaUrl, e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleBookmark({
    required String bookmarkLink,
    required bool currentStatus,
  }) async {
    try {
      if (!localStorage.isLoggedIn()) {
        return const Left(AuthenticationFailure('Login required'));
      }

      final cookie = localStorage.getUserCookie();
      if (cookie == null || cookie.isEmpty) {
        return const Left(AuthenticationFailure('Login required'));
      }

      final success = await remoteDataSource.toggleBookmark(
        bookmarkLink: bookmarkLink,
        currentStatus: currentStatus,
        cookie: cookie,
      );

      return Right(success);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(TitleDetail title) async {
    try {
      final model = TitleDetailModel.fromEntity(title);
      await localDataSource.addToFavorites(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add to favorites: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(int titleId) async {
    try {
      await localDataSource.removeFromFavorites(titleId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to remove from favorites: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int titleId) async {
    try {
      final isFav = await localDataSource.isFavorite(titleId);
      return Right(isFav);
    } catch (e) {
      return Left(CacheFailure('Failed to check favorite: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToRecent(TitleDetail title) async {
    try {
      final model = TitleDetailModel.fromEntity(title);
      await localDataSource.addToRecent(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add to recent: $e'));
    }
  }
}
