import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/purchase_remote_datasource.dart';
import '../../data/repositories/purchase_repository_impl.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/entities/purchase_line_entity.dart';

final purchaseRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return PurchaseRepositoryImpl(PurchaseRemoteDatasource(dio));
});

class PurchaseListState {
  final bool isLoading;
  final List<PurchaseEntity> purchases;
  final String? error;
  final double? lastTotal;
  final String searchQuery;
  final bool hasSearched;

  const PurchaseListState({
    this.isLoading = false,
    this.purchases = const [],
    this.error,
    this.lastTotal,
    this.searchQuery = '',
    this.hasSearched = false,
  });
}

class PurchaseListNotifier extends StateNotifier<PurchaseListState> {
  final PurchaseRepositoryImpl repository;
  PurchaseListNotifier(this.repository) : super(const PurchaseListState());

  Future<void> load({String? search}) async {
    final query = search ?? state.searchQuery;
    state = PurchaseListState(
      isLoading: true,
      purchases: state.purchases,
      searchQuery: query,
      hasSearched: query.isNotEmpty,
    );

    final result = await repository.getPurchases(search: query);
    result.fold(
          (failure) => state = PurchaseListState(
          error: failure.message,
          searchQuery: query,
          hasSearched: query.isNotEmpty),
          (purchases) => state = PurchaseListState(
          purchases: purchases,
          searchQuery: query,
          hasSearched: query.isNotEmpty),
    );
  }

  Future<void> search(String query) => load(search: query);
  Future<void> clearSearch() => load(search: '');

  Future<void> submit({
    required String supplierId,
    required String warehouseId,
    String? reference,
    String? notes,
    required String status,
    required List<PurchaseLineEntity> lines,
  }) async {
    final result = await repository.createPurchase(
      supplierId: supplierId,
      warehouseId: warehouseId,
      reference: reference,
      notes: notes,
      status: status,
      lines: lines,
    );

    if (result.isLeft()) {
      state = PurchaseListState(
        purchases: state.purchases,
        error: result.fold((f) => f.message, (_) => ''),
        searchQuery: state.searchQuery,
      );
      return;
    }

    final totals = result.fold((_) => null, (t) => t);
    state = PurchaseListState(
        purchases: state.purchases,
        lastTotal: totals?.total,
        searchQuery: state.searchQuery);
    await load();
  }

  Future<String?> edit({
    required String id,
    required String supplierId,
    required String warehouseId,
    String? reference,
    String? notes,
    required List<PurchaseLineEntity> lines,
  }) async {
    final result = await repository.updatePurchase(
      id: id,
      supplierId: supplierId,
      warehouseId: warehouseId,
      reference: reference,
      notes: notes,
      lines: lines,
    );

    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }

  Future<String?> remove(String id) async {
    final result = await repository.deletePurchase(id);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }

  Future<String?> receive(String id) async {
    final result = await repository.receivePurchase(id);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }
}

final purchaseListProvider =
StateNotifierProvider<PurchaseListNotifier, PurchaseListState>((ref) {
  return PurchaseListNotifier(ref.read(purchaseRepositoryProvider));
});