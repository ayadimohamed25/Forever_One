class PurchaseEntity {
  final String id;
  final String supplierName;
  final String? reference;
  final double subtotalHt;
  final double totalVat;
  final double total;
  final double paid;
  final String status;
  final DateTime? expectedDate;
  final DateTime? receivedDate;
  final DateTime createdAt;

  const PurchaseEntity({
    required this.id,
    required this.supplierName,
    this.reference,
    this.subtotalHt = 0,
    this.totalVat = 0,
    required this.total,
    this.paid = 0,
    required this.status,
    this.expectedDate,
    this.receivedDate,
    required this.createdAt,
  });

  double get balance => total - paid;
  bool get isFullyPaid => balance <= 0.009;
  bool get isReceived => status == 'received';
  bool get isPending => status == 'draft';

  /// True when the goods arrived after the date the supplier promised.
  bool? get wasLate {
    if (expectedDate == null || receivedDate == null) return null;
    return receivedDate!.isAfter(expectedDate!);
  }

  /// Negative when the expected date has already passed.
  int? get daysUntilExpected {
    if (expectedDate == null || isReceived) return null;
    final today = DateTime.now();
    final e = expectedDate!;
    return DateTime(e.year, e.month, e.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
  }
}