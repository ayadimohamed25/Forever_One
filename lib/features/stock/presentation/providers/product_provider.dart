import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';

final productRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return ProductRepositoryImpl(ProductRemoteDatasource(dio));
});

final getProductsUseCaseProvider = Provider((ref) {
  return GetProductsUseCase(ref.read(productRepositoryProvider));
});

final createProductUseCaseProvider = Provider((ref) {
  return CreateProductUseCase(ref.read(productRepositoryProvider));
});

class ProductListState {
  final bool isLoading;
  final List<ProductEntity> products;
  final String? error;
  const ProductListState({
    this.isLoading = false,
    this.products = const [],
    this.error,
  });
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final GetProductsUseCase getProducts;
  final CreateProductUseCase createProduct;

  ProductListNotifier(this.getProducts, this.createProduct)
      : super(const ProductListState());

  Future<void> load() async {
    state = const ProductListState(isLoading: true);
    final result = await getProducts();
    result.fold(
          (failure) => state = ProductListState(error: failure.message),
          (products) => state = ProductListState(products: products),
    );
  }

  Future<void> add({
    String? categoryId,
    required String name,
    String? barcode,
    required double price,
    required double cost,
    required int minThreshold,
    required String unit,
  }) async {
    final result = await createProduct(
      categoryId: categoryId,
      name: name,
      barcode: barcode,
      price: price,
      cost: cost,
      minThreshold: minThreshold,
      unit: unit,
    );
    result.fold(
          (failure) => state = ProductListState(
        products: state.products,
        error: failure.message,
      ),
          (product) => state = ProductListState(
        products: [...state.products, product],
      ),
    );
  }
}

final productListProvider =
StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(
    ref.read(getProductsUseCaseProvider),
    ref.read(createProductUseCaseProvider),
  );
});