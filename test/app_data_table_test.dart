import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/shared/widgets/app_data_table.dart';

typedef _Row = ({String name, int stock});

Future<void> _pump(WidgetTester tester, double width, List<_Row> rows,
    {void Function(_Row)? onTap}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: AppDataTable<_Row>(
        rows: rows,
        initialSortColumn: 0,
        onRowTap: onTap,
        columns: [
          AppTableColumn(
            label: 'Product',
            flex: 3,
            sortValue: (r) => r.name,
            cell: (r) => AppCellText(r.name),
          ),
          AppTableColumn(
            label: 'SKU',
            showFrom: 600,
            cell: (r) => AppCellText('SKU-${r.name}'),
          ),
          AppTableColumn(
            label: 'Stock',
            width: 60,
            numeric: true,
            sortValue: (r) => r.stock,
            cell: (r) => AppCellText('${r.stock}', numeric: true),
          ),
        ],
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

List<String> _order(WidgetTester tester, List<String> names) {
  final ys = {
    for (final n in names) n: tester.getTopLeft(find.text(n)).dy,
  };
  return names.toList()..sort((a, b) => ys[a]!.compareTo(ys[b]!));
}

void main() {
  const rows = <_Row>[
    (name: 'Café', stock: 40),
    (name: 'Attiéké', stock: 3),
    (name: 'Biscuits', stock: 12),
  ];
  final names = rows.map((r) => r.name).toList();

  testWidgets('sorts by the initial column, then by a tapped title',
      (tester) async {
    await _pump(tester, 400, rows);
    expect(_order(tester, names), ['Attiéké', 'Biscuits', 'Café']);

    await tester.tap(find.text('Stock'));
    await tester.pumpAndSettle();
    expect(_order(tester, names), ['Attiéké', 'Biscuits', 'Café']); // 3,12,40

    await tester.tap(find.text('Stock'));
    await tester.pumpAndSettle();
    expect(_order(tester, names), ['Café', 'Biscuits', 'Attiéké']); // desc
  });

  testWidgets('phones hide the extra columns; wide screens show them',
      (tester) async {
    await _pump(tester, 400, rows);
    expect(find.text('SKU'), findsNothing);

    await _pump(tester, 900, rows);
    expect(find.text('SKU'), findsOneWidget);
    expect(find.text('SKU-Café'), findsOneWidget);
  });

  testWidgets('tapping a row opens it', (tester) async {
    _Row? opened;
    await _pump(tester, 400, rows, onTap: (r) => opened = r);
    await tester.tap(find.text('Biscuits'));
    expect(opened?.name, 'Biscuits');
  });
}
