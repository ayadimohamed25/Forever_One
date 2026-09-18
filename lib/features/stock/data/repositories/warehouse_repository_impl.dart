import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../datasources/warehouse_remote_datasource.dart';
import '../models/warehouse_model.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final WarehouseRemoteDatasource remote;
  WarehouseRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<WarehouseEntity>>> getWarehouses({String? search}) async {
    try {
      final data = await remote.getWarehouses(search: search);
      return Right(data
          .whereType<Map>()
          .map((j) => WarehouseModel.fromJson(Map<String, dynamic>.from(j)))
          .toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load warehouses')));
    }
  }

  @override
  Future<Either<Failure, WarehouseEntity>> createWarehouse(WarehouseInput input) async {
    try {
      final data = await remote.createWarehouse(input.toJson());
      return Right(WarehouseModel.fromJson(Map<String, dynamic>.from(data)));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to create warehouse')));
    }
  }

  @override
  Future<Either<Failure, void>> updateWarehouse(String id, WarehouseInput input) async {
    try {
      await remote.updateWarehouse({'id': id, ...input.toJson()});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to update warehouse')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWarehouse(String id) async {
    try {
      await remote.deleteWarehouse(id);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('WAREHOUSE_IN_USE'));
      }
      return Left(ServerFailure(_err(e, 'Failed to delete warehouse')));
    }
  }

  String _err(DioException e, String fallback) {
    return e.response?.data is Map
        ? (e.response?.data['error'] ?? fallback)
        : '$fallback — check your connection';
  }
}