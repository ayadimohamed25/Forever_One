class SaleLineEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const SaleLineEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get lineTotal => quantity * unitPrice;
}