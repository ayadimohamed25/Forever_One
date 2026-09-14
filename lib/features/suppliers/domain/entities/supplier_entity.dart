class SupplierEntity {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final String? contactPerson;
  final int paymentTermsDays;
  final String? bankAccount;
  final String? notes;
  final int leadTimeDays;
  final double totalPurchases;
  final double totalPaid;
  final int orderCount;
  final DateTime? lastPurchase;
  final int trackedDeliveries;
  final int onTimeDeliveries;

  const SupplierEntity({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.contactPerson,
    this.paymentTermsDays = 0,
    this.bankAccount,
    this.notes,
    required this.leadTimeDays,
    this.totalPurchases = 0,
    this.totalPaid = 0,
    this.orderCount = 0,
    this.lastPurchase,
    this.trackedDeliveries = 0,
    this.onTimeDeliveries = 0,
  });

  double get balance => totalPurchases - totalPaid;
  bool get owesMoney => balance > 0.009;

  /// Null when we have no tracked deliveries — we never invent a score.
  double? get reliabilityRate =>
      trackedDeliveries > 0 ? onTimeDeliveries / trackedDeliveries : null;

  int? get daysSinceLastPurchase {
    if (lastPurchase == null) return null;
    return DateTime.now().difference(lastPurchase!).inDays;
  }
}