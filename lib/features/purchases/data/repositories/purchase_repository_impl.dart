import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/entities/purchase_line_entity.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_remote_datasource.dart';
import '../models/purchase_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseRemoteDatasource remote;
  PurchaseRepositoryImpl(this.remote);

  List<Map<String, dynamic>> _lineJson(List<PurchaseLineEntity> lines) => lines
      .map((l) => {
    'product_id': l.productId,
    'quantity': l.quantity,
    'unit_cost': l.unitCost,
    'vat_rate': l.vatRate,
  })
      .toList();

  @override
  Future<Either<Failure, List<PurchaseEntity>>> getPurchases({String? search}) async {
    try {
      final data = await remote.getPurchases(search: search);
      return Right(data
          .whereType<Map>()
          .map((j) => PurchaseModel.fromJson(Map<String, dynamic>.from(j)))
          .toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load purchases')));
    }
  }

  @override
  Future<Either<Failure, PurchaseDetail>> getPurchaseDetail(String id) async {
    try {
      final data = await remote.getPurchaseDetail(id);
      final purchase =
      PurchaseModel.fromJson(Map<String, dynamic>.from(data['purchase']));
      final lines = ((data['lines'] ?? []) as List)
          .whereType<Map>()
          .map((l) => PurchaseLineEntity(
        productId: '${l['product_id']}',
        productName: '${l['product_name'] ?? ''}',
        quantity: int.tryParse('${l['quantity'] ?? 0}') ?? 0,
        unitCost: double.tryParse('${l['unit_cost'] ?? 0}') ?? 0,
        vatRate: double.tryParse('${l['vat_rate'] ?? 0}') ?? 0,
      ))
          .toList();
      return Right((purchase: purchase, lines: lines));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load purchase')));
    }
  }

  @override
  Future<Either<Failure, PurchaseTotals>> createPurchase({
    required String supplierId,
    required String warehouseId,
    String? reference,
    String? notes,
    required String status,
    required List<PurchaseLineEntity> lines,
  }) async {
    try {
      final data = await remote.createPurchase({
        'supplier_id': supplierId,
        'warehouse_id': warehouseId,
        'reference': reference,
        'notes': notes,
        'status': status,
        'lines': _lineJson(lines),
      });

      return Right((
      subtotalHt: double.tryParse('${data['subtotal_ht'] ?? 0}') ?? 0,
      totalVat: double.tryParse('${data['total_vat'] ?? 0}') ?? 0,
      total: double.tryParse('${data['total'] ?? 0}') ?? 0,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to create purchase')));
    }
  }

  @override
  Future<Either<Failure, void>> updatePurchase({
    required String id,
    required String supplierId,
    required String warehouseId,
    String? reference,
    String? notes,
    required List<PurchaseLineEntity> lines,
  }) async {
    try {
      await remote.updatePurchase({
        'id': id,
        'supplier_id': supplierId,
        'warehouse_id': warehouseId,
        'reference': reference,
        'notes': notes,
        'lines': _lineJson(lines),
      });
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('PURCHASE_HAS_PAYMENTS'));
      }
      return Left(ServerFailure(_err(e, 'Failed to update purchase')));
    }
  }

  @override
  Future<Either<Failure, void>> deletePurchase(String id) async {
    try {
      await remote.deletePurchase(id);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('PURCHASE_HAS_PAYMENTS'));
      }
      return Left(ServerFailure(_err(e, 'Failed to delete purchase')));
    }
  }

  @override
  Future<Either<Failure, void>> receivePurchase(String id) async {
    try {
      await remote.receivePurchase(id);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('PURCHASE_ALREADY_RECEIVED'));
      }
      return Left(ServerFailure(_err(e, 'Failed to receive purchase')));
    }
  }

  String _err(DioException e, String fallback) {
    return e.response?.data is Map
        ? (e.response?.data['error'] ?? fallback)
        : '$fallback — check your connection';
  }
}