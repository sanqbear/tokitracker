import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/captcha_data.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, CaptchaData>> prepareCaptcha() async {
    try {
      final (imageBytes, sessionCookie, timestamp) =
          await remoteDataSource.prepareCaptcha();

      return Right(CaptchaData(
        imageBytes: imageBytes,
        sessionCookie: sessionCookie,
        timestamp: timestamp,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
    required String captchaAnswer,
    required String sessionCookie,
  }) async {
    try {
      final resultCookie = await remoteDataSource.login(
        username: username,
        password: password,
        captchaAnswer: captchaAnswer,
        sessionCookie: sessionCookie,
      );

      final user = User(
        username: username,
        sessionCookie: resultCookie,
        loginTime: DateTime.now(),
      );

      // Cache user locally
      await localDataSource.cacheUser(UserModel.fromEntity(user));

      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCachedUser();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final hasUser = await localDataSource.hasUser();
      if (!hasUser) return const Right(false);

      final userModel = await localDataSource.getCachedUser();
      if (userModel == null) return const Right(false);

      final user = userModel.toEntity();
      return Right(user.isValid);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      if (userModel == null) return const Right(null);

      return Right(userModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(User user) async {
    try {
      await localDataSource.cacheUser(UserModel.fromEntity(user));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearUser() async {
    try {
      await localDataSource.clearCachedUser();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
