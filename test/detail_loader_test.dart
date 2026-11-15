import 'dart:async';

import 'package:dartz/dartz.dart' show Either, Right, Left;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/core/errors/failures.dart';
import 'package:foreverone/shared/widgets/app_side_panel.dart';

class _Fail extends Failure {
  const _Fail(super.message);
}

/// Drives AppDetailLoader with requests the test completes by hand.
class _Host extends StatefulWidget {
  final Map<String, Completer<Either<Failure, String>>> pending;
  const _Host(this.pending);
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String id = 'A';
  void select(String v) => setState(() => id = v);
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: AppDetailLoader<String>(
            id: id,
            load: (id) {
              final c = Completer<Either<Failure, String>>();
              widget.pending[id] = c;
              return c.future;
            },
            builder: (v) => Text("Loaded $v"),
            errorMessage: (code) => 'Error $code',
            retryLabel: 'Retry',
          ),
        ),
      );
}

void main() {
  testWidgets('A then B: B answering first, then A late → B stays',
      (tester) async {
    final pending = <String, Completer<Either<Failure, String>>>{};
    await tester.pumpWidget(_Host(pending));
    tester.state<_HostState>(find.byType(_Host)).select('B');
    await tester.pump();

    pending['B']!.complete(const Right('B'));
    await tester.pumpAndSettle();
    pending['A']!.complete(const Right('A'));
    await tester.pumpAndSettle();
    expect(find.text('Loaded B'), findsOneWidget);
    expect(find.text('Loaded A'), findsNothing);
  });

  testWidgets('A then B: A answering first is ignored, B shows when it lands',
      (tester) async {
    final pending = <String, Completer<Either<Failure, String>>>{};
    await tester.pumpWidget(_Host(pending));
    final host = tester.state<_HostState>(find.byType(_Host));
    host.select('B');
    await tester.pump();

    pending['A']!.complete(const Right('A'));
    await tester.pumpAndSettle();
    expect(find.text('Loaded A'), findsNothing); // still loading B

    pending['B']!.complete(const Right('B'));
    await tester.pumpAndSettle();
    expect(find.text('Loaded B'), findsOneWidget);
  });

  testWidgets('a failure shows the message and Retry loads again',
      (tester) async {
    final pending = <String, Completer<Either<Failure, String>>>{};
    await tester.pumpWidget(_Host(pending));
    pending['A']!.complete(const Left(_Fail('NOT_FOUND')));
    await tester.pumpAndSettle();
    expect(find.text('Error NOT_FOUND'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    pending['A']!.complete(const Right('A'));
    await tester.pumpAndSettle();
    expect(find.text('Loaded A'), findsOneWidget);
  });
}
