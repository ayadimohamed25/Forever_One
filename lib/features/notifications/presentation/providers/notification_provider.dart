import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// The kinds of in-app notification, in the order the screen lists them.
enum NotificationType {
  outOfStock('out_of_stock'),
  lowStock('low_stock'),
  overduePayment('overdue_payment'),
  creditExceeded('credit_exceeded'),
  supplierPaymentDue('supplier_payment_due'),
  pendingDelivery('pending_delivery');

  final String key;
  const NotificationType(this.key);

  static NotificationType? fromKey(String? key) {
    for (final t in values) {
      if (t.key == key) return t;
    }
    return null;
  }
}

/// One active alert, pointing at the record it is about.
class NotificationItem {
  final NotificationType type;
  final String severity; // critical | warning | info
  final String entity; // product | customer | sale | purchase
  final String entityId;
  final String title;
  final double value;
  final double? threshold;
  final int? days;

  const NotificationItem({
    required this.type,
    required this.severity,
    required this.entity,
    required this.entityId,
    required this.title,
    required this.value,
    this.threshold,
    this.days,
  });

  bool get isCritical => severity == 'critical';

  static NotificationItem? fromJson(Map<String, dynamic> json) {
    final type = NotificationType.fromKey(json['type'] as String?);
    if (type == null) return null; // a type this app version doesn't know
    double toD(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    return NotificationItem(
      type: type,
      severity: '${json['severity'] ?? 'warning'}',
      entity: '${json['entity'] ?? ''}',
      entityId: '${json['entity_id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      value: toD(json['value']),
      threshold: json['threshold'] == null ? null : toD(json['threshold']),
      days: json['days'] == null ? null : (json['days'] as num).toInt(),
    );
  }
}

class NotificationState {
  final bool isLoading;
  final List<NotificationItem> items;
  final String? error;

  const NotificationState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  int get count => items.length;

  int countOf(NotificationType type) =>
      items.where((i) => i.type == type).length;

  /// Items grouped by type, in the fixed display order, empty groups left out.
  List<(NotificationType, List<NotificationItem>)> get grouped => [
        for (final t in NotificationType.values)
          if (items.any((i) => i.type == t))
            (t, items.where((i) => i.type == t).toList()),
      ];
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Dio dio;
  NotificationNotifier(this.dio) : super(const NotificationState());

  Future<void> load() async {
    state = NotificationState(isLoading: true, items: state.items);
    try {
      final response = await dio.get('/notifications');
      final data = response.data as Map<String, dynamic>;
      final items = ((data['items'] ?? []) as List)
          .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e)))
          .whereType<NotificationItem>()
          .toList();
      state = NotificationState(items: items);
    } catch (_) {
      state = NotificationState(items: state.items, error: 'LOAD_FAILED');
    }
  }
}

/// Loaded once the user is signed in; refreshed when the Notifications
/// screen opens, on pull-to-refresh, and after the dashboard reloads.
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notifier = NotificationNotifier(ref.read(apiClientProvider).dio);
  final status = ref.watch(authNotifierProvider.select((s) => s.status));
  if (status == AuthStatus.authenticated) {
    Future.microtask(notifier.load);
  }
  return notifier;
});
