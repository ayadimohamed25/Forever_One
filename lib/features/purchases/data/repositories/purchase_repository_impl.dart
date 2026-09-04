import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/entities/purchase_line_entity.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_remote_datasource.dart';
import '../models/purchase_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseRemoteDatasource remote;
  PurchaseRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<PurchaseEntity>>> getPurchases() async {
    try {
      final data = await remote.getPurchases();
      return Right(data.map((j) => PurchaseModel.fromJson(j).toEntity()).toList());
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to load purchases')
          : 'Failed to load purchases — check your connection';
      return Left(ServerFailure(message));
    }
  }

  @override
  Future<Either<Failure, double>> createPurchase({
    required String supplierId,
    required String warehouseId,
    required List<PurchaseLineEntity> lines,
  }) async {
    try {
      final data = await remote.createPurchase({
        'supplier_id': supplierId,
        'warehouse_id': warehouseId,
        'lines': lines
            .map((l) => {
          'product_id': l.productId,
          'quantity': l.quantity,
          'unit_cost': l.unitCost,
        })
            .toList(),
      });
      return Right(double.parse(data['total'].toString()));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to create purchase')
          : 'Failed to create purchase — check your connection';
      return Left(ServerFailure(message));
    }
  }
}