import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../customers/presentation/pages/customer_detail_page.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../../../purchases/presentation/pages/create_purchase_page.dart';
import '../../../stock/presentation/pages/product_detail_page.dart';
import '../providers/notification_provider.dart';

/// Opens the Notifications screen above the shell.
Future<void> openNotifications(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );

/// All active alerts, grouped by type. Each line opens the record it is
/// about. In-app only: nothing is pushed to the device.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationProvider.notifier).load());
  }

  String _groupTitle(NotificationType t, AppLocalizations l10n) {
    switch (t) {
      case NotificationType.outOfStock:
        return l10n.notifOutOfStock;
      case NotificationType.lowStock:
        return l10n.notifLowStock;
      case NotificationType.overduePayment:
        return l10n.notifOverduePayments;
      case NotificationType.creditExceeded:
        return l10n.notifCreditExceeded;
      case NotificationType.supplierPaymentDue:
        return l10n.notifSupplierPaymentsDue;
      case NotificationType.pendingDelivery:
        return l10n.notifPendingDeliveries;
    }
  }

  IconData _icon(NotificationType t) {
    switch (t) {
      case NotificationType.outOfStock:
        return Icons.remove_shopping_cart_outlined;
      case NotificationType.lowStock:
        return Icons.inventory_2_outlined;
      case NotificationType.overduePayment:
        return Icons.schedule_outlined;
      case NotificationType.creditExceeded:
        return Icons.credit_card_off_outlined;
      case NotificationType.supplierPaymentDue:
        return Icons.payments_outlined;
      case NotificationType.pendingDelivery:
        return Icons.local_shipping_outlined;
    }
  }

  String _qty(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  /// The second line: what is wrong, in words.
  String _detail(NotificationItem n, AppLocalizations l10n) {
    switch (n.type) {
      case NotificationType.outOfStock:
      case NotificationType.lowStock:
        return l10n.notifStockLeft(_qty(n.value), _qty(n.threshold ?? 0));
      case NotificationType.overduePayment:
        return l10n.notifDaysOverdue(n.days ?? 0);
      case NotificationType.creditExceeded:
        return l10n.notifOverLimit(formatDT(n.threshold ?? 0));
      case NotificationType.supplierPaymentDue:
        final d = n.days ?? 0;
        if (d < 0) return l10n.notifDaysOverdue(-d);
        if (d == 0) return l10n.notifDueToday;
        return l10n.notifDueInDays(d);
      case NotificationType.pendingDelivery:
        final d = n.days;
        if (d == null) return l10n.notifNoDate;
        if (d < 0) return l10n.notifDeliveryLate(-d);
        return l10n.notifExpectedInDays(d);
    }
  }

  /// The right-hand figure: a quantity for stock, an amount otherwise.
  String _figure(NotificationItem n) {
    switch (n.type) {
      case NotificationType.outOfStock:
      case NotificationType.lowStock:
        return _qty(n.value);
      default:
        return formatDT(n.value);
    }
  }

  Future<void> _open(NotificationItem n, AppLocalizations l10n) async {
    final Widget page;
    switch (n.entity) {
      case 'product':
        page = ProductDetailPage(productId: n.entityId);
      case 'customer':
        page = CustomerDetailPage(customerId: n.entityId);
      case 'sale':
        page = PaymentPage(saleId: n.entityId, title: '${l10n.payment} — ${n.title}');
      case 'purchase':
        page = n.type == NotificationType.pendingDelivery
            ? CreatePurchasePage(existingPurchaseId: n.entityId)
            : PaymentPage(
                purchaseId: n.entityId, title: '${l10n.payment} — ${n.title}');
      default:
        return;
    }
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) ref.read(notificationProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationProvider);

    final Widget body;
    if (state.isLoading && state.items.isEmpty) {
      body = AppSkeletonList(semanticLabel: l10n.loading);
    } else if (state.error != null && state.items.isEmpty) {
      body = AppErrorState(
        title: l10n.loadFailedTitle,
        message: l10n.serverUnreachable,
        retryLabel: l10n.retry,
        onRetry: () => ref.read(notificationProvider.notifier).load(),
      );
    } else if (state.items.isEmpty) {
      body = AppEmptyState(
        icon: Icons.notifications_none_outlined,
        title: l10n.noNotifications,
        subtitle: l10n.noNotificationsHint,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => ref.read(notificationProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            for (final (type, items) in state.grouped)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.gap),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Row(
                        children: [
                          Icon(_icon(type), size: 18, color: AppColors.iconMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_groupTitle(type, l10n),
                                style: AppTheme.sectionTitle),
                          ),
                          AppBadge(
                            label: '${items.length}',
                            tone: items.any((i) => i.isCritical)
                                ? BadgeTone.danger
                                : BadgeTone.warning,
                          ),
                        ],
                      ),
                    ),
                    for (final n in items) _row(n, l10n),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: l10n.notifications,
        icon: Icons.notifications_outlined,
        color: AppColors.primary,
        showMenuButton: false,
      ),
      body: body,
    );
  }

  Widget _row(NotificationItem n, AppLocalizations l10n) {
    final tone = n.isCritical ? AppColors.dangerText : AppColors.warningText;
    return AppPressable(
      onTap: () => _open(n, l10n),
      borderRadius: BorderRadius.zero,
      semanticLabel: '${n.title}, ${_detail(n, l10n)}',
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: n.isCritical ? AppColors.danger : AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title,
                      style: AppTheme.rowTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(_detail(n, l10n),
                      style: AppTheme.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(_figure(n),
                style: AppTheme.font(
                    size: 14,
                    weight: FontWeight.w600,
                    color: tone,
                    tabularFigures: true)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.iconMuted),
          ],
        ),
      ),
    );
  }
}
