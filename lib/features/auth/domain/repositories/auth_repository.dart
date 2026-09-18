import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<void> logout();
  Future<Either<Failure, UserEntity>> register({
    required String companyName,
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? city,
  });
}
