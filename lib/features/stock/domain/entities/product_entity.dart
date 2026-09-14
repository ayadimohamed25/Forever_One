class ProductEntity {
  final String id;
  final String? categoryId;
  final String name;
  final String? barcode;
  final double price;
  final double cost;
  final int minThreshold;
  final String unit;
  final int currentStock;

  const ProductEntity({
    required this.id,
    this.categoryId,
    required this.name,
    this.barcode,
    required this.price,
    required this.cost,
    required this.minThreshold,
    required this.unit,
    this.currentStock = 0,
  });

  double get margin => price - cost;
  double get marginPercent => price > 0 ? (margin / price * 100) : 0;
  bool get isLowStock => currentStock <= minThreshold;
}