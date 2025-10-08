import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Login use case
@injectable
class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(
      username: params.username,
      password: params.password,
      captchaAnswer: params.captchaAnswer,
      sessionCookie: params.sessionCookie,
    );
  }
}

/// Login parameters
class LoginParams extends Equatable {
  final String username;
  final String password;
  final String captchaAnswer;
  final String sessionCookie;

  const LoginParams({
    required this.username,
    required this.password,
    required this.captchaAnswer,
    required this.sessionCookie,
  });

  @override
  List<Object?> get props => [username, password, captchaAnswer, sessionCookie];
}
