import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/l10n/app_localizations.dart';
import 'package:foreverone/shared/widgets/app_data_table.dart';
import 'package:foreverone/shared/widgets/app_widgets.dart';

typedef _Row = ({String name, double total, bool paid});

final _rows = <_Row>[
  (name: 'Barquettes aluminium 500ml', total: 1250.5, paid: false),
  for (var i = 1; i < 57; i++)
    (name: 'Client ${i.toString().padLeft(2, '0')}', total: i * 10.0, paid: i.isEven),
];

Future<void> pumpForDebug(WidgetTester tester, double width) => _pump(tester, width);

Future<void> _pump(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: AppDataTable<_Row>(
        rows: _rows,
        initialSortColumn: 0,
        onRowTap: (_) {},
        rowMenu: (_) => const Icon(Icons.more_vert, key: Key('menu')),
        searchText: (r) => r.name,
        searchHint: 'Search',
        filters: [
          AppTableFilter(label: 'Status', options: [
            AppFilterOption('All'),
            AppFilterOption('Paid', (r) => r.paid),
          ]),
        ],
        onAdd: () {},
        addLabel: 'New sale',
        columns: [
          AppTableColumn(
            label: 'Customer',
            sortValue: (r) => r.name,
            cell: (r) => AppCellText(r.name, strong: true, maxLines: 2),
          ),
          AppTableColumn(
            label: 'Total',
            numeric: true,
            measure: (r) => r.total.toStringAsFixed(2),
            cell: (r) => AppCellText(r.total.toStringAsFixed(2), numeric: true),
          ),
          AppTableColumn(
            label: 'Status',
            chip: true,
            measure: (r) => r.paid ? 'Paid' : 'Unpaid',
            cell: (r) => AppBadge(
                label: r.paid ? 'Paid' : 'Unpaid',
                tone: r.paid ? BadgeTone.success : BadgeTone.warning),
          ),
        ],
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('phone: the long name is not cut, the chip touches the menu',
      (tester) async {
    await _pump(tester, 412);
    // The first column takes ALL the remaining width: its right edge reaches
    // the next column (only the 12px gap between). Widths are not compared to
    // real text: the test font draws every glyph at full font size.
    final nameCol = tester.getRect(find
        .ancestor(
            of: find.text('Barquettes aluminium 500ml'),
            matching: find.byType(Expanded))
        .first);
    final total = tester.getRect(find.text('1250.50'));
    final totalCol = tester.getRect(find
        .ancestor(of: find.text('1250.50'), matching: find.byType(SizedBox))
        .first);
    expect(totalCol.left - nameCol.right, lessThanOrEqualTo(12.5));
    expect(total.right, lessThanOrEqualTo(totalCol.right + 0.5));
    final para = tester.renderObject<RenderParagraph>(
        find.text('Barquettes aluminium 500ml'));
    expect(para.text.toPlainText(), 'Barquettes aluminium 500ml');

    final chip = tester.getRect(find.byType(AppBadge).first);
    final menu = tester.getRect(find.byKey(const Key('menu')).first);
    expect(menu.left - chip.right, lessThanOrEqualTo(24),
        reason: 'no empty gap between the status chip and the menu');
    // Phone: no toolbar, simple scrolling (no pagination).
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining(' of 57'), findsNothing);
  });

  testWidgets('phone: the last row scrolls clear of the floating button',
      (tester) async {
    await _pump(tester, 412);
    await tester.fling(find.byType(Scrollable).first, const Offset(0, -20000), 5000);
    await tester.pumpAndSettle();
    final last = tester.getRect(find.text('Client 56'));
    expect(900 - last.bottom, greaterThanOrEqualTo(96));
  });

  testWidgets('wide: toolbar, 1200px content, pagination 25 per page',
      (tester) async {
    await _pump(tester, 1600);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('New sale'), findsOneWidget);
    expect(find.text('57 results'), findsOneWidget);

    // Content capped at 1200px and centred.
    final first = tester.getRect(find.text('Barquettes aluminium 500ml'));
    expect(first.left, greaterThanOrEqualTo((1600 - 1200) / 2 - 1));

    // Pagination sits under the 25 rows.
    await tester.scrollUntilVisible(find.text('1–25 of 57'), 400,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('1–25 of 57'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    // Page 2 opens at its first row (Client 25), then the range updates.
    expect(find.text('Client 25'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('26–50 of 57'), 400,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('26–50 of 57'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 20000));
    await tester.pumpAndSettle();

    // Search narrows the list and the count.
    await tester.enterText(find.byType(TextField), 'Barquettes');
    await tester.pumpAndSettle();
    expect(find.text('Barquettes aluminium 500ml'), findsOneWidget);
    expect(find.text('Client 01'), findsNothing);
  });
}
