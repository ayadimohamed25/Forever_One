class DormantProductEntity {
  final String id;
  final String name;
  final String? lastSale;
  final int? daysSinceSale;
  final bool neverSold;

  const DormantProductEntity({
    required this.id,
    required this.name,
    this.lastSale,
    this.daysSinceSale,
    required this.neverSold,
  });
}