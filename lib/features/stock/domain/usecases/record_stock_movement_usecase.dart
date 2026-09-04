import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/stock_movement_repository.dart';

class RecordStockMovementUseCase {
  final StockMovementRepository repository;
  RecordStockMovementUseCase(this.repository);

  Future<Either<Failure, int>> call({
    required String productId,
    required String warehouseId,
    required String type,
    required int quantity,
    String? note,
  }) {
    return repository.recordMovement(
      productId: productId,
      warehouseId: warehouseId,
      type: type,
      quantity: quantity,
      note: note,
    );
  }
}