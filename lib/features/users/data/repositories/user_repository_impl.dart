import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource remote;
  UserRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers({String? search}) async {
    try {
      final data = await remote.getUsers(search: search);
      return Right(data
          .whereType<Map>()
          .map((j) => UserModel.fromJson(Map<String, dynamic>.from(j)))
          .toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load users')));
    }
  }

  @override
  Future<Either<Failure, void>> createUser(UserInput input) async {
    try {
      await remote.createUser(input.toJson());
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_code(e, 'Failed to create user')));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(String id, UserInput input) async {
    try {
      await remote.updateUser({'id': id, ...input.toJson()});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_code(e, 'Failed to update user')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String id) async {
    try {
      await remote.deleteUser(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_code(e, 'Failed to delete user')));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String id, String password) async {
    try {
      await remote.resetPassword(id, password);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_code(e, 'Failed to reset password')));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final data = await remote.getProfile();
      final merged = Map<String, dynamic>.from(data['user']);
      merged['permissions'] = data['permissions'] ?? [];
      return Right(UserModel.fromJson(merged));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load profile')));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String email,
    String? fullName,
    String? phone,
  }) async {
    try {
      await remote.updateProfile({
        'email': email,
        'full_name': fullName,
        'phone': phone,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_code(e, 'Failed to update profile')));
    }
  }

  @override
  Future<Either<Failure, void>> changeOwnPassword(
      String currentPassword, String newPassword) async {
    try {
      await remote.changeOwnPassword(currentPassword, newPassword);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_code(e, 'Failed to change password')));
    }
  }

  /// Returns the backend's error code so the UI can translate it.
  String _code(DioException e, String fallback) {
    if (e.response?.data is Map && e.response?.data['error'] != null) {
      return '${e.response?.data['error']}';
    }
    return fallback;
  }

  String _err(DioException e, String fallback) {
    return e.response?.data is Map
        ? (e.response?.data['error'] ?? fallback)
        : '$fallback — check your connection';
  }
}