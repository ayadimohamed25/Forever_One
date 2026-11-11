import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../providers/supplier_provider.dart';
import 'supplier_form_page.dart';
import '../../../../core/utils/formatters.dart';

class SupplierDetailPage extends ConsumerStatefulWidget {
  final String supplierId;
  const SupplierDetailPage({super.key, required this.supplierId});

  @override
  ConsumerState<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends ConsumerState<SupplierDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(supplierDetailProvider.notifier).load(widget.supplierId));
  }

  Future<void> _launch(String scheme, String value) async {
    final uri = Uri(scheme: scheme, path: value);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  String _paymentTermsLabel(int days, AppLocalizations l10n) {
    return days <= 0 ? l10n.paymentTermsCash : l10n.paymentTermsDays(days);
  }

  /// Delivery reliability tone: good from 80%, fair from 50%, poor below.
  Color _reliabilityColor(double rate) => rate >= 0.8
      ? AppColors.success
      : rate >= 0.5
          ? AppColors.warning
          : AppColors.danger;

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, top: 24, bottom: 10),
        child: Text(text, style: AppTheme.font(size: 16, weight: FontWeight.w600)),
      );

  Widget _stat(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTheme.font(
                size: 18,
                weight: FontWeight.w700,
                tabularFigures: true,
                color: color == null ? AppColors.textPrimary : AppColors.textOn(color),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTheme.font(size: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierDetailProvider);
    final l10n = AppLocalizations.of(context)!;
    final s = state.supplier;

    final Widget body;
    if (state.isLoading) {
      body = AppSkeletonList(rows: 4, semanticLabel: l10n.loading);
    } else if (s == null) {
      body = AppErrorState(
        title: l10n.loadFailedTitle,
        message: l10n.serverUnreachable,
        retryLabel: l10n.retry,
        onRetry: () =>
            ref.read(supplierDetailProvider.notifier).load(widget.supplierId),
      );
    } else {
      final rate = s.reliabilityRate;
      body = RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => ref.read(supplierDetailProvider.notifier).load(s.id),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Identity
            Row(
              children: [
                const AppLeadingTile.icon(Icons.local_shipping_outlined,
                    size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: AppTheme.sectionTitle, maxLines: 2),
                      if (s.contactPerson != null &&
                          s.contactPerson!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(s.contactPerson!, style: AppTheme.label),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              child: Row(
                children: [
                  _stat(l10n.totalOrders, '${s.orderCount}'),
                  _stat(l10n.totalPurchases,
                      formatDT(s.totalPurchases)),
                  _stat(
                    l10n.amountOwed,
                    formatDT(s.balance),
                    color: s.owesMoney ? AppColors.danger : AppColors.success,
                  ),
                ],
              ),
            ),

            // Delivery reliability
            _sectionTitle(l10n.deliveryReliability),
            AppCard(
              child: rate == null
                  ? Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 20, color: AppColors.iconMuted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(l10n.noDeliveryData,
                              style: AppTheme.font(
                                  size: 14, color: AppColors.textSecondary)),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(rate * 100).toStringAsFixed(0)}%',
                              style: AppTheme.font(
                                size: 22,
                                weight: FontWeight.w700,
                                tabularFigures: true,
                                color: AppColors.textOn(_reliabilityColor(rate)),
                              ),
                            ),
                            Text(
                              l10n.onTimeDeliveries(
                                  s.onTimeDeliveries, s.trackedDeliveries),
                              style: AppTheme.label,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: rate,
                            minHeight: 8,
                            backgroundColor: AppColors.track,
                            valueColor:
                                AlwaysStoppedAnimation(_reliabilityColor(rate)),
                          ),
                        ),
                      ],
                    ),
            ),

            // Commercial info
            _sectionTitle(l10n.commercialInfo),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
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
                      value: _paymentTermsLabel(s.paymentTermsDays, l10n)),
                  if (s.bankAccount != null && s.bankAccount!.isNotEmpty)
                    AppInfoRow(
                        icon: Icons.account_balance_outlined,
                        label: l10n.bankAccount,
                        value: s.bankAccount!),
                  if (s.notes != null && s.notes!.isNotEmpty)
                    AppInfoRow(
                        icon: Icons.notes, label: l10n.notes, value: s.notes!),
                ],
              ),
            ),

            // Contact
            if ((s.phone?.isNotEmpty ?? false) ||
                (s.email?.isNotEmpty ?? false) ||
                (s.address?.isNotEmpty ?? false)) ...[
              _sectionTitle(l10n.contact),
              AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  children: [
                    if (s.phone != null && s.phone!.isNotEmpty)
                      AppInfoRow(
                        icon: Icons.phone_outlined,
                        label: l10n.phone,
                        value: s.phone!,
                        trailing: AppIconButton(
                          icon: Icons.call_outlined,
                          tooltip: l10n.phone,
                          color: AppColors.success,
                          onTap: () => _launch('tel', s.phone!),
                        ),
                      ),
                    if (s.email != null && s.email!.isNotEmpty)
                      AppInfoRow(
                        icon: Icons.mail_outline,
                        label: l10n.email,
                        value: s.email!,
                        trailing: AppIconButton(
                          icon: Icons.send_outlined,
                          tooltip: l10n.send,
                          onTap: () => _launch('mailto', s.email!),
                        ),
                      ),
                    if (s.address != null && s.address!.isNotEmpty)
                      AppInfoRow(
                          icon: Icons.place_outlined,
                          label: l10n.address,
                          value: s.address!),
                  ],
                ),
              ),
            ],

            // Purchase history
            _sectionTitle(l10n.purchaseHistory),
            if (state.purchases.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(l10n.noPurchaseHistory,
                      style: AppTheme.font(
                          size: 14, color: AppColors.textSecondary)),
                ),
              )
            else
              ...state.purchases.map((p) {
                final dateLabel =
                    '${p.createdAt.day.toString().padLeft(2, '0')}/${p.createdAt.month.toString().padLeft(2, '0')}/${p.createdAt.year}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () async {
                      await Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          purchaseId: p.id,
                          title: '${l10n.payment} — ${s.name}',
                        ),
                      ));
                      if (mounted) {
                        ref.read(supplierDetailProvider.notifier).load(s.id);
                      }
                    },
                    child: Row(
                      children: [
                        AppLeadingTile.icon(
                          p.isFullyPaid
                              ? Icons.check_circle_outline
                              : Icons.pending_outlined,
                          tone: p.isFullyPaid
                              ? BadgeTone.success
                              : BadgeTone.danger,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.reference != null && p.reference!.isNotEmpty
                                    ? '${p.reference} · ${formatDT(p.total)}'
                                    : formatDT(p.total),
                                style: AppTheme.rowTitle,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.isFullyPaid
                                    ? '$dateLabel · ${l10n.paid}'
                                    : '$dateLabel · ${formatDT(p.balance)} ${l10n.unpaid}',
                                style: AppTheme.label,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.iconMuted),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: l10n.supplierDetails,
        subtitle: s?.name,
        icon: Icons.local_shipping_outlined,
        color: AppColors.purchases,
        showMenuButton: false,
        actions: [
          if (s != null)
            AppHeaderAction(
              icon: Icons.edit_outlined,
              tooltip: l10n.edit,
              onTap: () async {
                final input =
                    await openSupplierForm(context, existing: s);
                if (input == null) return;
                await ref.read(supplierListProvider.notifier).update(s.id, input);
                if (mounted) {
                  ref.read(supplierDetailProvider.notifier).load(s.id);
                }
              },
            ),
        ],
      ),
      body: body,
    );
  }
}
