import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class StockMovementRepository {
  Future<Either<Failure, int>> recordMovement({
    required String productId,
    required String warehouseId,
    required String type,
    required int quantity,
    String? note,
  });
}