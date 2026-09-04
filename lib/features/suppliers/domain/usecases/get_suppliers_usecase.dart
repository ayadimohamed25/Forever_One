import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

class GetSuppliersUseCase {
  final SupplierRepository repository;
  GetSuppliersUseCase(this.repository);

  Future<Either<Failure, List<SupplierEntity>>> call() {
    return repository.getSuppliers();
  }
}