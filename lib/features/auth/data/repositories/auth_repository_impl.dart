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
      final user = UserModel.fromJson(data['user']);
      return Right(user.toEntity());
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
}