import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/warehouse_remote_datasource.dart';
import '../../data/repositories/warehouse_repository_impl.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/repositories/warehouse_repository.dart';

final warehouseRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return WarehouseRepositoryImpl(WarehouseRemoteDatasource(dio));
});

class WarehouseListState {
  final bool isLoading;
  final List<WarehouseEntity> warehouses;
  final String? error;
  final String searchQuery;
  final bool hasSearched;

  const WarehouseListState({
    this.isLoading = false,
    this.warehouses = const [],
    this.error,
    this.searchQuery = '',
    this.hasSearched = false,
  });
}

class WarehouseListNotifier extends StateNotifier<WarehouseListState> {
  final WarehouseRepositoryImpl repository;
  WarehouseListNotifier(this.repository) : super(const WarehouseListState());

  Future<void> load({String? search}) async {
    final query = search ?? state.searchQuery;
    state = WarehouseListState(
      isLoading: true,
      warehouses: state.warehouses,
      searchQuery: query,
      hasSearched: query.isNotEmpty,
    );

    final result = await repository.getWarehouses(search: query);
    result.fold(
          (failure) => state = WarehouseListState(
          error: failure.message,
          searchQuery: query,
          hasSearched: query.isNotEmpty),
          (warehouses) => state = WarehouseListState(
          warehouses: warehouses,
          searchQuery: query,
          hasSearched: query.isNotEmpty),
    );
  }

  Future<void> search(String query) => load(search: query);
  Future<void> clearSearch() => load(search: '');

  Future<void> add(WarehouseInput input) async {
    final result = await repository.createWarehouse(input);
    if (result.isLeft()) {
      state = WarehouseListState(
        warehouses: state.warehouses,
        error: result.fold((f) => f.message, (_) => ''),
      );
      return;
    }
    await load();
  }

  Future<void> update(String id, WarehouseInput input) async {
    final result = await repository.updateWarehouse(id, input);
    if (result.isLeft()) {
      state = WarehouseListState(
        warehouses: state.warehouses,
        error: result.fold((f) => f.message, (_) => ''),
      );
      return;
    }
    await load();
  }

  Future<String?> remove(String id) async {
    final result = await repository.deleteWarehouse(id);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }
}

final warehouseListProvider =
StateNotifierProvider<WarehouseListNotifier, WarehouseListState>((ref) {
  return WarehouseListNotifier(ref.read(warehouseRepositoryProvider));
});