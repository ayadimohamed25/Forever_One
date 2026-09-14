import '../../domain/entities/product_entity.dart';

class ProductModel {
  final String id;
  final String? categoryId;
  final String name;
  final String? barcode;
  final double price;
  final double cost;
  final int minThreshold;
  final String unit;
  final int currentStock;

  ProductModel({
    required this.id,
    this.categoryId,
    required this.name,
    this.barcode,
    required this.price,
    required this.cost,
    required this.minThreshold,
    required this.unit,
    required this.currentStock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'] ?? '',
      barcode: json['barcode'],
      price: double.parse((json['price'] ?? 0).toString()),
      cost: double.parse((json['cost'] ?? 0).toString()),
      minThreshold: int.parse((json['min_threshold'] ?? 0).toString()),
      unit: json['unit'] ?? 'unit',
      currentStock: int.parse((json['current_stock'] ?? 0).toString()),
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      categoryId: categoryId,
      name: name,
      barcode: barcode,
      price: price,
      cost: cost,
      minThreshold: minThreshold,
      unit: unit,
      currentStock: currentStock,
    );
  }
}