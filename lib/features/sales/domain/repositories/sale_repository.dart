import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sale_entity.dart';
import '../entities/sale_line_entity.dart';

typedef SaleTotals = ({double subtotalHt, double totalVat, double total});
typedef SaleDetail = ({SaleEntity sale, List<SaleLineEntity> lines});

abstract class SaleRepository {
  Future<Either<Failure, List<SaleEntity>>> getSales({String? search});
  Future<Either<Failure, SaleDetail>> getSaleDetail(String id);
  Future<Either<Failure, SaleTotals>> createSale({
    required String customerId,
    required String warehouseId,
    String? reference,
    String? notes,
    required List<SaleLineEntity> lines,
  });
  Future<Either<Failure, void>> updateSale({
    required String id,
    required String customerId,
    required String warehouseId,
    String? reference,
    String? notes,
    required List<SaleLineEntity> lines,
  });
  Future<Either<Failure, void>> deleteSale(String id);
}