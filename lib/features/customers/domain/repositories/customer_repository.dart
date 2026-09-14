import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';
import '../entities/customer_sale_entity.dart';

typedef CustomerDetail = ({CustomerEntity customer, List<CustomerSaleEntity> sales});

class CustomerInput {
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final CustomerType customerType;
  final int paymentTermsDays;
  final String? notes;
  final double creditLimit;

  const CustomerInput({
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.customerType = CustomerType.company,
    this.paymentTermsDays = 0,
    this.notes,
    this.creditLimit = 0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'tax_id': taxId,
    'customer_type': customerType.name,
    'payment_terms_days': paymentTermsDays,
    'notes': notes,
    'credit_limit': creditLimit,
  };
}

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({String? search});
  Future<Either<Failure, CustomerDetail>> getCustomerDetail(String id);
  Future<Either<Failure, CustomerEntity>> createCustomer(CustomerInput input);
  Future<Either<Failure, void>> updateCustomer(String id, CustomerInput input);
  Future<Either<Failure, void>> deleteCustomer(String id);
}