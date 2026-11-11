import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/shared/widgets/app_widgets.dart';

/// Regression: on wide windows the fixed Save bar must stay a bar. It once
/// grew to the full window height (an Align without heightFactor inside
/// bottomNavigationBar), covering the form with a blank page.
void main() {
  for (final width in [400.0, 1280.0]) {
    testWidgets('a form keeps its body visible at ${width.toInt()}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListView(children: const [
            Text('Form body field'),
          ]),
          bottomNavigationBar: AppBottomActionBar(
            child: FilledButton(onPressed: () {}, child: const Text('Save')),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final bar = tester.getSize(find.byType(AppBottomActionBar));
      expect(bar.height, lessThan(100), reason: 'the Save bar is a bar');
      expect(find.text('Form body field').hitTestable(), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  }
}
