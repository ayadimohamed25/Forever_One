enum CustomerType { individual, company }

class CustomerEntity {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final CustomerType customerType;
  final int paymentTermsDays;
  final String? notes;
  final double creditLimit;
  final double totalPurchases;
  final double totalPaid;
  final int orderCount;
  final DateTime? lastPurchase;

  const CustomerEntity({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.customerType = CustomerType.company,
    this.paymentTermsDays = 0,
    this.notes,
    required this.creditLimit,
    this.totalPurchases = 0,
    this.totalPaid = 0,
    this.orderCount = 0,
    this.lastPurchase,
  });

  double get balance => totalPurchases - totalPaid;
  bool get owesMoney => balance > 0.009;

  double get creditUsage => creditLimit > 0 ? balance / creditLimit : 0;
  bool get isOverCreditLimit => creditLimit > 0 && balance > creditLimit;
  bool get isNearCreditLimit =>
      creditLimit > 0 && !isOverCreditLimit && creditUsage >= 0.8;

  int? get daysSinceLastPurchase {
    if (lastPurchase == null) return null;
    return DateTime.now().difference(lastPurchase!).inDays;
  }
}