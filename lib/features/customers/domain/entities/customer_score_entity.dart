class CustomerScoreEntity {
  final String customerId;
  final String name;
  final String? phone;
  final double balance;
  final double creditLimit;
  final int? daysSincePurchase;
  final bool neverPurchased;
  final bool overCreditLimit;
  final int score;

  /// Kept for compatibility; the reason is now phrased in the app from the
  /// fields above, in the selected language.
  final String reason;

  const CustomerScoreEntity({
    required this.customerId,
    required this.name,
    this.phone,
    required this.balance,
    this.creditLimit = 0,
    this.daysSincePurchase,
    this.neverPurchased = false,
    this.overCreditLimit = false,
    required this.score,
    this.reason = '',
  });
}