import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/purchase_line_entity.dart';
import '../repositories/purchase_repository.dart';

class CreatePurchaseUseCase {
  final PurchaseRepository repository;
  CreatePurchaseUseCase(this.repository);

  Future<Either<Failure, double>> call({
    required String supplierId,
    required String warehouseId,
    required List<PurchaseLineEntity> lines,
  }) {
    return repository.createPurchase(supplierId: supplierId, warehouseId: warehouseId, lines: lines);
  }
}