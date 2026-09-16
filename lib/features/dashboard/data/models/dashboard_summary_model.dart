import '../../domain/entities/dashboard_summary_entity.dart';

class DashboardSummaryModel {
  static double _d(dynamic v) => double.tryParse((v ?? 0).toString()) ?? 0;
  static int _i(dynamic v) => int.tryParse((v ?? 0).toString()) ?? 0;

  /// PHP's json_encode turns an empty array into `[]` but a non-sequential
  /// array into `{}`, so we accept both shapes here.
  static List<Map<String, dynamic>> _asList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (raw is Map) {
      return raw.values
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  static DashboardSummaryEntity fromJson(Map<String, dynamic> json) {
    final k = json['kpis'] is Map
        ? Map<String, dynamic>.from(json['kpis'])
        : <String, dynamic>{};

    return DashboardSummaryEntity(
      kpis: DashboardKpis(
        revenueTotal: _d(k['revenue_total']),
        revenueThisMonth: _d(k['revenue_this_month']),
        revenuePrevMonth: _d(k['revenue_prev_month']),
        revenueGrowthPercent: k['revenue_growth_percent'] != null
            ? _d(k['revenue_growth_percent'])
            : null,
        receivables: _d(k['receivables']),
        payables: _d(k['payables']),
        stockValue: _d(k['stock_value']),
        salesCountThisMonth: _i(k['sales_count_this_month']),
        lowStockCount: _i(k['low_stock_count']),
      ),
      salesTrend: _asList(json['sales_trend'])
          .map((t) => SalesTrendPoint(
        day: DateTime.tryParse('${t['day']}') ?? DateTime.now(),
        revenue: _d(t['revenue']),
      ))
          .toList(),
      topProducts: _asList(json['top_products'])
          .map((p) => TopProduct(
        name: '${p['name'] ?? ''}',
        quantitySold: _i(p['quantity_sold']),
        revenue: _d(p['revenue']),
      ))
          .toList(),
      alerts: _asList(json['alerts']).map((a) {
        final rawType = '${a['type'] ?? ''}';
        final type = switch (rawType) {
          'low_stock' => AlertType.lowStock,
          'credit_exceeded' => AlertType.creditExceeded,
          'overdue_payment' => AlertType.overduePayment,
          _ => AlertType.unknown,
        };
        return DashboardAlert(
          type: type,
          severity: '${a['severity'] ?? 'warning'}',
          entityId: '${a['entity_id'] ?? ''}',
          title: '${a['title'] ?? ''}',
          value: _d(a['value']),
          days: a['days'] != null ? _i(a['days']) : null,
          route: '${a['route'] ?? '/dashboard'}',
        );
      }).toList(),
      recentActivity: _asList(json['recent_activity'])
          .map((r) => ActivityItem(
        kind: '${r['kind'] ?? ''}',
        id: '${r['id'] ?? ''}',
        label: '${r['label'] ?? ''}',
        amount: _d(r['amount']),
        createdAt:
        DateTime.tryParse('${r['created_at']}') ?? DateTime.now(),
      ))
          .toList(),
    );
  }
}