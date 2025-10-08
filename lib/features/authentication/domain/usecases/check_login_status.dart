import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Check login status use case
@injectable
class CheckLoginStatus {
  final AuthRepository repository;

  CheckLoginStatus(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isLoggedIn();
  }
}
