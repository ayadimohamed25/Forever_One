import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/sale_remote_datasource.dart';
import '../../data/repositories/sale_repository_impl.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/sale_line_entity.dart';
import '../../domain/usecases/create_sale_usecase.dart';
import '../../domain/usecases/get_sales_usecase.dart';

final saleRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return SaleRepositoryImpl(SaleRemoteDatasource(dio));
});

final getSalesUseCaseProvider = Provider((ref) => GetSalesUseCase(ref.read(saleRepositoryProvider)));
final createSaleUseCaseProvider = Provider((ref) => CreateSaleUseCase(ref.read(saleRepositoryProvider)));

class SaleListState {
  final bool isLoading;
  final List<SaleEntity> sales;
  final String? error;
  final double? lastTotal;
  const SaleListState({this.isLoading = false, this.sales = const [], this.error, this.lastTotal});
}

class SaleListNotifier extends StateNotifier<SaleListState> {
  final GetSalesUseCase getSales;
  final CreateSaleUseCase createSale;
  SaleListNotifier(this.getSales, this.createSale) : super(const SaleListState());

  Future<void> load() async {
    state = const SaleListState(isLoading: true);
    final result = await getSales();
    result.fold(
          (failure) => state = SaleListState(error: failure.message),
          (sales) => state = SaleListState(sales: sales),
    );
  }

  Future<void> submit({
    required String customerId,
    required String warehouseId,
    required List<SaleLineEntity> lines,
  }) async {
    final result = await createSale(customerId: customerId, warehouseId: warehouseId, lines: lines);
    result.fold(
          (failure) => state = SaleListState(sales: state.sales, error: failure.message),
          (total) async {
        state = SaleListState(sales: state.sales, lastTotal: total);
        await load();
      },
    );
  }
}

final saleListProvider = StateNotifierProvider<SaleListNotifier, SaleListState>((ref) {
  return SaleListNotifier(ref.read(getSalesUseCaseProvider), ref.read(createSaleUseCaseProvider));
});