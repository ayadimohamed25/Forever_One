import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/purchase_remote_datasource.dart';
import '../../data/repositories/purchase_repository_impl.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/entities/purchase_line_entity.dart';
import '../../domain/usecases/create_purchase_usecase.dart';
import '../../domain/usecases/get_purchases_usecase.dart';

final purchaseRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return PurchaseRepositoryImpl(PurchaseRemoteDatasource(dio));
});

final getPurchasesUseCaseProvider = Provider((ref) => GetPurchasesUseCase(ref.read(purchaseRepositoryProvider)));
final createPurchaseUseCaseProvider = Provider((ref) => CreatePurchaseUseCase(ref.read(purchaseRepositoryProvider)));

class PurchaseListState {
  final bool isLoading;
  final List<PurchaseEntity> purchases;
  final String? error;
  final double? lastTotal;
  const PurchaseListState({this.isLoading = false, this.purchases = const [], this.error, this.lastTotal});
}

class PurchaseListNotifier extends StateNotifier<PurchaseListState> {
  final GetPurchasesUseCase getPurchases;
  final CreatePurchaseUseCase createPurchase;
  PurchaseListNotifier(this.getPurchases, this.createPurchase) : super(const PurchaseListState());

  Future<void> load() async {
    state = const PurchaseListState(isLoading: true);
    final result = await getPurchases();
    result.fold(
          (failure) => state = PurchaseListState(error: failure.message),
          (purchases) => state = PurchaseListState(purchases: purchases),
    );
  }

  Future<void> submit({
    required String supplierId,
    required String warehouseId,
    required List<PurchaseLineEntity> lines,
  }) async {
    final result = await createPurchase(supplierId: supplierId, warehouseId: warehouseId, lines: lines);
    result.fold(
          (failure) => state = PurchaseListState(purchases: state.purchases, error: failure.message),
          (total) async {
        state = PurchaseListState(purchases: state.purchases, lastTotal: total);
        await load();
      },
    );
  }
}

final purchaseListProvider = StateNotifierProvider<PurchaseListNotifier, PurchaseListState>((ref) {
  return PurchaseListNotifier(ref.read(getPurchasesUseCaseProvider), ref.read(createPurchaseUseCaseProvider));
});