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
  Future<Either<Failure, List<ProductEntity>>> getProducts({String? search}) async {
    try {
      final data = await remote.getProducts(search: search);
      return Right(data.map((j) => ProductModel.fromJson(j).toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load products')));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    required String name,
    String? categoryId,
    String? barcode,
    required double price,
    required double cost,
    required int minThreshold,
    required String unit,
  }) async {
    try {
      final data = await remote.createProduct({
        'name': name,
        'category_id': categoryId,
        'barcode': barcode,
        'price': price,
        'cost': cost,
        'min_threshold': minThreshold,
        'unit': unit,
      });
      return Right(ProductModel.fromJson(data).toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to create product')));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct({
    required String id,
    required String name,
    String? categoryId,
    String? barcode,
    required double price,
    required double cost,
    required int minThreshold,
    required String unit,
  }) async {
    try {
      await remote.updateProduct({
        'id': id,
        'name': name,
        'category_id': categoryId,
        'barcode': barcode,
        'price': price,
        'cost': cost,
        'min_threshold': minThreshold,
        'unit': unit,
      });
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
      // The backend returns 409 + PRODUCT_IN_USE when history exists.
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