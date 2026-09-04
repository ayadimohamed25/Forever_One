import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/balance_entity.dart';
import '../../domain/usecases/record_payment_usecase.dart';

final paymentRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return PaymentRepositoryImpl(PaymentRemoteDatasource(dio));
});

final recordPaymentUseCaseProvider = Provider((ref) => RecordPaymentUseCase(ref.read(paymentRepositoryProvider)));

class PaymentState {
  final bool isLoading;
  final BalanceEntity? balance;
  final String? error;
  const PaymentState({this.isLoading = false, this.balance, this.error});
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepositoryImpl repository;
  final RecordPaymentUseCase recordPayment;
  PaymentNotifier(this.repository, this.recordPayment) : super(const PaymentState());

  Future<void> loadSaleBalance(String saleId) async {
    state = const PaymentState(isLoading: true);
    final result = await repository.getSaleBalance(saleId);
    result.fold(
          (failure) => state = PaymentState(error: failure.message),
          (balance) => state = PaymentState(balance: balance),
    );
  }

  Future<void> loadPurchaseBalance(String purchaseId) async {
    state = const PaymentState(isLoading: true);
    final result = await repository.getPurchaseBalance(purchaseId);
    result.fold(
          (failure) => state = PaymentState(error: failure.message),
          (balance) => state = PaymentState(balance: balance),
    );
  }

  Future<void> pay({String? saleId, String? purchaseId, required double amount, required String method}) async {
    final result = await recordPayment(saleId: saleId, purchaseId: purchaseId, amount: amount, method: method);
    result.fold(
          (failure) => state = PaymentState(balance: state.balance, error: failure.message),
          (balance) => state = PaymentState(balance: balance),
    );
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref.read(paymentRepositoryProvider), ref.read(recordPaymentUseCaseProvider));
});