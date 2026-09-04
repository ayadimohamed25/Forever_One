class PurchaseEntity {
  final String id;
  final String supplierName;
  final double total;
  final String status;

  const PurchaseEntity({
    required this.id,
    required this.supplierName,
    required this.total,
    required this.status,
  });
}