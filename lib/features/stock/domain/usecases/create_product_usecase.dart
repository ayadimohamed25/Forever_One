import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call({
    String? categoryId,
    required String name,
    String? barcode,
    required double price,
    required double cost,
    required int minThreshold,
    required String unit,
  }) {
    return repository.createProduct(
      categoryId: categoryId,
      name: name,
      barcode: barcode,
      price: price,
      cost: cost,
      minThreshold: minThreshold,
      unit: unit,
    );
  }
}