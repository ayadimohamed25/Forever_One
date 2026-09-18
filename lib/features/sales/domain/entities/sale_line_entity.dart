class SaleLineEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double vatRate;

  const SaleLineEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.vatRate = 0,
  });

  double get lineTotal => quantity * unitPrice;
  double get vatAmount => lineTotal * vatRate / 100;
  double get lineTotalTtc => lineTotal + vatAmount;
}