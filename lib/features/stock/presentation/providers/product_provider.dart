import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/stock_movement_history_entity.dart';
import '../../domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return ProductRepositoryImpl(ProductRemoteDatasource(dio));
});

final categoryRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return CategoryRepositoryImpl(CategoryRemoteDatasource(dio));
});

// ---------- Product list ----------

class ProductListState {
  final bool isLoading;
  final List<ProductEntity> products;
  final String? error;
  final String searchQuery;
  final String? categoryFilter;
  final bool hasSearched;

  const ProductListState({
    this.isLoading = false,
    this.products = const [],
    this.error,
    this.searchQuery = '',
    this.categoryFilter,
    this.hasSearched = false,
  });

  ProductListState copyWith({
    bool? isLoading,
    List<ProductEntity>? products,
    String? error,
    String? searchQuery,
    String? categoryFilter,
    bool clearCategoryFilter = false,
    bool? hasSearched,
  }) {
    return ProductListState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter:
      clearCategoryFilter ? null : (categoryFilter ?? this.categoryFilter),
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepositoryImpl repository;
  ProductListNotifier(this.repository) : super(const ProductListState());

  Future<void> load({String? search, String? categoryId, bool clearCategory = false}) async {
    final query = search ?? state.searchQuery;
    final category = clearCategory ? null : (categoryId ?? state.categoryFilter);

    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      categoryFilter: category,
      clearCategoryFilter: clearCategory,
      hasSearched: query.isNotEmpty || category != null,
    );

    final result = await repository.getProducts(
      search: query,
      categoryId: category,
    );

    result.fold(
          (failure) =>
      state = state.copyWith(isLoading: false, error: failure.message),
          (products) => state = state.copyWith(isLoading: false, products: products),
    );
  }

  Future<void> search(String query) => load(search: query);
  Future<void> clearSearch() => load(search: '');
  Future<void> filterByCategory(String? categoryId) =>
      load(categoryId: categoryId, clearCategory: categoryId == null);

  Future<void> add(ProductInput input) async {
    final result = await repository.createProduct(input);
    if (result.isLeft()) {
      state = state.copyWith(error: result.fold((f) => f.message, (_) => ''));
      return;
    }
    await load();
  }

  Future<void> update(String id, ProductInput input) async {
    final result = await repository.updateProduct(id, input);
    if (result.isLeft()) {
      state = state.copyWith(error: result.fold((f) => f.message, (_) => ''));
      return;
    }
    await load();
  }

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

// ---------- Product detail ----------

class ProductDetailState {
  final bool isLoading;
  final ProductEntity? product;
  final List<StockMovementHistoryEntity> history;
  final String? error;

  const ProductDetailState({
    this.isLoading = false,
    this.product,
    this.history = const [],
    this.error,
  });
}

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  final ProductRepositoryImpl repository;
  ProductDetailNotifier(this.repository) : super(const ProductDetailState());

  Future<void> load(String id) async {
    state = const ProductDetailState(isLoading: true);
    final result = await repository.getProductDetail(id);
    result.fold(
          (failure) => state = ProductDetailState(error: failure.message),
          (detail) => state = ProductDetailState(
        product: detail.product,
        history: detail.history,
      ),
    );
  }
}

final productDetailProvider =
StateNotifierProvider<ProductDetailNotifier, ProductDetailState>((ref) {
  return ProductDetailNotifier(ref.read(productRepositoryProvider));
});

// ---------- Categories ----------

class CategoryListState {
  final bool isLoading;
  final List<CategoryEntity> categories;
  final String? error;
  final String searchQuery;
  final bool hasSearched;

  const CategoryListState({
    this.isLoading = false,
    this.categories = const [],
    this.error,
    this.searchQuery = '',
    this.hasSearched = false,
  });
}

class CategoryListNotifier extends StateNotifier<CategoryListState> {
  final CategoryRepositoryImpl repository;
  CategoryListNotifier(this.repository) : super(const CategoryListState());

  Future<void> load({String? search}) async {
    final query = search ?? state.searchQuery;
    state = CategoryListState(
      isLoading: true,
      categories: state.categories,
      searchQuery: query,
      hasSearched: query.isNotEmpty,
    );

    final result = await repository.getCategories(search: query);
    result.fold(
          (failure) => state = CategoryListState(
          error: failure.message,
          searchQuery: query,
          hasSearched: query.isNotEmpty),
          (categories) => state = CategoryListState(
          categories: categories,
          searchQuery: query,
          hasSearched: query.isNotEmpty),
    );
  }

  Future<void> search(String query) => load(search: query);
  Future<void> clearSearch() => load(search: '');

  Future<void> add({
    required String name,
    String? description,
    String? colorHex,
  }) async {
    final result = await repository.createCategory(
      name: name,
      description: description,
      colorHex: colorHex,
    );
    if (result.isLeft()) {
      state = CategoryListState(
        categories: state.categories,
        error: result.fold((f) => f.message, (_) => ''),
        searchQuery: state.searchQuery,
      );
      return;
    }
    await load();
  }

  Future<void> update({
    required String id,
    required String name,
    String? description,
    String? colorHex,
  }) async {
    final result = await repository.updateCategory(
      id: id,
      name: name,
      description: description,
      colorHex: colorHex,
    );
    if (result.isLeft()) {
      state = CategoryListState(
        categories: state.categories,
        error: result.fold((f) => f.message, (_) => ''),
        searchQuery: state.searchQuery,
      );
      return;
    }
    await load();
  }

  Future<String?> remove(String id) async {
    final result = await repository.deleteCategory(id);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }
}

final categoryListProvider =
StateNotifierProvider<CategoryListNotifier, CategoryListState>((ref) {
  return CategoryListNotifier(ref.read(categoryRepositoryProvider));
});