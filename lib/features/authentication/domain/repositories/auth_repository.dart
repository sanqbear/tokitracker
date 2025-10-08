import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/captcha_data.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Prepare captcha for login
  /// Returns captcha image data and session cookie
  Future<Either<Failure, CaptchaData>> prepareCaptcha();

  /// Login with credentials and captcha answer
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
    required String captchaAnswer,
    required String sessionCookie,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Check if user is logged in
  Future<Either<Failure, bool>> isLoggedIn();

  /// Get current user from local storage
  Future<Either<Failure, User?>> getCurrentUser();

  /// Save user to local storage
  Future<Either<Failure, void>> saveUser(User user);

  /// Clear user from local storage
  Future<Either<Failure, void>> clearUser();
}
