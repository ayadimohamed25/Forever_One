import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDatasource remote;
  CustomerRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers() async {
    try {
      final data = await remote.getCustomers();
      return Right(data.map((j) => CustomerModel.fromJson(j).toEntity()).toList());
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to load customers')
          : 'Failed to load customers — check your connection';
      return Left(ServerFailure(message));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer({
    required String name,
    String? phone,
    String? email,
    required double creditLimit,
  }) async {
    try {
      final data = await remote.createCustomer({
        'name': name, 'phone': phone, 'email': email, 'credit_limit': creditLimit,
      });
      return Right(CustomerModel.fromJson(data).toEntity());
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to create customer')
          : 'Failed to create customer — check your connection';
      return Left(ServerFailure(message));
    }
  }
}