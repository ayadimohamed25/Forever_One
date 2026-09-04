import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class CreateCustomerUseCase {
  final CustomerRepository repository;
  CreateCustomerUseCase(this.repository);

  Future<Either<Failure, CustomerEntity>> call({
    required String name,
    String? phone,
    String? email,
    required double creditLimit,
  }) {
    return repository.createCustomer(
      name: name, phone: phone, email: email, creditLimit: creditLimit,
    );
  }
}