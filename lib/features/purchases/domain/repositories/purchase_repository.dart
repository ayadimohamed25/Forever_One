import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/purchase_entity.dart';
import '../entities/purchase_line_entity.dart';

abstract class PurchaseRepository {
  Future<Either<Failure, List<PurchaseEntity>>> getPurchases();
  Future<Either<Failure, double>> createPurchase({
    required String supplierId,
    required String warehouseId,
    required List<PurchaseLineEntity> lines,
  });
}