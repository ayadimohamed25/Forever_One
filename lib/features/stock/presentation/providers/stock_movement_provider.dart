import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/stock_movement_remote_datasource.dart';
import '../../data/repositories/stock_movement_repository_impl.dart';
import '../../domain/usecases/record_stock_movement_usecase.dart';

final stockMovementRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return StockMovementRepositoryImpl(StockMovementRemoteDatasource(dio));
});

final recordStockMovementUseCaseProvider = Provider((ref) {
  return RecordStockMovementUseCase(ref.read(stockMovementRepositoryProvider));
});

class StockMovementState {
  final bool isLoading;
  final int? lastCurrentStock;
  final String? error;
  const StockMovementState({this.isLoading = false, this.lastCurrentStock, this.error});
}

class StockMovementNotifier extends StateNotifier<StockMovementState> {
  final RecordStockMovementUseCase recordMovement;
  StockMovementNotifier(this.recordMovement) : super(const StockMovementState());

  Future<void> record({
    required String productId,
    required String warehouseId,
    required String type,
    required int quantity,
    String? note,
  }) async {
    state = const StockMovementState(isLoading: true);
    final result = await recordMovement(
      productId: productId,
      warehouseId: warehouseId,
      type: type,
      quantity: quantity,
      note: note,
    );
    result.fold(
          (failure) => state = StockMovementState(error: failure.message),
          (currentStock) => state = StockMovementState(lastCurrentStock: currentStock),
    );
  }
}

final stockMovementProvider =
StateNotifierProvider<StockMovementNotifier, StockMovementState>((ref) {
  return StockMovementNotifier(ref.read(recordStockMovementUseCaseProvider));
});