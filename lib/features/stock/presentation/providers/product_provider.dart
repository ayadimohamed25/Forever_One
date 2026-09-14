import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';

final productRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return ProductRepositoryImpl(ProductRemoteDatasource(dio));
});

class ProductListState {
  final bool isLoading;
  final List<ProductEntity> products;
  final String? error;
  final String searchQuery;
  final bool hasSearched;

  const ProductListState({
    this.isLoading = false,
    this.products = const [],
    this.error,
    this.searchQuery = '',
    this.hasSearched = false,
  });

  ProductListState copyWith({
    bool? isLoading,
    List<ProductEntity>? products,
    String? error,
    String? searchQuery,
    bool? hasSearched,
  }) {
    return ProductListState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepositoryImpl repository;
  ProductListNotifier(this.repository) : super(const ProductListState());

  Future<void> load({String? search}) async {
    final query = search ?? state.searchQuery;
    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      hasSearched: query.isNotEmpty,
    );

    final result = await repository.getProducts(search: query);
    result.fold(
          (failure) =>
      state = state.copyWith(isLoading: false, error: failure.message),
          (products) => state = state.copyWith(isLoading: false, products: products),
    );
  }

  Future<void> search(String query) => load(search: query);

  Future<void> clearSearch() => load(search: '');

  Future<void> add({
    required String name,
    String? barcode,
    required double price,
    required double cost,
    required int minThreshold,
    required String unit,
  }) async {
    final result = await repository.createProduct(
      name: name,
      barcode: barcode,
      price: price,
      cost: cost,
      minThreshold: minThreshold,
      unit: unit,
    );

    if (result.isLeft()) {
      final message = result.fold((f) => f.message, (_) => '');
      state = state.copyWith(error: message);
      return;
    }

    await load();
  }

  Future<void> update({
    required String id,
    required String name,
    String? barcode,
    required double price,
    required double cost,
    required int minThreshold,
    required String unit,
  }) async {
    final result = await repository.updateProduct(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      cost: cost,
      minThreshold: minThreshold,
      unit: unit,
    );

    if (result.isLeft()) {
      final message = result.fold((f) => f.message, (_) => '');
      state = state.copyWith(error: message);
      return;
    }

    await load();
  }

  /// Returns null on success, or an error code the UI can translate.
  Future<String?> remove(String id) async {
    final result = await repository.deleteProduct(id);

    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }

    await load();
    return null;
  }
}

final productListProvider =
StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(ref.read(productRepositoryProvider));
});