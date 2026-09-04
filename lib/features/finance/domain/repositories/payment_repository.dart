import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/balance_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, BalanceEntity>> getSaleBalance(String saleId);
  Future<Either<Failure, BalanceEntity>> getPurchaseBalance(String purchaseId);
  Future<Either<Failure, BalanceEntity>> recordPayment({
    String? saleId,
    String? purchaseId,
    required double amount,
    required String method,
  });
}