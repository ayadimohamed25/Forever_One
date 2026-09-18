class PurchaseLineEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double unitCost;
  final double vatRate;

  const PurchaseLineEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
    this.vatRate = 0,
  });

  double get lineTotal => quantity * unitCost;
  double get vatAmount => lineTotal * vatRate / 100;
  double get lineTotalTtc => lineTotal + vatAmount;
}