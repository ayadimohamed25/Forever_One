class CustomerScoreEntity {
  final String customerId;
  final String name;
  final String? phone;
  final double balance;
  final int? daysSincePurchase;
  final int score;
  final String reason;

  const CustomerScoreEntity({
    required this.customerId,
    required this.name,
    this.phone,
    required this.balance,
    this.daysSincePurchase,
    required this.score,
    required this.reason,
  });
}