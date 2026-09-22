import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../../domain/entities/customer_entity.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_form_dialog.dart';

class CustomerDetailPage extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends ConsumerState<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(customerDetailProvider.notifier).load(widget.customerId));
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _edit(CustomerEntity c) async {
    final input = await showCustomerFormDialog(context, existing: c);
    if (input == null) return;
    await ref.read(customerListProvider.notifier).update(c.id, input);
    if (mounted) ref.read(customerDetailProvider.notifier).load(c.id);
  }

  String _lastOrder(CustomerEntity c, AppLocalizations l10n) {
    final days = c.daysSinceLastPurchase;
    if (days == null) return l10n.never;
    if (days == 0) return l10n.today;
    return l10n.daysAgo(days);
  }

  String _paymentTerms(CustomerEntity c, AppLocalizations l10n) {
    return c.paymentTermsDays <= 0
        ? l10n.paymentTermsCash
        : l10n.paymentTermsDays(c.paymentTermsDays);
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTheme.font(
                size: 16,
                weight: FontWeight.w700,
                color: color,
                tabularFigures: true,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTheme.font(size: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 36, color: AppColors.track);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerDetailProvider);
    final l10n = AppLocalizations.of(context)!;
    final c = state.customer;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: l10n.customerDetails,
        subtitle: c?.name,
        icon: Icons.person_outline,
        color: AppColors.finance,
        showMenuButton: false,
        actions: [
          if (c != null)
            AppHeaderAction(
              icon: Icons.edit_outlined,
              tooltip: l10n.edit,
              onTap: () => _edit(c),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : c == null
          ? AppEmptyState(
        icon: Icons.error_outline,
        title: state.error ?? l10n.noCustomers,
        subtitle: '',
      )
          : RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => ref
            .read(customerDetailProvider.notifier)
            .load(widget.customerId),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ── Identity ──
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLeadingTile.initials(c.name, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          maxLines: 2,
                          style: AppTheme.font(
                              size: 18, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.lastOrder}: ${_lastOrder(c, l10n)}',
                          style: AppTheme.label,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            AppBadge(
                              label: c.customerType ==
                                  CustomerType.company
                                  ? l10n.company
                                  : l10n.individual,
                              tone: BadgeTone.neutral,
                            ),
                            if (c.isOverCreditLimit)
                              AppBadge(
                                  label: l10n.creditLimitExceeded,
                                  tone: BadgeTone.danger)
                            else if (c.owesMoney)
                              AppBadge(
                                  label: l10n.unpaid,
                                  tone: BadgeTone.warning)
                            else
                              AppBadge(
                                  label: l10n.reasonUpToDate,
                                  tone: BadgeTone.success),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Credit warning ──
            if (c.isOverCreditLimit || c.isNearCreditLimit)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.isOverCreditLimit
                      ? AppColors.dangerSoft
                      : AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      size: 22,
                      color: c.isOverCreditLimit
                          ? AppColors.danger
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c.isOverCreditLimit
                            ? l10n.creditLimitExceeded
                            : l10n.creditLimitNearlyReached,
                        style: AppTheme.font(
                          size: 14,
                          weight: FontWeight.w600,
                          color: c.isOverCreditLimit
                              ? AppColors.danger
                              : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Figures ──
            AppCard(
              child: Row(
                children: [
                  _stat(l10n.orders, '${c.orderCount}',
                      AppColors.textPrimary),
                  _statDivider(),
                  _stat(l10n.totalPurchases,
                      formatDT(c.totalPurchases),
                      AppColors.textPrimary),
                  _statDivider(),
                  _stat(
                    l10n.outstandingBalance,
                    formatDT(c.balance > 0 ? c.balance : 0),
                    c.owesMoney
                        ? AppColors.danger
                        : AppColors.success,
                  ),
                ],
              ),
            ),

            // ── Credit usage ──
            if (c.creditLimit > 0)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.creditUsage,
                            style: AppTheme.font(
                                size: 14, weight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${(c.creditUsage * 100).clamp(0, 999).toStringAsFixed(0)}%',
                          style: AppTheme.font(
                            size: 14,
                            weight: FontWeight.w600,
                            tabularFigures: true,
                            color: c.isOverCreditLimit
                                ? AppColors.danger
                                : c.isNearCreditLimit
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: c.creditUsage.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.track,
                        valueColor: AlwaysStoppedAnimation(
                          c.isOverCreditLimit
                              ? AppColors.danger
                              : c.isNearCreditLimit
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatDT(c.balance > 0 ? c.balance : 0)} / ${formatDT(c.creditLimit)}',
                      style: AppTheme.font(
                        size: 12,
                        color: AppColors.textSecondary,
                        tabularFigures: true,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // ── Commercial info ──
            AppFormSection(
              title: l10n.commercialInfo,
              spacing: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              children: [
                if (c.taxId != null && c.taxId!.trim().isNotEmpty)
                  AppInfoRow(
                    icon: Icons.badge_outlined,
                    label: l10n.taxId,
                    value: c.taxId!,
                  ),
                AppInfoRow(
                  icon: Icons.payments_outlined,
                  label: l10n.paymentTerms,
                  value: _paymentTerms(c, l10n),
                ),
                AppInfoRow(
                  icon: Icons.credit_card_outlined,
                  label: l10n.creditLimit,
                  value: formatDT(c.creditLimit),
                ),
                if (c.notes != null && c.notes!.trim().isNotEmpty)
                  AppInfoRow(
                    icon: Icons.notes_outlined,
                    label: l10n.notes,
                    value: c.notes!,
                  ),
              ],
            ),

            // ── Contact ──
            if ((c.phone ?? '').isNotEmpty ||
                (c.email ?? '').isNotEmpty ||
                (c.address ?? '').isNotEmpty) ...[
              const SizedBox(height: 24),
              AppFormSection(
                title: l10n.contact,
                spacing: 0,
                padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                children: [
                  if ((c.phone ?? '').isNotEmpty)
                    AppInfoRow(
                      icon: Icons.phone_outlined,
                      label: l10n.phone,
                      value: c.phone!,
                      trailing: IconButton(
                        tooltip: l10n.callCustomer,
                        icon: const Icon(Icons.call_outlined,
                            color: AppColors.success),
                        onPressed: () => _launch(
                            Uri(scheme: 'tel', path: c.phone)),
                      ),
                    ),
                  if ((c.email ?? '').isNotEmpty)
                    AppInfoRow(
                      icon: Icons.mail_outline,
                      label: l10n.email,
                      value: c.email!,
                      trailing: IconButton(
                        tooltip: l10n.sendEmail,
                        icon: const Icon(Icons.send_outlined,
                            color: AppColors.accent),
                        onPressed: () => _launch(
                            Uri(scheme: 'mailto', path: c.email)),
                      ),
                    ),
                  if ((c.address ?? '').isNotEmpty)
                    AppInfoRow(
                      icon: Icons.place_outlined,
                      label: l10n.address,
                      value: c.address!,
                    ),
                ],
              ),
            ],

            // ── Purchase history ──
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                l10n.purchaseHistory,
                style:
                AppTheme.font(size: 16, weight: FontWeight.w600),
              ),
            ),
            if (state.sales.isEmpty)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(l10n.noPurchaseHistory,
                        style: AppTheme.label),
                  ),
                ),
              )
            else
              for (final s in state.sales)
                AppCard(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          saleId: s.id,
                          title: '${l10n.payment} — ${c.name}',
                        ),
                      ),
                    );
                    if (mounted) {
                      ref
                          .read(customerDetailProvider.notifier)
                          .load(widget.customerId);
                    }
                  },
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLeadingTile.icon(
                          Icons.receipt_long_outlined),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(formatDate(s.createdAt),
                                style: AppTheme.rowTitle),
                            const SizedBox(height: 4),
                            Text(formatDT(s.total),
                                style: AppTheme.label),
                            const SizedBox(height: 10),
                            if (s.isFullyPaid)
                              AppBadge(
                                  label: l10n.paid,
                                  tone: BadgeTone.success)
                            else if (s.paid > 0.009)
                              AppBadge(
                                  label: l10n.partiallyPaid,
                                  tone: BadgeTone.warning)
                            else
                              AppBadge(
                                  label: l10n.unpaid,
                                  tone: BadgeTone.warning),
                          ],
                        ),
                      ),
                      if (!s.isFullyPaid) ...[
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatDT(s.balance),
                              style: AppTheme.money.copyWith(
                                  color: AppColors.danger),
                            ),
                            const SizedBox(height: 3),
                            Text(l10n.outstandingBalance,
                                style: AppTheme.label),
                          ],
                        ),
                      ],
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right,
                          size: 22, color: AppColors.textMuted),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}