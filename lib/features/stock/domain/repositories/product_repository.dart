import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({String? search});
  Future<Either<Failure, ProductEntity>> createProduct({
    required String name,
    String? categoryId,
    String? barcode,
    required double price,
    required double cost,
    required int minThreshold,
    required String unit,
  });
  Future<Either<Failure, void>> updateProduct({
    required String id,
    required String name,
    String? categoryId,
    String? barcode,
    required double price,
    required double cost,
    required int minThreshold,
    required String unit,
  });
  Future<Either<Failure, void>> deleteProduct(String id);
}