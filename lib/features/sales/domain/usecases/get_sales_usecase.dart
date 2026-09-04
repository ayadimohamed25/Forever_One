import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sale_entity.dart';
import '../repositories/sale_repository.dart';

class GetSalesUseCase {
  final SaleRepository repository;
  GetSalesUseCase(this.repository);

  Future<Either<Failure, List<SaleEntity>>> call() {
    return repository.getSales();
  }
}