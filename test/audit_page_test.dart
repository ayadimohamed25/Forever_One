import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/dashboard/data/datasources/audit_remote_datasource.dart';
import 'package:foreverone/features/dashboard/data/repositories/audit_repository_impl.dart';
import 'package:foreverone/features/dashboard/domain/entities/audit_log_entity.dart';
import 'package:foreverone/features/dashboard/presentation/pages/audit_page.dart';
import 'package:foreverone/features/dashboard/presentation/providers/audit_provider.dart';
import 'package:foreverone/l10n/app_localizations.dart';

class _FixedAudit extends AuditNotifier {
  _FixedAudit(List<AuditLogEntity> logs)
      : super(AuditRepositoryImpl(AuditRemoteDatasource(Dio()))) {
    state = AuditState(logs: logs);
  }
  @override
  Future<void> load() async {}
}

final _logs = [
  const AuditLogEntity(
      id: '1', userEmail: 'admin@elbaraka.tn', action: 'login',
      createdAt: '2026-11-11T08:12:00'),
  const AuditLogEntity(
      id: '2', userEmail: 'ventes@elbaraka.tn', action: 'create_sale',
      details: '{"total": 202.45}', createdAt: '2026-11-11T10:40:00'),
  const AuditLogEntity(
      id: '3', userEmail: 'stock@elbaraka.tn', action: 'stock_movement',
      details: '{"type": "out", "quantity": 1}', createdAt: '2026-11-10T17:30:00'),
];

void main() {
  for (final width in [412.0, 1280.0]) {
    testWidgets('audit entries are compact rows with a title at ${width.toInt()}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ProviderScope(
        overrides: [auditProvider.overrideWith((ref) => _FixedAudit(_logs))],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const AuditPage(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Every entry has a title, sign-ins included.
      expect(find.text('Signed in'), findsOneWidget);
      // Compact: each row is at most ~60px tall, so many fit on a laptop.
      final row = find.ancestor(
          of: find.text('Signed in'), matching: find.byType(Container));
      expect(tester.getSize(row.first).height, lessThanOrEqualTo(64));
      // Detail chips show values, not raw API keys.
      expect(find.textContaining('total:'), findsNothing);
      expect(find.text('× 1'), findsOneWidget);
    });
  }
}
