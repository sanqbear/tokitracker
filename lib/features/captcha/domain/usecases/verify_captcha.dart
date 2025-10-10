import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/captcha/domain/entities/captcha_result.dart';
import 'package:tokitracker/features/captcha/domain/repositories/captcha_repository.dart';

/// UseCase for verifying captcha and saving cookies
/// Corresponds to the cookie extraction and saving logic in CaptchaActivity.java
@injectable
class VerifyCaptcha {
  final CaptchaRepository repository;

  VerifyCaptcha(this.repository);

  Future<Either<Failure, void>> call(CaptchaResult result) async {
    if (!result.success) {
      return Left(
        ServerFailure(result.errorMessage ?? 'Captcha verification failed'),
      );
    }

    // Save cookies to HttpClient
    final cookieResult = await repository.saveCookies(result.cookies);
    if (cookieResult.isLeft()) {
      return cookieResult;
    }

    // Update user agent if provided
    if (result.userAgent != null && result.userAgent!.isNotEmpty) {
      final uaResult = await repository.updateUserAgent(result.userAgent!);
      if (uaResult.isLeft()) {
        return uaResult;
      }
    }

    return const Right(null);
  }
}
