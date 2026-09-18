import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/sale_line_entity.dart';
import '../../domain/repositories/sale_repository.dart';
import '../datasources/sale_remote_datasource.dart';
import '../models/sale_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SaleRemoteDatasource remote;
  SaleRepositoryImpl(this.remote);

  List<Map<String, dynamic>> _lineJson(List<SaleLineEntity> lines) => lines
      .map((l) => {
    'product_id': l.productId,
    'quantity': l.quantity,
    'unit_price': l.unitPrice,
    'vat_rate': l.vatRate,
  })
      .toList();

  @override
  Future<Either<Failure, List<SaleEntity>>> getSales({String? search}) async {
    try {
      final data = await remote.getSales(search: search);
      return Right(data
          .whereType<Map>()
          .map((j) => SaleModel.fromJson(Map<String, dynamic>.from(j)))
          .toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load sales')));
    }
  }

  @override
  Future<Either<Failure, SaleDetail>> getSaleDetail(String id) async {
    try {
      final data = await remote.getSaleDetail(id);
      final sale = SaleModel.fromJson(Map<String, dynamic>.from(data['sale']));
      final lines = ((data['lines'] ?? []) as List)
          .whereType<Map>()
          .map((l) => SaleLineEntity(
        productId: '${l['product_id']}',
        productName: '${l['product_name'] ?? ''}',
        quantity: int.tryParse('${l['quantity'] ?? 0}') ?? 0,
        unitPrice: double.tryParse('${l['unit_price'] ?? 0}') ?? 0,
        vatRate: double.tryParse('${l['vat_rate'] ?? 0}') ?? 0,
      ))
          .toList();
      return Right((sale: sale, lines: lines));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load sale')));
    }
  }

  @override
  Future<Either<Failure, SaleTotals>> createSale({
    required String customerId,
    required String warehouseId,
    String? reference,
    String? notes,
    required List<SaleLineEntity> lines,
  }) async {
    try {
      final data = await remote.createSale({
        'customer_id': customerId,
        'warehouse_id': warehouseId,
        'reference': reference,
        'notes': notes,
        'lines': _lineJson(lines),
      });

      return Right((
      subtotalHt: double.tryParse('${data['subtotal_ht'] ?? 0}') ?? 0,
      totalVat: double.tryParse('${data['total_vat'] ?? 0}') ?? 0,
      total: double.tryParse('${data['total'] ?? 0}') ?? 0,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to create sale')));
    }
  }

  @override
  Future<Either<Failure, void>> updateSale({
    required String id,
    required String customerId,
    required String warehouseId,
    String? reference,
    String? notes,
    required List<SaleLineEntity> lines,
  }) async {
    try {
      await remote.updateSale({
        'id': id,
        'customer_id': customerId,
        'warehouse_id': warehouseId,
        'reference': reference,
        'notes': notes,
        'lines': _lineJson(lines),
      });
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('SALE_HAS_PAYMENTS'));
      }
      return Left(ServerFailure(_err(e, 'Failed to update sale')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSale(String id) async {
    try {
      await remote.deleteSale(id);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('SALE_HAS_PAYMENTS'));
      }
      return Left(ServerFailure(_err(e, 'Failed to delete sale')));
    }
  }

  String _err(DioException e, String fallback) {
    return e.response?.data is Map
        ? (e.response?.data['error'] ?? fallback)
        : '$fallback — check your connection';
  }
}