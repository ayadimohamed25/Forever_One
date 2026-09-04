import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, ProductEntity>> createProduct({
    String? categoryId,
    required String name,
    String? barcode,
    required double price,
    required double cost,
    required int minThreshold,
    required String unit,
  });
}