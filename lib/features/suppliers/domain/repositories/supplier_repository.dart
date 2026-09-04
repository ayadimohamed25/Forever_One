import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/supplier_entity.dart';

abstract class SupplierRepository {
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers();
  Future<Either<Failure, SupplierEntity>> createSupplier({
    required String name,
    String? phone,
    String? email,
    required int leadTimeDays,
  });
}