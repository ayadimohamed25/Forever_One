import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../entities/stock_movement_history_entity.dart';

typedef ProductDetail = ({
ProductEntity product,
List<StockMovementHistoryEntity> history
});

/// All the editable product fields in one object — passing 18 named
/// parameters through four layers would be unreadable.
class ProductInput {
  final String? sku;
  final String name;
  final String? description;
  final String? categoryId;
  final String? defaultSupplierId;
  final String? barcode;
  final double price;
  final double cost;
  final double vatRate;
  final int minThreshold;
  final int? maxThreshold;
  final String? shelfLocation;
  final bool isActive;
  final String? notes;
  final String unit;
  final String? purchaseUnit;
  final int unitsPerPurchase;

  const ProductInput({
    this.sku,
    required this.name,
    this.description,
    this.categoryId,
    this.defaultSupplierId,
    this.barcode,
    this.price = 0,
    this.cost = 0,
    this.vatRate = 19,
    this.minThreshold = 0,
    this.maxThreshold,
    this.shelfLocation,
    this.isActive = true,
    this.notes,
    this.unit = 'unit',
    this.purchaseUnit,
    this.unitsPerPurchase = 1,
  });

  Map<String, dynamic> toJson() => {
    'sku': sku,
    'name': name,
    'description': description,
    'category_id': categoryId,
    'default_supplier_id': defaultSupplierId,
    'barcode': barcode,
    'price': price,
    'cost': cost,
    'vat_rate': vatRate,
    'min_threshold': minThreshold,
    'max_threshold': maxThreshold,
    'shelf_location': shelfLocation,
    'is_active': isActive ? 1 : 0,
    'notes': notes,
    'unit': unit,
    'purchase_unit': purchaseUnit,
    'units_per_purchase': unitsPerPurchase,
  };
}

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? categoryId,
    bool activeOnly,
  });
  Future<Either<Failure, ProductDetail>> getProductDetail(String id);
  Future<Either<Failure, ProductEntity>> createProduct(ProductInput input);
  Future<Either<Failure, void>> updateProduct(String id, ProductInput input);
  Future<Either<Failure, void>> deleteProduct(String id);
}