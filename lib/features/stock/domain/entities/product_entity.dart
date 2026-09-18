class ProductEntity {
  final String id;
  final String? sku;
  final String name;
  final String? description;
  final String? categoryId;
  final String? categoryName;
  final String? categoryColorHex;
  final String? defaultSupplierId;
  final String? supplierName;
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
  final int currentStock;

  const ProductEntity({
    required this.id,
    this.sku,
    required this.name,
    this.description,
    this.categoryId,
    this.categoryName,
    this.categoryColorHex,
    this.defaultSupplierId,
    this.supplierName,
    this.barcode,
    required this.price,
    required this.cost,
    this.vatRate = 19,
    required this.minThreshold,
    this.maxThreshold,
    this.shelfLocation,
    this.isActive = true,
    this.notes,
    required this.unit,
    this.purchaseUnit,
    this.unitsPerPurchase = 1,
    this.currentStock = 0,
  });

  double get margin => price - cost;
  double get marginPercent => price > 0 ? (margin / price * 100) : 0;

  /// Price including Tunisian VAT, which is what a customer actually pays.
  double get priceTtc => price * (1 + vatRate / 100);

  bool get isLowStock => currentStock <= minThreshold;
  bool get isOverstocked =>
      maxThreshold != null && currentStock > maxThreshold!;
}