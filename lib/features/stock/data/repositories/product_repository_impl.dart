import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/stock_movement_history_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remote;
  ProductRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? categoryId,
    bool activeOnly = false,
  }) async {
    try {
      final data = await remote.getProducts(
        search: search,
        categoryId: categoryId,
        activeOnly: activeOnly,
      );
      return Right(data
          .whereType<Map>()
          .map((j) => ProductModel.fromJson(Map<String, dynamic>.from(j)))
          .toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load products')));
    }
  }

  @override
  Future<Either<Failure, ProductDetail>> getProductDetail(String id) async {
    try {
      final data = await remote.getProductDetail(id);
      final product =
      ProductModel.fromJson(Map<String, dynamic>.from(data['product']));
      final history = ((data['stock_history'] ?? []) as List)
          .whereType<Map>()
          .map((h) => StockMovementHistoryEntity(
        id: '${h['id']}',
        type: '${h['type']}',
        quantity: int.tryParse('${h['quantity'] ?? 0}') ?? 0,
        note: h['note']?.toString(),
        warehouseName: h['warehouse_name']?.toString(),
        createdAt: DateTime.tryParse('${h['created_at']}') ??
            DateTime.now(),
      ))
          .toList();
      return Right((product: product, history: history));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load product')));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(ProductInput input) async {
    try {
      final data = await remote.createProduct(input.toJson());
      return Right(ProductModel.fromJson(Map<String, dynamic>.from(data)));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to create product')));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(String id, ProductInput input) async {
    try {
      await remote.updateProduct({'id': id, ...input.toJson()});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to update product')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await remote.deleteProduct(id);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('PRODUCT_IN_USE'));
      }
      return Left(ServerFailure(_err(e, 'Failed to delete product')));
    }
  }

  String _err(DioException e, String fallback) {
    return e.response?.data is Map
        ? (e.response?.data['error'] ?? fallback)
        : '$fallback — check your connection';
  }
}