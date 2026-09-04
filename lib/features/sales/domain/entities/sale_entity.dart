class SaleEntity {
  final String id;
  final String customerName;
  final double total;
  final String status;

  const SaleEntity({
    required this.id,
    required this.customerName,
    required this.total,
    required this.status,
  });
}