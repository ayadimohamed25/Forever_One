import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';

class UserInput {
  final String email;
  final String? fullName;
  final String? phone;
  final String role;
  final bool isActive;
  final String? password;

  const UserInput({
    required this.email,
    this.fullName,
    this.phone,
    required this.role,
    this.isActive = true,
    this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'full_name': fullName,
    'phone': phone,
    'role': role,
    'is_active': isActive ? 1 : 0,
    if (password != null) 'password': password,
  };
}

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers({String? search});
  Future<Either<Failure, void>> createUser(UserInput input);
  Future<Either<Failure, void>> updateUser(String id, UserInput input);
  Future<Either<Failure, void>> deleteUser(String id);
  Future<Either<Failure, void>> resetPassword(String id, String password);
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, void>> updateProfile({
    required String email,
    String? fullName,
    String? phone,
  });
  Future<Either<Failure, void>> changeOwnPassword(
      String currentPassword, String newPassword);
}