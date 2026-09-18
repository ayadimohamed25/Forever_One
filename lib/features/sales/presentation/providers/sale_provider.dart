import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/sale_remote_datasource.dart';
import '../../data/repositories/sale_repository_impl.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/sale_line_entity.dart';

final saleRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return SaleRepositoryImpl(SaleRemoteDatasource(dio));
});

class SaleListState {
  final bool isLoading;
  final List<SaleEntity> sales;
  final String? error;
  final double? lastTotal;
  final String searchQuery;
  final bool hasSearched;

  const SaleListState({
    this.isLoading = false,
    this.sales = const [],
    this.error,
    this.lastTotal,
    this.searchQuery = '',
    this.hasSearched = false,
  });
}

class SaleListNotifier extends StateNotifier<SaleListState> {
  final SaleRepositoryImpl repository;
  SaleListNotifier(this.repository) : super(const SaleListState());

  Future<void> load({String? search}) async {
    final query = search ?? state.searchQuery;
    state = SaleListState(
      isLoading: true,
      sales: state.sales,
      searchQuery: query,
      hasSearched: query.isNotEmpty,
    );

    final result = await repository.getSales(search: query);
    result.fold(
          (failure) => state = SaleListState(
          error: failure.message, searchQuery: query, hasSearched: query.isNotEmpty),
          (sales) => state = SaleListState(
          sales: sales, searchQuery: query, hasSearched: query.isNotEmpty),
    );
  }

  Future<void> search(String query) => load(search: query);
  Future<void> clearSearch() => load(search: '');

  Future<void> submit({
    required String customerId,
    required String warehouseId,
    String? reference,
    String? notes,
    required List<SaleLineEntity> lines,
  }) async {
    final result = await repository.createSale(
      customerId: customerId,
      warehouseId: warehouseId,
      reference: reference,
      notes: notes,
      lines: lines,
    );

    if (result.isLeft()) {
      state = SaleListState(
        sales: state.sales,
        error: result.fold((f) => f.message, (_) => ''),
        searchQuery: state.searchQuery,
      );
      return;
    }

    final totals = result.fold((_) => null, (t) => t);
    state = SaleListState(
        sales: state.sales,
        lastTotal: totals?.total,
        searchQuery: state.searchQuery);
    await load();
  }

  Future<String?> edit({
    required String id,
    required String customerId,
    required String warehouseId,
    String? reference,
    String? notes,
    required List<SaleLineEntity> lines,
  }) async {
    final result = await repository.updateSale(
      id: id,
      customerId: customerId,
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
    final result = await repository.deleteSale(id);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }
}

final saleListProvider =
StateNotifierProvider<SaleListNotifier, SaleListState>((ref) {
  return SaleListNotifier(ref.read(saleRepositoryProvider));
});