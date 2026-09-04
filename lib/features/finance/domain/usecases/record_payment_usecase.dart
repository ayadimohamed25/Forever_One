import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/balance_entity.dart';
import '../repositories/payment_repository.dart';

class RecordPaymentUseCase {
  final PaymentRepository repository;
  RecordPaymentUseCase(this.repository);

  Future<Either<Failure, BalanceEntity>> call({
    String? saleId,
    String? purchaseId,
    required double amount,
    required String method,
  }) {
    return repository.recordPayment(saleId: saleId, purchaseId: purchaseId, amount: amount, method: method);
  }
}