import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers();
  Future<Either<Failure, CustomerEntity>> createCustomer({
    required String name,
    String? phone,
    String? email,
    required double creditLimit,
  });
}