import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/supplier_remote_datasource.dart';
import '../../data/repositories/supplier_repository_impl.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/supplier_purchase_entity.dart';
import '../../domain/repositories/supplier_repository.dart';

final supplierRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return SupplierRepositoryImpl(SupplierRemoteDatasource(dio));
});

class SupplierListState {
  final bool isLoading;
  final List<SupplierEntity> suppliers;
  final String? error;
  final String searchQuery;
  final bool hasSearched;

  const SupplierListState({
    this.isLoading = false,
    this.suppliers = const [],
    this.error,
    this.searchQuery = '',
    this.hasSearched = false,
  });

  SupplierListState copyWith({
    bool? isLoading,
    List<SupplierEntity>? suppliers,
    String? error,
    String? searchQuery,
    bool? hasSearched,
  }) {
    return SupplierListState(
      isLoading: isLoading ?? this.isLoading,
      suppliers: suppliers ?? this.suppliers,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class SupplierListNotifier extends StateNotifier<SupplierListState> {
  final SupplierRepositoryImpl repository;
  SupplierListNotifier(this.repository) : super(const SupplierListState());

  Future<void> load({String? search}) async {
    final query = search ?? state.searchQuery;
    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      hasSearched: query.isNotEmpty,
    );

    final result = await repository.getSuppliers(search: query);
    result.fold(
          (failure) =>
      state = state.copyWith(isLoading: false, error: failure.message),
          (suppliers) =>
      state = state.copyWith(isLoading: false, suppliers: suppliers),
    );
  }

  Future<void> search(String query) => load(search: query);
  Future<void> clearSearch() => load(search: '');

  Future<void> add(SupplierInput input) async {
    final result = await repository.createSupplier(input);
    if (result.isLeft()) {
      state = state.copyWith(error: result.fold((f) => f.message, (_) => ''));
      return;
    }
    await load();
  }

  Future<void> update(String id, SupplierInput input) async {
    final result = await repository.updateSupplier(id, input);
    if (result.isLeft()) {
      state = state.copyWith(error: result.fold((f) => f.message, (_) => ''));
      return;
    }
    await load();
  }

  Future<String?> remove(String id) async {
    final result = await repository.deleteSupplier(id);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }
}

final supplierListProvider =
StateNotifierProvider<SupplierListNotifier, SupplierListState>((ref) {
  return SupplierListNotifier(ref.read(supplierRepositoryProvider));
});

// ---------- Detail ----------

class SupplierDetailState {
  final bool isLoading;
  final SupplierEntity? supplier;
  final List<SupplierPurchaseEntity> purchases;
  final String? error;

  const SupplierDetailState({
    this.isLoading = false,
    this.supplier,
    this.purchases = const [],
    this.error,
  });
}

class SupplierDetailNotifier extends StateNotifier<SupplierDetailState> {
  final SupplierRepositoryImpl repository;
  SupplierDetailNotifier(this.repository) : super(const SupplierDetailState());

  Future<void> load(String id) async {
    state = const SupplierDetailState(isLoading: true);
    final result = await repository.getSupplierDetail(id);
    result.fold(
          (failure) => state = SupplierDetailState(error: failure.message),
          (detail) => state = SupplierDetailState(
        supplier: detail.supplier,
        purchases: detail.purchases,
      ),
    );
  }
}

final supplierDetailProvider =
StateNotifierProvider<SupplierDetailNotifier, SupplierDetailState>((ref) {
  return SupplierDetailNotifier(ref.read(supplierRepositoryProvider));
});