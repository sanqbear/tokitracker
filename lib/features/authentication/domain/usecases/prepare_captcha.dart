import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/captcha_data.dart';
import '../repositories/auth_repository.dart';

/// Prepare captcha use case
@injectable
class PrepareCaptcha {
  final AuthRepository repository;

  PrepareCaptcha(this.repository);

  Future<Either<Failure, CaptchaData>> call() async {
    return await repository.prepareCaptcha();
  }
}
