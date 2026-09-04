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

  ProductModel({
    required this.id,
    this.categoryId,
    required this.name,
    this.barcode,
    required this.price,
    required this.cost,
    required this.minThreshold,
    required this.unit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      barcode: json['barcode'],
      price: double.parse(json['price'].toString()),
      cost: double.parse(json['cost'].toString()),
      minThreshold: int.parse(json['min_threshold'].toString()),
      unit: json['unit'] ?? 'unit',
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
    );
  }
}