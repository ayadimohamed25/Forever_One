import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:foreverone/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foreverone/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:foreverone/features/dashboard/presentation/widgets/revenue_trend_chart.dart';
import 'package:foreverone/l10n/app_localizations.dart';

Map<String, dynamic> _summary(int days, double perDay) => {
      'kpis': {
        'revenue_this_month': 48320.5,
        'revenue_prev_month': 42990,
        'revenue_growth_percent': 12.4,
        'receivables': 9840,
        'payables': 4115.4,
        'stock_value': 61240,
        'sales_count_this_month': 23,
        'low_stock_count': 6,
      },
      'trend_days': days,
      'sales_trend': [
        for (var i = 0; i < (days == 365 ? 12 : days); i++)
          {'day': '2026-11-${(i % 28 + 1).toString().padLeft(2, '0')}', 'revenue': perDay + i},
      ],
      'sales_trend_previous': [
        for (var i = 0; i < (days == 365 ? 12 : days); i++)
          {'day': '2026-10-${(i % 28 + 1).toString().padLeft(2, '0')}', 'revenue': perDay / 2},
      ],
      'top_products': [
        {'name': 'Gobelets carton 25 cl', 'quantity_sold': 1200, 'revenue': 2040},
      ],
      'alerts': [
        {'type': 'overdue_payment', 'severity': 'critical', 'entity_id': 's1', 'title': 'Café Sidi Bou', 'value': 980, 'days': 18, 'route': '/sales'},
      ],
      'recent_activity': [
        {'kind': 'sale', 'id': 's2', 'label': 'Restaurant El Medina', 'amount': 1845, 'created_at': '2026-11-12 10:00:00'},
      ],
    };

/// Answers each request when the test says so, by period.
class _ControlledDatasource extends DashboardRemoteDatasource {
  final pending = <int, Completer<Map<String, dynamic>>>{};
  _ControlledDatasource() : super(Dio());

  @override
  Future<Map<String, dynamic>> getSummary({int trendDays = 30}) {
    final c = Completer<Map<String, dynamic>>();
    pending[trendDays] = c;
    return c.future;
  }
}

class _InstantDatasource extends DashboardRemoteDatasource {
  _InstantDatasource() : super(Dio());
  @override
  Future<Map<String, dynamic>> getSummary({int trendDays = 30}) async =>
      _summary(trendDays, 1000);
}

/// The notifier's current state, read through its public listener API.
DashboardState _now(DashboardNotifier n) {
  late DashboardState s;
  n.addListener((v) => s = v)();
  return s;
}

void main() {
  test('period switch: 7D then 90D, 90D answering first → ends on 90D',
      () async {
    final ds = _ControlledDatasource();
    final n = DashboardNotifier(ds);
    final a = n.setPeriod(7);
    final b = n.setPeriod(90);
    ds.pending[90]!.complete(_summary(90, 10));
    await b;
    ds.pending[7]!.complete(_summary(7, 10));
    await a;
    expect(_now(n).trendDays, 90);
    expect(_now(n).summary!.salesTrend.length, 90);
  });

  test('period switch: 7D answering first is ignored, 90D shows when it lands',
      () async {
    final ds = _ControlledDatasource();
    final n = DashboardNotifier(ds);
    final a = n.setPeriod(7);
    final b = n.setPeriod(90);
    ds.pending[7]!.complete(_summary(7, 10));
    await a;
    expect(_now(n).trendLoading, isTrue);
    expect(_now(n).trendDays, 90);
    ds.pending[90]!.complete(_summary(90, 10));
    await b;
    expect(_now(n).summary!.salesTrend.length, 90);
    expect(_now(n).trendLoading, isFalse);
  });

  test('a failed switch keeps the previous chart and flags the error',
      () async {
    final ds = _ControlledDatasource();
    final n = DashboardNotifier(ds);
    final first = n.load();
    ds.pending[30]!.complete(_summary(30, 10));
    await first;
    final sw = n.setPeriod(7);
    ds.pending[7]!.completeError(Exception('offline'));
    await sw;
    expect(_now(n).trendFailed, isTrue);
    expect(_now(n).summary!.salesTrend.length, 30);
  });

  for (final width in [1440.0, 412.0]) {
    testWidgets('dashboard renders the new layout at ${width.toInt()}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          dashboardProvider
              .overrideWith((ref) => DashboardNotifier(_InstantDatasource())),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DashboardPage(),
        ),
      ));
      // Animations are finite (draw-in, 3 pulses): the page settles.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(RevenueTrendChart), findsOneWidget);
      expect(find.text('Revenue this month'), findsWidgets);
      expect(find.text('Net position'), findsOneWidget);

      await tester.tap(find.text('90D'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
