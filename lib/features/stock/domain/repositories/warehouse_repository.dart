import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/warehouse_entity.dart';

abstract class WarehouseRepository {
  Future<Either<Failure, List<WarehouseEntity>>> getWarehouses();
}