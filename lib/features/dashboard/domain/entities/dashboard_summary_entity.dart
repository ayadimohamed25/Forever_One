class DashboardKpis {
  final double revenueTotal;
  final double revenueThisMonth;
  final double revenuePrevMonth;
  final double? revenueGrowthPercent;
  final double receivables;
  final double payables;
  final double stockValue;
  final int salesCountThisMonth;
  final int lowStockCount;

  const DashboardKpis({
    required this.revenueTotal,
    required this.revenueThisMonth,
    required this.revenuePrevMonth,
    this.revenueGrowthPercent,
    required this.receivables,
    required this.payables,
    required this.stockValue,
    required this.salesCountThisMonth,
    required this.lowStockCount,
  });
}

class SalesTrendPoint {
  final DateTime day;
  final double revenue;

  const SalesTrendPoint({required this.day, required this.revenue});
}

class TopProduct {
  final String name;
  final int quantitySold;
  final double revenue;

  const TopProduct({
    required this.name,
    required this.quantitySold,
    required this.revenue,
  });
}

enum AlertType { lowStock, creditExceeded, overduePayment, unknown }

class DashboardAlert {
  final AlertType type;
  final String severity;
  final String entityId;
  final String title;
  final double value;
  final int? days;
  final String route;

  const DashboardAlert({
    required this.type,
    required this.severity,
    required this.entityId,
    required this.title,
    required this.value,
    this.days,
    required this.route,
  });

  bool get isCritical => severity == 'critical';
}

class ActivityItem {
  final String kind; // 'sale' or 'purchase'
  final String id;
  final String label;
  final double amount;
  final DateTime createdAt;

  const ActivityItem({
    required this.kind,
    required this.id,
    required this.label,
    required this.amount,
    required this.createdAt,
  });
}

class DashboardSummaryEntity {
  final DashboardKpis kpis;
  final List<SalesTrendPoint> salesTrend;
  final List<TopProduct> topProducts;
  final List<DashboardAlert> alerts;
  final List<ActivityItem> recentActivity;

  const DashboardSummaryEntity({
    required this.kpis,
    required this.salesTrend,
    required this.topProducts,
    required this.alerts,
    required this.recentActivity,
  });
}