class PurchaseLineEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double unitCost;

  const PurchaseLineEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
  });

  double get lineTotal => quantity * unitCost;
}