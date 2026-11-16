import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/l10n/app_localizations.dart';
import 'package:foreverone/shared/widgets/app_data_table.dart';

typedef _Row = ({String name, bool paid});

final _rows = <_Row>[
  for (var i = 0; i < 10; i++) (name: 'Client $i', paid: i < 6),
];

/// A page that owns the selection, like the real list pages.
class _Page extends StatefulWidget {
  const _Page();
  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  String? selected;
  int hidden = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppDataTable<_Row>(
        rows: _rows,
        initialSortColumn: 0,
        onRowTap: (r) => setState(() => selected = r.name),
        isSelected: (r) => r.name == selected,
        detailPanel:
            selected == null ? null : Text('Panel for $selected'),
        onSelectionHidden: () => setState(() {
          hidden++;
          selected = null;
        }),
        tabs: AppTableFilter(label: 'Status', options: [
          AppFilterOption('All'),
          AppFilterOption('Paid', (r) => r.paid),
          AppFilterOption('Unpaid', (r) => !r.paid),
        ]),
        summary: const [
          AppTableStat(label: 'Unpaid total', value: '4', tab: 2),
        ],
        columns: [
          AppTableColumn(
            label: 'Customer',
            sortValue: (r) => r.name,
            cell: (r) => AppCellText(r.name),
          ),
        ],
      ),
    );
  }
}

Future<_PageState> _pump(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(
    locale: Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: _Page(),
  ));
  await tester.pumpAndSettle();
  return tester.state<_PageState>(find.byType(_Page));
}

void main() {
  testWidgets('tabs show counts and filter the rows', (tester) async {
    await _pump(tester, 1400);
    expect(find.text('10'), findsOneWidget); // All
    expect(find.text('6'), findsOneWidget); // Paid
    expect(_cell('Client 9'), findsOneWidget);

    await tester.tap(find.text('Paid'));
    await tester.pumpAndSettle();
    expect(_cell('Client 9'), findsNothing);
    expect(_cell('Client 0'), findsOneWidget);
  });

  testWidgets('a summary figure selects its tab', (tester) async {
    await _pump(tester, 1400);
    await tester.tap(find.text('Unpaid total'));
    await tester.pumpAndSettle();
    expect(_cell('Client 0'), findsNothing);
    expect(_cell('Client 9'), findsOneWidget);
  });

  testWidgets('phones show the tabs as chips with counts', (tester) async {
    await _pump(tester, 412);
    expect(find.text('All 10'), findsOneWidget);
    await tester.tap(find.text('Unpaid 4'));
    await tester.pumpAndSettle();
    expect(_cell('Client 0'), findsNothing);
  });

  testWidgets('wide: selecting a row opens the panel beside the table',
      (tester) async {
    await _pump(tester, 1400);
    await tester.tap(_cell('Client 3'));
    await tester.pumpAndSettle();
    final panel = tester.getRect(find.text('Panel for Client 3'));
    final row = tester.getRect(_cell('Client 3'));
    expect(panel.left, greaterThan(row.right));

    // Selecting another row replaces the panel's content.
    await tester.tap(_cell('Client 4'));
    await tester.pumpAndSettle();
    expect(find.text('Panel for Client 4'), findsOneWidget);
  });

  testWidgets('phones never show the side panel', (tester) async {
    final page = await _pump(tester, 412);
    await tester.tap(_cell('Client 3'));
    await tester.pumpAndSettle();
    expect(page.selected, 'Client 3');
    expect(find.text('Panel for Client 3'), findsNothing);
  });

  testWidgets('the panel closes when a tab hides the selected row',
      (tester) async {
    final page = await _pump(tester, 1400);
    await tester.tap(_cell('Client 1')); // paid
    await tester.pumpAndSettle();
    expect(find.text('Panel for Client 1'), findsOneWidget);

    await tester.tap(find.text('Unpaid'));
    await tester.pumpAndSettle();
    expect(page.hidden, 1);
    expect(find.textContaining('Panel for'), findsNothing);
  });
}

/// A row name as the table displays it (short last words are kept with the
/// word before by a non-breaking space).
Finder _cell(String name) => find.text(keepUnitsTogether(name));
