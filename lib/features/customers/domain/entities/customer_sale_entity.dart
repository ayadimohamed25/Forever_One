class CustomerSaleEntity {
  final String id;
  final double total;
  final double paid;
  final String status;
  final DateTime createdAt;

  const CustomerSaleEntity({
    required this.id,
    required this.total,
    required this.paid,
    required this.status,
    required this.createdAt,
  });

  double get balance => total - paid;
  bool get isFullyPaid => balance <= 0.009;
}