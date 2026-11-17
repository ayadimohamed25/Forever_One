import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:foreverone/core/router/app_destinations.dart';
import 'package:foreverone/l10n/app_localizations.dart';
import 'package:foreverone/l10n/app_localizations_en.dart';
import 'package:foreverone/shared/widgets/app_data_table.dart';

typedef _Row = ({String name, DateTime at});

final _now = DateTime(2026, 11, 16, 15);

final _rows = <_Row>[
  (name: 'Restaurant El Medina', at: DateTime(2026, 11, 16, 9)),
  (name: 'Hôtel Dar Djerba', at: DateTime(2026, 11, 15, 18)),
  (name: 'Café Sidi Bou', at: DateTime(2026, 10, 24)),
];

Future<void> _pump(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: AppDataTable<_Row>(
          rows: _rows,
          initialSortColumn: 1,
          initialAscending: false,
          phoneGroup: (r) => phoneDayGroup(
              AppLocalizations.of(context)!, 'en', r.at, _now),
          phoneLeading: (r) => AppAvatar(r.name, size: 38, square: true),
          searchText: (r) => r.name,
          searchHint: 'Search sales',
          columns: [
            AppTableColumn(
              label: 'Customer',
              sortValue: (r) => r.name,
              cell: (r) => AppCellText(r.name, strong: true),
            ),
            AppTableColumn(
              label: 'Date',
              showFrom: 760,
              sortValue: (r) => r.at,
              measure: (r) => '${r.at.day}',
              cell: (r) => AppCellText('${r.at.day}'),
            ),
          ],
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  group('phoneDayGroup', () {
    final l10n = AppLocalizationsEn();
    test('today, yesterday, this week, then the month', () {
      expect(phoneDayGroup(l10n, 'en', DateTime(2026, 11, 16, 1), _now), 'Today');
      expect(phoneDayGroup(l10n, 'en', DateTime(2026, 11, 15, 23), _now),
          'Yesterday');
      expect(phoneDayGroup(l10n, 'en', DateTime(2026, 11, 11), _now),
          'This week');
      expect(phoneDayGroup(l10n, 'en', DateTime(2026, 11, 3), _now),
          'This month');
      expect(phoneDayGroup(l10n, 'en', DateTime(2026, 10, 24), _now),
          'October 2026');
    });
  });

  testWidgets('phones group rows under day labels, newest first',
      (tester) async {
    await _pump(tester, 412);
    final today = tester.getTopLeft(find.text('TODAY')).dy;
    final yesterday = tester.getTopLeft(find.text('YESTERDAY')).dy;
    final october = tester.getTopLeft(find.text('OCTOBER 2026')).dy;
    final medina =
        tester.getTopLeft(find.text(keepUnitsTogether('Restaurant El Medina'))).dy;
    expect(today, lessThan(medina));
    expect(medina, lessThan(yesterday));
    expect(yesterday, lessThan(october));
    // Initials avatar before each name.
    expect(find.byType(AppAvatar), findsNWidgets(3));
  });

  testWidgets('groups disappear when sorted another way, and wide never '
      'shows them', (tester) async {
    await _pump(tester, 412);
    await tester.tap(find.byIcon(Icons.swap_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Customer').last);
    await tester.pumpAndSettle();
    expect(find.text('TODAY'), findsNothing);

    await _pump(tester, 1400);
    expect(find.text('TODAY'), findsNothing);
    expect(find.byType(AppAvatar), findsNothing); // phone-only leading
  });

  testWidgets('phones: the search field under the title filters the list',
      (tester) async {
    await _pump(tester, 412);
    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    // It is the first thing in the list, above the first day group.
    expect(tester.getTopLeft(field).dy,
        lessThan(tester.getTopLeft(find.text('TODAY')).dy));

    await tester.enterText(field, 'djerba');
    await tester.pumpAndSettle();
    expect(find.byType(AppAvatar), findsOneWidget);
    expect(find.text(keepUnitsTogether('Restaurant El Medina')), findsNothing);

    await tester.tap(find.byIcon(Icons.close)); // clear
    await tester.pumpAndSettle();
    expect(find.byType(AppAvatar), findsNWidgets(3));
  });

  test('bottom bar order follows the mobile board', () {
    expect(tabRoutes,
        ['/dashboard', '/sales', '/products', '/customers', moreRoute]);
    // More is open to everyone: it is not a guarded destination.
    expect(destinationFor(moreRoute), isNull);
  });
}
