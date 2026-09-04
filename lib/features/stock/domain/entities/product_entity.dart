class ProductEntity {
  final String id;
  final String? categoryId;
  final String name;
  final String? barcode;
  final double price;
  final double cost;
  final int minThreshold;
  final String unit;

  const ProductEntity({
    required this.id,
    this.categoryId,
    required this.name,
    this.barcode,
    required this.price,
    required this.cost,
    required this.minThreshold,
    required this.unit,
  });
}