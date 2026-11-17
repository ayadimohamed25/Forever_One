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
import '../../../finance/presentation/pages/payment_page.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/supplier_purchase_entity.dart';
import '../pages/supplier_form_page.dart';
import '../providers/supplier_provider.dart';

/// Everything about one supplier, shared by the side panel (wide list) and
/// the full detail page (phones). [compact] = panel.
class SupplierDetailBody extends ConsumerStatefulWidget {
  final String supplierId;
  final bool compact;
  final VoidCallback? onChanged;

  const SupplierDetailBody({
    super.key,
    required this.supplierId,
    this.compact = false,
    this.onChanged,
  });

  @override
  ConsumerState<SupplierDetailBody> createState() => _SupplierDetailBodyState();
}

class _SupplierDetailBodyState extends ConsumerState<SupplierDetailBody> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void didUpdateWidget(SupplierDetailBody old) {
    super.didUpdateWidget(old);
    if (old.supplierId != widget.supplierId) Future.microtask(_load);
  }

  Future<void> _load() =>
      ref.read(supplierDetailProvider.notifier).load(widget.supplierId);

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _edit(SupplierEntity s) async {
    final input = await openSupplierForm(context, existing: s);
    if (input == null) return;
    await ref.read(supplierListProvider.notifier).update(s.id, input);
    if (!mounted) return;
    widget.onChanged?.call();
    _load();
  }

  Future<void> _openPurchase(SupplierPurchaseEntity p, SupplierEntity s,
      AppLocalizations l10n) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          purchaseId: p.id,
          party: s.name,
          reference: p.reference,
        ),
      ),
    );
    if (!mounted) return;
    widget.onChanged?.call();
    _load();
  }

  /// Delivery reliability tone: good from 80%, fair from 50%, poor below.
  Color _reliabilityColor(double rate) => rate >= 0.8
      ? AppColors.success
      : rate >= 0.5
          ? AppColors.warning
          : AppColors.danger;

  Widget _badge(SupplierPurchaseEntity p, AppLocalizations l10n) {
    if (p.isFullyPaid) {
      return AppBadge(label: l10n.paid, tone: BadgeTone.success);
    }
    if (p.paid > 0.009) {
      return AppBadge(label: l10n.partiallyPaid, tone: BadgeTone.warning);
    }
    return AppBadge(label: l10n.statusToPay, tone: BadgeTone.warning);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(supplierDetailProvider);
    final s = state.supplier;

    if (state.isLoading || (s == null && state.error == null)) {
      return const AppPanelSkeleton();
    }
    if (s == null || s.id != widget.supplierId) {
      return AppPanelError(
        message: errorText(state.error, l10n),
        retryLabel: l10n.retry,
        onRetry: _load,
      );
    }

    final rate = s.reliabilityRate;
    final months = lastMonths(
      [for (final p in state.purchases) (p.createdAt, p.total)],
    );
    final locale = Localizations.localeOf(context).toString();
    final purchases =
        widget.compact ? state.purchases.take(5).toList() : state.purchases;

    final sections = <Widget>[
      Row(children: [
        AppAvatar(s.name, size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: widget.compact ? 32 : 0),
                child: Text(s.name, maxLines: 2, style: AppTheme.heading(size: 18)),
              ),
              if ((s.contactPerson ?? '').isNotEmpty)
                Text(s.contactPerson!, style: AppTheme.label),
            ],
          ),
        ),
      ]),
      const SizedBox(height: 14),
      Wrap(spacing: 8, runSpacing: 8, children: [
        FilledButton.icon(
          onPressed: () => _edit(s),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l10n.edit),
        ),
        if ((s.phone ?? '').isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => _launch(Uri(scheme: 'tel', path: s.phone)),
            icon: const Icon(Icons.call_outlined, size: 18),
            label: Text(l10n.phone),
          ),
        if ((s.email ?? '').isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => _launch(Uri(scheme: 'mailto', path: s.email)),
            icon: const Icon(Icons.mail_outline, size: 18),
            label: Text(l10n.email),
          ),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(
          child: AppStatTile(
            label: l10n.amountOwed,
            value: formatDT(s.balance > 0 ? s.balance : 0),
            color: s.owesMoney ? AppColors.warningText : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppStatTile(label: l10n.orders, value: '${s.orderCount}'),
        ),
      ]),
      AppPanelSection(
        title: l10n.deliveryReliability,
        trailing: rate == null
            ? null
            : Text(
                '${(rate * 100).toStringAsFixed(0)}% · ${l10n.onTimeDeliveries(s.onTimeDeliveries, s.trackedDeliveries)}',
                style: AppTheme.font(
                    size: 12,
                    weight: FontWeight.w600,
                    tabularFigures: true,
                    color: AppColors.textOn(_reliabilityColor(rate))),
              ),
        child: rate == null
            ? Text(l10n.noDeliveryData, style: AppTheme.label)
            : AppMeter(
                value: rate, color: _reliabilityColor(rate), height: 8),
      ),
      AppPanelSection(
        title: l10n.purchases,
        child: AppMonthBars(
          values: months.values,
          labels: [
            for (final m in months.months) DateFormat.MMM(locale).format(m)
          ],
          semanticLabel: l10n.purchases,
        ),
      ),
      AppPanelSection(
        title: l10n.purchaseHistory,
        child: purchases.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.noPurchaseHistory, style: AppTheme.label),
              )
            : Column(children: [
                for (final p in purchases)
                  InkWell(
                    onTap: () => _openPurchase(p, s, l10n),
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
                              Text(formatDT(p.total), style: AppTheme.money),
                              Text(
                                  [
                                    if ((p.reference ?? '').isNotEmpty)
                                      p.reference!,
                                    formatDate(p.createdAt),
                                  ].join(' · '),
                                  style: AppTheme.label),
                            ],
                          ),
                        ),
                        _badge(p, l10n),
                      ]),
                    ),
                  ),
              ]),
      ),
      if (!widget.compact)
        AppPanelSection(
          title: l10n.commercialInfo,
          child: Column(children: [
            if (s.taxId != null && s.taxId!.isNotEmpty)
              AppInfoRow(
                  icon: Icons.badge_outlined,
                  label: l10n.taxId,
                  value: s.taxId!),
            AppInfoRow(
                icon: Icons.schedule,
                label: l10n.leadTime,
                value: '${s.leadTimeDays} ${l10n.days}'),
            AppInfoRow(
              icon: Icons.payments_outlined,
              label: l10n.paymentTerms,
              value: s.paymentTermsDays <= 0
                  ? l10n.paymentTermsCash
                  : l10n.paymentTermsDays(s.paymentTermsDays),
            ),
            if (s.bankAccount != null && s.bankAccount!.isNotEmpty)
              AppInfoRow(
                  icon: Icons.account_balance_outlined,
                  label: l10n.bankAccount,
                  value: s.bankAccount!),
            if ((s.address ?? '').isNotEmpty)
              AppInfoRow(
                  icon: Icons.place_outlined,
                  label: l10n.address,
                  value: s.address!),
            if (s.notes != null && s.notes!.isNotEmpty)
              AppInfoRow(
                  icon: Icons.notes, label: l10n.notes, value: s.notes!),
          ]),
        ),
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
