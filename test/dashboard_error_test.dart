import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:foreverone/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foreverone/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:foreverone/l10n/app_localizations.dart';
import 'package:foreverone/shared/widgets/app_widgets.dart';
import 'package:dio/dio.dart';

/// A dashboard whose every load fails, counting the attempts.
class _FailingDashboard extends DashboardNotifier {
  int loads = 0;
  _FailingDashboard() : super(DashboardRemoteDatasource(Dio()));

  @override
  Future<void> load() async {
    loads++;
    state = const DashboardState(error: 'Failed to load dashboard');
  }
}

void main() {
  testWidgets('a failed dashboard load shows an error with Retry, not a spinner',
      (tester) async {
    final dashboard = _FailingDashboard();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dashboardProvider.overrideWith((ref) => dashboard)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const DashboardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorState), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text("Couldn't load this page"), findsOneWidget);

    final before = dashboard.loads;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(dashboard.loads, before + 1);
  });
}
