import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/errors/error_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../shared/widgets/app_motion.dart';
import '../../../../shared/widgets/app_side_panel.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_sale_entity.dart';
import '../providers/customer_provider.dart';
import 'customer_form_route.dart';

/// Everything about one customer, shared by the side panel (wide list) and
/// the full detail page (phones), so there is one way to show a customer.
///
/// [compact] (panel) shows the 5 latest sales and skips the long info
/// sections; the page shows everything.
class CustomerDetailBody extends ConsumerStatefulWidget {
  final String customerId;
  final bool compact;

  /// Called after an edit or a payment, so the list can refresh.
  final VoidCallback? onChanged;

  const CustomerDetailBody({
    super.key,
    required this.customerId,
    this.compact = false,
    this.onChanged,
  });

  @override
  ConsumerState<CustomerDetailBody> createState() => _CustomerDetailBodyState();
}

class _CustomerDetailBodyState extends ConsumerState<CustomerDetailBody> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void didUpdateWidget(CustomerDetailBody old) {
    super.didUpdateWidget(old);
    if (old.customerId != widget.customerId) Future.microtask(_load);
  }

  Future<void> _load() =>
      ref.read(customerDetailProvider.notifier).load(widget.customerId);

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _edit(CustomerEntity c) async {
    final input = await openCustomerForm(context, existing: c);
    if (input == null) return;
    await ref.read(customerListProvider.notifier).update(c.id, input);
    if (!mounted) return;
    widget.onChanged?.call();
    _load();
  }

  Future<void> _openSale(CustomerSaleEntity s, CustomerEntity c,
      AppLocalizations l10n) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          saleId: s.id,
          party: c.name,
        ),
      ),
    );
    if (!mounted) return;
    widget.onChanged?.call();
    _load();
  }

  String _lastOrder(CustomerEntity c, AppLocalizations l10n) {
    final days = c.daysSinceLastPurchase;
    if (days == null) return l10n.never;
    if (days == 0) return l10n.today;
    return l10n.daysAgo(days);
  }

  Widget _saleBadge(CustomerSaleEntity s, AppLocalizations l10n) {
    if (s.isFullyPaid) {
      return AppBadge(label: l10n.paid, tone: BadgeTone.success);
    }
    if (s.paid > 0.009) {
      return AppBadge(label: l10n.partiallyPaid, tone: BadgeTone.warning);
    }
    return AppBadge(label: l10n.unpaid, tone: BadgeTone.warning);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(customerDetailProvider);
    final c = state.customer;

    if (state.isLoading || (c == null && state.error == null)) {
      return const AppPanelSkeleton();
    }
    if (c == null || c.id != widget.customerId) {
      return AppPanelError(
        message: errorText(state.error, l10n),
        retryLabel: l10n.retry,
        onRetry: _load,
      );
    }

    final usageColor = c.isOverCreditLimit
        ? AppColors.danger
        : c.isNearCreditLimit
            ? AppColors.warning
            : AppColors.primary;
    final months = lastMonths(
      [for (final s in state.sales) (s.createdAt, s.total)],
    );
    final locale = Localizations.localeOf(context).toString();
    final sales = widget.compact ? state.sales.take(5).toList() : state.sales;

    final sections = <Widget>[
      // ── Identity ──
      Row(children: [
        AppAvatar(c.name, size: 48, square: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                // Room for the panel's close button.
                padding: EdgeInsets.only(right: widget.compact ? 32 : 0),
                child: Text(c.name,
                    maxLines: 2,
                    style: AppTheme.heading(size: 18)),
              ),
              const SizedBox(height: 2),
              Text('${l10n.lastOrder}: ${_lastOrder(c, l10n)}',
                  style: AppTheme.label),
            ],
          ),
        ),
      ]),
      const SizedBox(height: 14),
      // ── Actions ──
      // Phones: a row of large round actions, as on the mobile board (the
      // thumb reaches them, and Message opens the SMS app directly).
      if (!widget.compact && MediaQuery.sizeOf(context).width < 840)
        Row(children: [
          for (final (icon, label, onTap, primary) in [
            if ((c.phone ?? '').isNotEmpty) ...[
              (Icons.call_outlined, l10n.callAction,
                  () => _launch(Uri(scheme: 'tel', path: c.phone)), false),
              (Icons.sms_outlined, l10n.messageAction,
                  () => _launch(Uri(scheme: 'sms', path: c.phone)), false),
            ],
            if ((c.email ?? '').isNotEmpty)
              (Icons.mail_outline, l10n.emailAction,
                  () => _launch(Uri(scheme: 'mailto', path: c.email)), false),
            (Icons.edit_outlined, l10n.edit, () => _edit(c), true),
          ])
            Expanded(
              child: _RoundAction(
                  icon: icon, label: label, onTap: onTap, primary: primary),
            ),
        ])
      else
      Wrap(spacing: 8, runSpacing: 8, children: [
        FilledButton.icon(
          onPressed: () => _edit(c),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l10n.edit),
        ),
        if ((c.phone ?? '').isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => _launch(Uri(scheme: 'tel', path: c.phone)),
            icon: const Icon(Icons.call_outlined, size: 18),
            label: Text(l10n.callCustomer),
          ),
        if ((c.email ?? '').isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => _launch(Uri(scheme: 'mailto', path: c.email)),
            icon: const Icon(Icons.mail_outline, size: 18),
            label: Text(l10n.sendEmail),
          ),
      ]),
      const SizedBox(height: 16),
      // ── Figures ──
      Row(children: [
        Expanded(
          child: AppStatTile(
            label: l10n.outstandingBalance,
            value: formatDT(c.balance > 0 ? c.balance : 0),
            color: c.owesMoney ? AppColors.dangerText : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppStatTile(label: l10n.orders, value: '${c.orderCount}'),
        ),
      ]),
      // ── Credit usage ──
      if (c.creditLimit > 0)
        AppPanelSection(
          title: l10n.creditUsage,
          trailing: Text(
            '${formatDT(c.balance > 0 ? c.balance : 0)} / ${formatDT(c.creditLimit)}',
            style: AppTheme.font(
                size: 12, weight: FontWeight.w600, tabularFigures: true),
          ),
          child: AppMeter(
            value: c.creditUsage,
            color: usageColor,
            height: 8,
          ),
        ),
      // ── Purchases per month ──
      AppPanelSection(
        title: l10n.totalPurchases,
        child: AppMonthBars(
          values: months.values,
          labels: [
            for (final m in months.months) DateFormat.MMM(locale).format(m)
          ],
          semanticLabel: l10n.totalPurchases,
        ),
      ),
      // ── Recent sales ──
      AppPanelSection(
        title: l10n.purchaseHistory,
        child: sales.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.noPurchaseHistory, style: AppTheme.label),
              )
            : Column(
                children: [
                  for (final s in sales)
                    InkWell(
                      onTap: () => _openSale(s, c, l10n),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: AppColors.border)),
                        ),
                        child: Row(children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(formatDT(s.total),
                                    style: AppTheme.money),
                                Text(formatDate(s.createdAt),
                                    style: AppTheme.label),
                              ],
                            ),
                          ),
                          _saleBadge(s, l10n),
                        ]),
                      ),
                    ),
                ],
              ),
      ),
      if (!widget.compact) ...[
        AppPanelSection(
          title: l10n.commercialInfo,
          child: Column(children: [
            if (c.taxId != null && c.taxId!.trim().isNotEmpty)
              AppInfoRow(
                  icon: Icons.badge_outlined,
                  label: l10n.taxId,
                  value: c.taxId!),
            AppInfoRow(
              icon: Icons.payments_outlined,
              label: l10n.paymentTerms,
              value: c.paymentTermsDays <= 0
                  ? l10n.paymentTermsCash
                  : l10n.paymentTermsDays(c.paymentTermsDays),
            ),
            AppInfoRow(
                icon: Icons.credit_card_outlined,
                label: l10n.creditLimit,
                value: formatDT(c.creditLimit)),
            if ((c.address ?? '').isNotEmpty)
              AppInfoRow(
                  icon: Icons.place_outlined,
                  label: l10n.address,
                  value: c.address!),
            if (c.notes != null && c.notes!.trim().isNotEmpty)
              AppInfoRow(
                  icon: Icons.notes_outlined,
                  label: l10n.notes,
                  value: c.notes!),
          ]),
        ),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++)
          AppEntrance(index: i, stagger: AppMotion.stagger, child: sections[i]),
      ],
    );
  }
}

/// Phones: a 52px rounded square with its label under it (Call, Message…).
class _RoundAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      semanticLabel: label,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primary ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: primary ? AppColors.primary : AppColors.border),
            ),
            child: Icon(icon,
                size: 21, color: primary ? Colors.white : AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                  size: 12, weight: FontWeight.w500, color: AppColors.textLabel)),
        ]),
      ),
    );
  }
}
