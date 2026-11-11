import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<void> logout();

  /// Rebuilds the signed-in user from the stored token.
  /// Left(SessionExpiredFailure) when there is no token or it was rejected
  /// (the token is deleted); Left(NetworkFailure) when the server is
  /// unreachable (the token is kept).
  Future<Either<Failure, UserEntity>> restoreSession();
  Future<Either<Failure, UserEntity>> register({
    required String companyName,
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? city,
  });
}
