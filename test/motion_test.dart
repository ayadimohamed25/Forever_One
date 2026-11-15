import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/shared/widgets/app_motion.dart';

Widget _app(Widget child, {bool reduce = false}) => MediaQuery(
      data: MediaQueryData(disableAnimations: reduce),
      child: MaterialApp(home: Scaffold(body: child)),
    );

double _opacity(WidgetTester tester) => tester
    .widgetList<Opacity>(
        find.ancestor(of: find.text('Hello'), matching: find.byType(Opacity)))
    .first
    .opacity;

class _Counter extends StatefulWidget {
  const _Counter();
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int n = 0;
  @override
  Widget build(BuildContext context) => TextButton(
      onPressed: () => setState(() => n++), child: Text('Count $n'));
}

void main() {
  testWidgets('entrance animates in, then rests fully visible', (tester) async {
    await tester.pumpWidget(_app(const AppEntrance(child: Text('Hello'))));
    expect(_opacity(tester), lessThan(1));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
  });

  testWidgets('reduced motion: the final state shows at once', (tester) async {
    await tester.pumpWidget(
        _app(const AppEntrance(child: Text('Hello')), reduce: true));
    expect(find.byType(Opacity), findsNothing);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('switching sections animates without remounting the page',
      (tester) async {
    Widget shell(String key) => _app(
          AppSectionSwitcher(switchKey: key, child: const _Counter()),
        );
    await tester.pumpWidget(shell('/sales'));
    await tester.tap(find.text('Count 0'));
    await tester.pump();
    expect(find.text('Count 1'), findsOneWidget);

    await tester.pumpWidget(shell('/customers'));
    await tester.pump(const Duration(milliseconds: 60));
    // Mid-animation and afterwards the page keeps its state.
    expect(find.text('Count 1'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Count 1'), findsOneWidget);
  });

  testWidgets('meter grows to its value; instantly with reduced motion',
      (tester) async {
    double width(WidgetTester t) => t
        .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .widthFactor!;
    await tester.pumpWidget(_app(const SizedBox(
        width: 200, child: AppMeter(value: 0.5, color: Colors.blue))));
    expect(width(tester), lessThan(0.5));
    await tester.pumpAndSettle();
    expect(width(tester), closeTo(0.5, 0.001));

    await tester.pumpWidget(_app(
        const SizedBox(
            width: 200,
            child: AppMeter(
                key: ValueKey('reduced'), value: 0.5, color: Colors.blue)),
        reduce: true));
    expect(width(tester), closeTo(0.5, 0.001));
  });
}
