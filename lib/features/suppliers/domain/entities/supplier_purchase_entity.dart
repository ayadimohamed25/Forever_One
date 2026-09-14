class SupplierPurchaseEntity {
  final String id;
  final String? reference;
  final double total;
  final double paid;
  final String status;
  final DateTime createdAt;
  final DateTime? expectedDate;
  final DateTime? receivedDate;

  const SupplierPurchaseEntity({
    required this.id,
    this.reference,
    required this.total,
    required this.paid,
    required this.status,
    required this.createdAt,
    this.expectedDate,
    this.receivedDate,
  });

  double get balance => total - paid;
  bool get isFullyPaid => balance <= 0.009;

  bool? get wasOnTime {
    if (expectedDate == null || receivedDate == null) return null;
    return !receivedDate!.isAfter(expectedDate!);
  }
}