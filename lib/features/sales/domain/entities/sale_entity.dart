class SaleEntity {
  final String id;
  final String customerName;
  final String? reference;
  final double subtotalHt;
  final double totalVat;
  final double total;
  final double paid;
  final String status;
  final DateTime? dueDate;
  final DateTime createdAt;

  const SaleEntity({
    required this.id,
    required this.customerName,
    this.reference,
    this.subtotalHt = 0,
    this.totalVat = 0,
    required this.total,
    this.paid = 0,
    required this.status,
    this.dueDate,
    required this.createdAt,
  });

  double get balance => total - paid;
  bool get isFullyPaid => balance <= 0.009;

  /// Negative when overdue, positive when still in the future.
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final today = DateTime.now();
    final due = dueDate!;
    return DateTime(due.year, due.month, due.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
  }

  bool get isOverdue =>
      !isFullyPaid && daysUntilDue != null && daysUntilDue! < 0;
}