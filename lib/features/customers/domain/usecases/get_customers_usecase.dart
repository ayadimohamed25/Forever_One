import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;
  GetCustomersUseCase(this.repository);

  Future<Either<Failure, List<CustomerEntity>>> call() {
    return repository.getCustomers();
  }
}