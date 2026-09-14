import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_sale_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDatasource remote;
  CustomerRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({String? search}) async {
    try {
      final data = await remote.getCustomers(search: search);
      return Right(data.map((j) => CustomerModel.fromJson(j).toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load customers')));
    }
  }

  @override
  Future<Either<Failure, CustomerDetail>> getCustomerDetail(String id) async {
    try {
      final data = await remote.getCustomerDetail(id);
      final customer = CustomerModel.fromJson(data['customer']).toEntity();
      final sales = (data['sales'] as List)
          .map((s) => CustomerSaleEntity(
        id: s['id'],
        total: double.parse((s['total'] ?? 0).toString()),
        paid: double.parse((s['paid'] ?? 0).toString()),
        status: s['status'] ?? '',
        createdAt:
        DateTime.tryParse(s['created_at'].toString()) ?? DateTime.now(),
      ))
          .toList();
      return Right((customer: customer, sales: sales));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load customer')));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer(CustomerInput input) async {
    try {
      final data = await remote.createCustomer(input.toJson());
      return Right(CustomerModel.fromJson(data).toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to create customer')));
    }
  }

  @override
  Future<Either<Failure, void>> updateCustomer(String id, CustomerInput input) async {
    try {
      await remote.updateCustomer({'id': id, ...input.toJson()});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to update customer')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      await remote.deleteCustomer(id);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('CUSTOMER_IN_USE'));
      }
      return Left(ServerFailure(_err(e, 'Failed to delete customer')));
    }
  }

  String _err(DioException e, String fallback) {
    return e.response?.data is Map
        ? (e.response?.data['error'] ?? fallback)
        : '$fallback — check your connection';
  }
}