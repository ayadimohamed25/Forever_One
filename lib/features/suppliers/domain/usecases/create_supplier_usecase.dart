import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

class CreateSupplierUseCase {
  final SupplierRepository repository;
  CreateSupplierUseCase(this.repository);

  Future<Either<Failure, SupplierEntity>> call({
    required String name,
    String? phone,
    String? email,
    required int leadTimeDays,
  }) {
    return repository.createSupplier(
      name: name, phone: phone, email: email, leadTimeDays: leadTimeDays,
    );
  }
}