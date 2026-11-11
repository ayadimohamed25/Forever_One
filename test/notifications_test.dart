import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/notifications/presentation/providers/notification_provider.dart';

NotificationItem _item(String type, {String severity = 'warning'}) =>
    NotificationItem.fromJson({
      'type': type,
      'severity': severity,
      'entity': 'product',
      'entity_id': 'x',
      'title': 'T',
      'value': 3,
    })!;

void main() {
  test('parses the API shape, including numbers sent as strings', () {
    final n = NotificationItem.fromJson({
      'type': 'overdue_payment',
      'severity': 'critical',
      'entity': 'sale',
      'entity_id': 's1',
      'title': 'Café Majestic',
      'value': '1250.40',
      'days': 12,
    })!;
    expect(n.type, NotificationType.overduePayment);
    expect(n.isCritical, isTrue);
    expect(n.value, 1250.40);
    expect(n.days, 12);
  });

  test('ignores notification types this app version does not know', () {
    expect(NotificationItem.fromJson({'type': 'something_new'}), isNull);
  });

  test('groups by type in a fixed order and counts each group', () {
    final state = NotificationState(items: [
      _item('overdue_payment', severity: 'critical'),
      _item('low_stock'),
      _item('out_of_stock', severity: 'critical'),
      _item('overdue_payment', severity: 'critical'),
    ]);
    expect(state.count, 4);
    expect(state.countOf(NotificationType.overduePayment), 2);
    expect(state.grouped.map((g) => g.$1).toList(), [
      NotificationType.outOfStock,
      NotificationType.lowStock,
      NotificationType.overduePayment,
    ]);
  });
}
