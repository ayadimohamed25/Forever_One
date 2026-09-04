import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/stock_movement_repository.dart';
import '../datasources/stock_movement_remote_datasource.dart';

class StockMovementRepositoryImpl implements StockMovementRepository {
  final StockMovementRemoteDatasource remote;
  StockMovementRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, int>> recordMovement({
    required String productId,
    required String warehouseId,
    required String type,
    required int quantity,
    String? note,
  }) async {
    try {
      final data = await remote.recordMovement({
        'product_id': productId,
        'warehouse_id': warehouseId,
        'type': type,
        'quantity': quantity,
        'note': note,
      });
      return Right(data['current_stock'] as int);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to record movement')
          : 'Failed to record movement — check your connection';
      return Left(ServerFailure(message));
    }
  }
}