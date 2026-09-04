import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/warehouse_remote_datasource.dart';
import '../../data/repositories/warehouse_repository_impl.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/usecases/get_warehouses_usecase.dart';

final warehouseRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return WarehouseRepositoryImpl(WarehouseRemoteDatasource(dio));
});

final getWarehousesUseCaseProvider = Provider((ref) {
  return GetWarehousesUseCase(ref.read(warehouseRepositoryProvider));
});

class WarehouseListState {
  final bool isLoading;
  final List<WarehouseEntity> warehouses;
  final String? error;
  const WarehouseListState({
    this.isLoading = false,
    this.warehouses = const [],
    this.error,
  });
}

class WarehouseListNotifier extends StateNotifier<WarehouseListState> {
  final GetWarehousesUseCase getWarehouses;
  WarehouseListNotifier(this.getWarehouses) : super(const WarehouseListState());

  Future<void> load() async {
    state = const WarehouseListState(isLoading: true);
    final result = await getWarehouses();
    result.fold(
          (failure) => state = WarehouseListState(error: failure.message),
          (warehouses) => state = WarehouseListState(warehouses: warehouses),
    );
  }
}

final warehouseListProvider =
StateNotifierProvider<WarehouseListNotifier, WarehouseListState>((ref) {
  return WarehouseListNotifier(ref.read(getWarehousesUseCaseProvider));
});