import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final _storage = const FlutterSecureStorage();

  AuthRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final data = await remote.login(email, password);
      await _storage.write(key: 'auth_token', value: data['token']);

      return Right(UserModel.fromJson(Map<String, dynamic>.from(data['user'])));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Login failed')
          : 'Login failed — check your connection';
      return Left(AuthFailure(message));
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  @override
  Future<Either<Failure, UserEntity>> restoreSession() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      return const Left(SessionExpiredFailure());
    }
    try {
      final data = await remote.profile();
      final merged = Map<String, dynamic>.from(data['user']);
      merged['permissions'] = data['permissions'] ?? [];
      return Right(UserModel.fromJson(merged));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        // Only a rejected token ends the session. A network error keeps it.
        await _storage.delete(key: 'auth_token');
        return const Left(SessionExpiredFailure());
      }
      return const Left(NetworkFailure());
    }
  }
  @override
  Future<Either<Failure, UserEntity>> register({
    required String companyName,
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? city,
  }) async {
    try {
      final data = await remote.register({
        'company_name': companyName,
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'city': city,
      });
      await _storage.write(key: 'auth_token', value: data['token']);
      return Right(UserModel.fromJson(Map<String, dynamic>.from(data['user'])));
    } on DioException catch (e) {
      final code = e.response?.data is Map
          ? '${e.response?.data['error'] ?? 'REGISTRATION_FAILED'}'
          : 'REGISTRATION_FAILED';
      return Left(AuthFailure(code));
    }
  }
}