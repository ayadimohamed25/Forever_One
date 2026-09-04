import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sale_entity.dart';
import '../entities/sale_line_entity.dart';

abstract class SaleRepository {
  Future<Either<Failure, List<SaleEntity>>> getSales();
  Future<Either<Failure, double>> createSale({
    required String customerId,
    required String warehouseId,
    required List<SaleLineEntity> lines,
  });
}