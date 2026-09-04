import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/warehouse_entity.dart';
import '../repositories/warehouse_repository.dart';

class GetWarehousesUseCase {
  final WarehouseRepository repository;
  GetWarehousesUseCase(this.repository);

  Future<Either<Failure, List<WarehouseEntity>>> call() {
    return repository.getWarehouses();
  }
}