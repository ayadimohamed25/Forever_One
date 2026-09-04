import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sale_line_entity.dart';
import '../repositories/sale_repository.dart';

class CreateSaleUseCase {
  final SaleRepository repository;
  CreateSaleUseCase(this.repository);

  Future<Either<Failure, double>> call({
    required String customerId,
    required String warehouseId,
    required List<SaleLineEntity> lines,
  }) {
    return repository.createSale(customerId: customerId, warehouseId: warehouseId, lines: lines);
  }
}