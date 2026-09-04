import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/balance_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/balance_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDatasource remote;
  PaymentRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, BalanceEntity>> getSaleBalance(String saleId) async {
    try {
      final data = await remote.getSaleBalance(saleId);
      return Right(BalanceModel.fromJson(data).toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e, 'Failed to load balance')));
    }
  }

  @override
  Future<Either<Failure, BalanceEntity>> getPurchaseBalance(String purchaseId) async {
    try {
      final data = await remote.getPurchaseBalance(purchaseId);
      return Right(BalanceModel.fromJson(data).toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e, 'Failed to load balance')));
    }
  }

  @override
  Future<Either<Failure, BalanceEntity>> recordPayment({
    String? saleId,
    String? purchaseId,
    required double amount,
    required String method,
  }) async {
    try {
      final data = await remote.recordPayment({
        'sale_id': saleId,
        'purchase_id': purchaseId,
        'amount': amount,
        'method': method,
      });
      return Right(BalanceModel.fromJson(data['balance']).toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e, 'Failed to record payment')));
    }
  }

  String _extractError(DioException e, String fallback) {
    return e.response?.data is Map ? (e.response?.data['error'] ?? fallback) : '$fallback — check your connection';
  }
}