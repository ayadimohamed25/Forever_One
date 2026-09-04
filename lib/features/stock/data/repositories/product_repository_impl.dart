import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remote;
  ProductRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final data = await remote.getProducts();
      final products = data
          .map((json) => ProductModel.fromJson(json).toEntity())
          .toList();
      return Right(products);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to load products')
          : 'Failed to load products — check your connection';
      return Left(ServerFailure(message));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    String? categoryId,
    required String name,
    String? barcode,
    required double price,
    required double cost,
    required int minThreshold,
    required String unit,
  }) async {
    try {
      final data = await remote.createProduct({
        'category_id': categoryId,
        'name': name,
        'barcode': barcode,
        'price': price,
        'cost': cost,
        'min_threshold': minThreshold,
        'unit': unit,
      });
      return Right(ProductModel.fromJson(data).toEntity());
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to create product')
          : 'Failed to create product — check your connection';
      return Left(ServerFailure(message));
    }
  }
}