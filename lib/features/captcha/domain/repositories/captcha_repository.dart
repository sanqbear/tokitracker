import 'package:dartz/dartz.dart';
import 'package:tokitracker/core/error/failures.dart';

/// Captcha repository interface
/// Handles saving cookies and user agent after captcha verification
abstract class CaptchaRepository {
  /// Save cookies from captcha verification to HttpClient
  Future<Either<Failure, void>> saveCookies(Map<String, String> cookies);

  /// Update user agent in storage for future requests
  Future<Either<Failure, void>> updateUserAgent(String userAgent);
}
