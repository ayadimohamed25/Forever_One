class DashboardSummaryEntity {
  final double revenue;
  final double receivables;
  final double payables;
  final int lowStockCount;

  const DashboardSummaryEntity({
    required this.revenue,
    required this.receivables,
    required this.payables,
    required this.lowStockCount,
  });
}