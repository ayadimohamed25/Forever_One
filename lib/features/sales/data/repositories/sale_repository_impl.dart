import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/sale_line_entity.dart';
import '../../domain/repositories/sale_repository.dart';
import '../datasources/sale_remote_datasource.dart';
import '../models/sale_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SaleRemoteDatasource remote;
  SaleRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<SaleEntity>>> getSales() async {
    try {
      final data = await remote.getSales();
      return Right(data.map((j) => SaleModel.fromJson(j).toEntity()).toList());
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to load sales')
          : 'Failed to load sales — check your connection';
      return Left(ServerFailure(message));
    }
  }

  @override
  Future<Either<Failure, double>> createSale({
    required String customerId,
    required String warehouseId,
    required List<SaleLineEntity> lines,
  }) async {
    try {
      final data = await remote.createSale({
        'customer_id': customerId,
        'warehouse_id': warehouseId,
        'lines': lines
            .map((l) => {
          'product_id': l.productId,
          'quantity': l.quantity,
          'unit_price': l.unitPrice,
        })
            .toList(),
      });
      return Right(double.parse(data['total'].toString()));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to create sale')
          : 'Failed to create sale — check your connection';
      return Left(ServerFailure(message));
    }
  }
}