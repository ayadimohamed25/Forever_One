import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/app_localizations.dart';
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
    Future.microtask(
            () => ref.read(customerDetailProvider.notifier).load(widget.customerId));
  }

  Future<void> _launch(String scheme, String value) async {
    final uri = Uri(scheme: scheme, path: value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _lastOrderLabel(int? days, AppLocalizations l10n) {
    if (days == null) return l10n.never;
    if (days == 0) return l10n.today;
    return l10n.daysAgo(days);
  }

  String _paymentTermsLabel(int days, AppLocalizations l10n) {
    return days <= 0 ? l10n.paymentTermsCash : l10n.paymentTermsDays(days);
  }

  Widget _statTile(String label, String value, ThemeData theme, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerDetailProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final c = state.customer;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerDetails),
        actions: [
          if (c != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.edit,
              onPressed: () async {
                final input = await showCustomerFormDialog(context, existing: c);
                if (input == null) return;
                await ref.read(customerListProvider.notifier).update(c.id, input);
                if (mounted) {
                  ref.read(customerDetailProvider.notifier).load(c.id);
                }
              },
            ),
        ],
      ),
      body: state.isLoading || c == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(customerDetailProvider.notifier).load(c.id),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name,
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              c.customerType == CustomerType.individual
                                  ? l10n.individual
                                  : l10n.company,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color:
                                theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${l10n.lastOrder}: ${_lastOrderLabel(c.daysSinceLastPurchase, l10n)}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                  theme.colorScheme.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Credit warning
            if (c.isOverCreditLimit || c.isNearCreditLimit)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (c.isOverCreditLimit
                      ? theme.colorScheme.error
                      : Colors.orange)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 20,
                        color: c.isOverCreditLimit
                            ? theme.colorScheme.error
                            : Colors.orange.shade800),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        c.isOverCreditLimit
                            ? l10n.creditLimitExceeded
                            : l10n.creditLimitNearlyReached,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.isOverCreditLimit
                              ? theme.colorScheme.error
                              : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Stats
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    _statTile(l10n.orders, '${c.orderCount}', theme),
                    _statTile(l10n.totalPurchases,
                        c.totalPurchases.toStringAsFixed(2), theme),
                    _statTile(
                      l10n.outstandingBalance,
                      c.balance.toStringAsFixed(2),
                      theme,
                      color: c.owesMoney
                          ? theme.colorScheme.error
                          : Colors.green.shade700,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Credit usage bar
            if (c.creditLimit > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.creditUsage,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    '${c.balance.toStringAsFixed(0)} / ${c.creditLimit.toStringAsFixed(0)} DT',
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: c.creditUsage.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(
                    c.isOverCreditLimit
                        ? theme.colorScheme.error
                        : c.isNearCreditLimit
                        ? Colors.orange
                        : Colors.green.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Commercial info
            Text(l10n.commercialInfo,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  if (c.taxId != null && c.taxId!.isNotEmpty)
                    _infoRow(
                        Icons.badge_outlined, l10n.taxId, c.taxId!, theme),
                  _infoRow(Icons.payments_outlined, l10n.paymentTerms,
                      _paymentTermsLabel(c.paymentTermsDays, l10n), theme),
                  _infoRow(Icons.credit_card_outlined, l10n.creditLimit,
                      '${c.creditLimit.toStringAsFixed(0)} DT', theme),
                  if (c.notes != null && c.notes!.isNotEmpty)
                    _infoRow(Icons.notes, l10n.notes, c.notes!, theme),
                  const SizedBox(height: 6),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Contact
            Text(l10n.contact,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  if (c.phone != null && c.phone!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: Text(c.phone!),
                      trailing: IconButton(
                        icon: Icon(Icons.call, color: Colors.green.shade700),
                        tooltip: l10n.callCustomer,
                        onPressed: () => _launch('tel', c.phone!),
                      ),
                    ),
                  if (c.email != null && c.email!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: Text(c.email!),
                      trailing: IconButton(
                        icon: Icon(Icons.send,
                            color: theme.colorScheme.primary),
                        tooltip: l10n.sendEmail,
                        onPressed: () => _launch('mailto', c.email!),
                      ),
                    ),
                  if (c.address != null && c.address!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(c.address!),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Purchase history
            Text(l10n.purchaseHistory,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (state.sales.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(l10n.noPurchaseHistory,
                      style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
              )
            else
              ...state.sales.map((s) {
                final dateLabel =
                    '${s.createdAt.day.toString().padLeft(2, '0')}/${s.createdAt.month.toString().padLeft(2, '0')}/${s.createdAt.year}';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side:
                    BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          saleId: s.id,
                          title: '${l10n.payment} — ${c.name}',
                        ),
                      ));
                      if (mounted) {
                        ref
                            .read(customerDetailProvider.notifier)
                            .load(c.id);
                      }
                    },
                    child: ListTile(
                      leading: Icon(
                        s.isFullyPaid
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined,
                        color: s.isFullyPaid
                            ? Colors.green.shade700
                            : theme.colorScheme.error,
                      ),
                      title: Text('${s.total.toStringAsFixed(2)} DT',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        s.isFullyPaid
                            ? '$dateLabel · ${l10n.paid}'
                            : '$dateLabel · ${s.balance.toStringAsFixed(2)} DT ${l10n.unpaid}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Icon(Icons.chevron_right,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}