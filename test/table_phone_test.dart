import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/core/theme/app_colors.dart';
import 'package:foreverone/l10n/app_localizations.dart';
import 'package:foreverone/shared/widgets/app_data_table.dart';
import 'package:foreverone/shared/widgets/app_widgets.dart';

typedef _Row = ({String name, double total, bool paid});

const _rows = <_Row>[
  (name: 'Hôtel Les Oliviers', total: 222.56, paid: true),
  (name: 'Restaurant El Bahja', total: 47.15, paid: false),
];

Future<void> _pump(WidgetTester tester, double width,
    {List<AppTableStat> summary = const []}) async {
  tester.view.physicalSize = Size(width, 1000);
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
        rowMenu: (_) => const Icon(Icons.more_vert, key: Key('menu')),
        summary: summary,
        columns: [
          AppTableColumn(
            label: 'Customer',
            sortValue: (r) => r.name,
            cell: (r) => AppCellText(r.name, strong: true, maxLines: 2),
          ),
          AppTableColumn(
            label: 'Total incl. VAT',
            shortLabel: 'Total',
            numeric: true,
            measure: (r) => '${r.total} DT',
            cell: (r) => AppCellText('${r.total} DT', numeric: true),
          ),
          AppTableColumn(
            label: 'Status',
            chip: true,
            measure: (r) => r.paid ? 'Paid' : 'Partially paid',
            cell: (r) => AppBadge(
                label: r.paid ? 'Paid' : 'Partially paid',
                tone: r.paid ? BadgeTone.success : BadgeTone.warning),
          ),
        ],
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('keepUnitsTogether', () {
    test('glues a number to its unit', () {
      expect(keepUnitsTogether('Pâtes spaghetti 500 g'),
          'Pâtes spaghetti 500 g');
      expect(keepUnitsTogether('Lait demi-écrémé 1 L'), 'Lait demi-écrémé 1 L');
      expect(keepUnitsTogether('Sacs kraft 1 kg (x100)'),
          'Sacs kraft 1 kg (x100)'.replaceFirst(' (x100)', ' (x100)'));
    });
    test('keeps a short last word with the word before', () {
      expect(keepUnitsTogether('Yaourt nature (pack 8)'),
          'Yaourt nature (pack 8)');
    });
    test('leaves ordinary names alone', () {
      expect(keepUnitsTogether('Café Majestic'), 'Café Majestic');
    });
  });

  testWidgets('phone: status sits under the amount, flush right, no own column',
      (tester) async {
    await _pump(tester, 412);
    expect(find.text('Status'), findsNothing); // no separate column title
    final amount = tester.getRect(find.text(keepUnitsTogether('222.56 DT')));
    final chip = tester.getRect(find.byType(AppBadge).first);
    expect(chip.top, greaterThan(amount.bottom - 1)); // stacked below
    expect((chip.right - amount.right).abs(), lessThan(1.5)); // same right edge
    // The name keeps most of the row. (Measured structurally: the test font
    // draws every glyph at full size, so line counts aren't meaningful here.)
    final nameCol = tester.getRect(find
        .ancestor(
            of: find.text(keepUnitsTogether('Hôtel Les Oliviers')),
            matching: find.byType(Expanded))
        .first);
    // Exactly one column right of the name (amount and chip share it), 10px
    // away: no separate status column eating the name's room.
    final cell = tester.getRect(find
        .ancestor(
            of: find.text(keepUnitsTogether('222.56 DT')),
            matching: find.byType(SizedBox))
        .first);
    expect(cell.left - nameCol.right, closeTo(10, 1));
    expect(chip.left, greaterThanOrEqualTo(cell.left - 0.5)); // inside it
    expect(chip.right, lessThanOrEqualTo(cell.right + 0.5));
  });

  testWidgets('phone: no column titles, the Sort menu names the columns; '
      'wide shows the titles', (tester) async {
    await _pump(tester, 412);
    expect(find.text('Total'), findsNothing);
    expect(find.text('Total incl. VAT'), findsNothing);
    await tester.tap(find.byIcon(Icons.swap_vert));
    await tester.pumpAndSettle();
    // Only sortable columns are listed (here: Customer), by their full title.
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Total incl. VAT'), findsNothing);
    await tester.tapAt(const Offset(5, 5)); // close the menu
    await tester.pumpAndSettle();
    await _pump(tester, 1400);
    expect(find.text('Total incl. VAT'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
  });

  testWidgets('summary: zero is neutral, phones use two columns',
      (tester) async {
    await _pump(tester, 412, summary: const [
      AppTableStat(label: 'Customers', value: '7'),
      AppTableStat(label: 'Outstanding balance', value: '2 088.48 DT',
          color: AppColors.warningText),
      AppTableStat(label: 'Over limit', value: '0', color: AppColors.dangerText),
    ]);
    Color colorOf(String v) => tester.widget<Text>(find.text(v)).style!.color!;
    expect(colorOf('0'), AppColors.textPrimary);
    expect(colorOf('2 088.48 DT'), AppColors.warningText);
    // Two per row: the third figure starts a new row below the first.
    expect(tester.getTopLeft(find.text('Over limit')).dy,
        greaterThan(tester.getBottomLeft(find.text('7')).dy));
    expect(find.text('Outstanding balance'), findsOneWidget); // not cut
  });
}
