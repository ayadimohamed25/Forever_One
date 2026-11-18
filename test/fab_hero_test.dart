import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/shared/widgets/app_page_header.dart';

/// The phone tabs keep their pages alive side by side (IndexedStack), each
/// with an add button. Pushing another page with its own add button used to
/// throw "multiple heroes that share the same tag".
void main() {
  testWidgets('add buttons kept alive in tabs do not clash when a page is '
      'pushed', (tester) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Widget page(String label) => Scaffold(
          body: Text(label),
          floatingActionButton: AppAddFab(onPressed: () {}, label: label),
        );

    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        ctx = context;
        return IndexedStack(
          index: 0,
          children: [page('Sales'), page('Stock'), page('Customers')],
        );
      }),
    ));

    Navigator.of(ctx).push(MaterialPageRoute(
        builder: (_) => page('New purchase')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('New purchase'), findsWidgets);
  });
}
