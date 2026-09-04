import '../../domain/entities/dashboard_summary_entity.dart';

class DashboardSummaryModel {
  final double revenue;
  final double receivables;
  final double payables;
  final int lowStockCount;

  DashboardSummaryModel({
    required this.revenue,
    required this.receivables,
    required this.payables,
    required this.lowStockCount,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      revenue: double.parse((json['revenue'] ?? 0).toString()),
      receivables: double.parse((json['receivables'] ?? 0).toString()),
      payables: double.parse((json['payables'] ?? 0).toString()),
      lowStockCount: int.parse((json['low_stock_count'] ?? 0).toString()),
    );
  }

  DashboardSummaryEntity toEntity() => DashboardSummaryEntity(
    revenue: revenue, receivables: receivables, payables: payables, lowStockCount: lowStockCount,
  );
}