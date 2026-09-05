class StockForecastEntity {
  final String productId;
  final String name;
  final int currentStock;
  final int minThreshold;
  final double dailySalesRate;
  final int? daysOfCoverage;
  final int suggestedOrder;
  final String urgency;

  const StockForecastEntity({
    required this.productId,
    required this.name,
    required this.currentStock,
    required this.minThreshold,
    required this.dailySalesRate,
    this.daysOfCoverage,
    required this.suggestedOrder,
    required this.urgency,
  });
}