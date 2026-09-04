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
  Future<Either<Failure, List<WarehouseEntity>>> getWarehouses() async {
    try {
      final data = await remote.getWarehouses();
      final warehouses = data
          .map((json) => WarehouseModel.fromJson(json).toEntity())
          .toList();
      return Right(warehouses);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to load warehouses')
          : 'Failed to load warehouses — check your connection';
      return Left(ServerFailure(message));
    }
  }
}