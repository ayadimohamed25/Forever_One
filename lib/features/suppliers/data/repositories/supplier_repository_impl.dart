import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_remote_datasource.dart';
import '../models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDatasource remote;
  SupplierRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers() async {
    try {
      final data = await remote.getSuppliers();
      return Right(data.map((j) => SupplierModel.fromJson(j).toEntity()).toList());
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to load suppliers')
          : 'Failed to load suppliers — check your connection';
      return Left(ServerFailure(message));
    }
  }

  @override
  Future<Either<Failure, SupplierEntity>> createSupplier({
    required String name,
    String? phone,
    String? email,
    required int leadTimeDays,
  }) async {
    try {
      final data = await remote.createSupplier({
        'name': name, 'phone': phone, 'email': email, 'lead_time_days': leadTimeDays,
      });
      return Right(SupplierModel.fromJson(data).toEntity());
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to create supplier')
          : 'Failed to create supplier — check your connection';
      return Left(ServerFailure(message));
    }
  }
}