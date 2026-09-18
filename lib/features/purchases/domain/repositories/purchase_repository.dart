import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/purchase_entity.dart';
import '../entities/purchase_line_entity.dart';

typedef PurchaseTotals = ({double subtotalHt, double totalVat, double total});
typedef PurchaseDetail = ({
PurchaseEntity purchase,
List<PurchaseLineEntity> lines
});

abstract class PurchaseRepository {
  Future<Either<Failure, List<PurchaseEntity>>> getPurchases({String? search});
  Future<Either<Failure, PurchaseDetail>> getPurchaseDetail(String id);
  Future<Either<Failure, PurchaseTotals>> createPurchase({
    required String supplierId,
    required String warehouseId,
    String? reference,
    String? notes,
    required String status,
    required List<PurchaseLineEntity> lines,
  });
  Future<Either<Failure, void>> updatePurchase({
    required String id,
    required String supplierId,
    required String warehouseId,
    String? reference,
    String? notes,
    required List<PurchaseLineEntity> lines,
  });
  Future<Either<Failure, void>> deletePurchase(String id);
  Future<Either<Failure, void>> receivePurchase(String id);
}