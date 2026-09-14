import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/supplier_purchase_entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_remote_datasource.dart';
import '../models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDatasource remote;
  SupplierRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers({String? search}) async {
    try {
      final data = await remote.getSuppliers(search: search);
      return Right(data.map((j) => SupplierModel.fromJson(j).toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load suppliers')));
    }
  }

  @override
  Future<Either<Failure, SupplierDetail>> getSupplierDetail(String id) async {
    try {
      final data = await remote.getSupplierDetail(id);
      final supplier = SupplierModel.fromJson(data['supplier']).toEntity();
      final purchases = (data['purchases'] as List)
          .map((p) => SupplierPurchaseEntity(
        id: p['id'],
        reference: p['reference'],
        total: double.parse((p['total'] ?? 0).toString()),
        paid: double.parse((p['paid'] ?? 0).toString()),
        status: p['status'] ?? '',
        createdAt: DateTime.tryParse(p['created_at'].toString()) ??
            DateTime.now(),
        expectedDate: p['expected_date'] != null
            ? DateTime.tryParse(p['expected_date'].toString())
            : null,
        receivedDate: p['received_date'] != null
            ? DateTime.tryParse(p['received_date'].toString())
            : null,
      ))
          .toList();
      return Right((supplier: supplier, purchases: purchases));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load supplier')));
    }
  }

  @override
  Future<Either<Failure, SupplierEntity>> createSupplier(SupplierInput input) async {
    try {
      final data = await remote.createSupplier(input.toJson());
      return Right(SupplierModel.fromJson(data).toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to create supplier')));
    }
  }

  @override
  Future<Either<Failure, void>> updateSupplier(String id, SupplierInput input) async {
    try {
      await remote.updateSupplier({'id': id, ...input.toJson()});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to update supplier')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSupplier(String id) async {
    try {
      await remote.deleteSupplier(id);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('SUPPLIER_IN_USE'));
      }
      return Left(ServerFailure(_err(e, 'Failed to delete supplier')));
    }
  }

  String _err(DioException e, String fallback) {
    return e.response?.data is Map
        ? (e.response?.data['error'] ?? fallback)
        : '$fallback — check your connection';
  }
}