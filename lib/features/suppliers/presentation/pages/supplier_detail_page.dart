import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../providers/supplier_provider.dart';
import '../widgets/supplier_form_dialog.dart';

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
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant)),
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
    final state = ref.watch(supplierDetailProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final s = state.supplier;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.supplierDetails),
        actions: [
          if (s != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.edit,
              onPressed: () async {
                final input = await showSupplierFormDialog(context, existing: s);
                if (input == null) return;
                await ref.read(supplierListProvider.notifier).update(s.id, input);
                if (mounted) {
                  ref.read(supplierDetailProvider.notifier).load(s.id);
                }
              },
            ),
        ],
      ),
      body: state.isLoading || s == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(supplierDetailProvider.notifier).load(s.id),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.local_shipping_outlined,
                      size: 30,
                      color: theme.colorScheme.onTertiaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold)),
                      if (s.contactPerson != null &&
                          s.contactPerson!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(s.contactPerson!,
                            style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

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
                    _statTile(l10n.totalOrders, '${s.orderCount}', theme),
                    _statTile(l10n.totalPurchases,
                        s.totalPurchases.toStringAsFixed(2), theme),
                    _statTile(
                      l10n.amountOwed,
                      s.balance.toStringAsFixed(2),
                      theme,
                      color: s.owesMoney
                          ? theme.colorScheme.error
                          : Colors.green.shade700,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Delivery reliability
            Text(l10n.deliveryReliability,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: s.reliabilityRate == null
                    ? Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(l10n.noDeliveryData,
                          style: TextStyle(
                              fontSize: 13,
                              color: theme
                                  .colorScheme.onSurfaceVariant)),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(s.reliabilityRate! * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: s.reliabilityRate! >= 0.8
                                ? Colors.green.shade700
                                : s.reliabilityRate! >= 0.5
                                ? Colors.orange.shade700
                                : theme.colorScheme.error,
                          ),
                        ),
                        Text(
                          l10n.onTimeDeliveries(
                              s.onTimeDeliveries, s.trackedDeliveries),
                          style: TextStyle(
                              fontSize: 12,
                              color: theme
                                  .colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: s.reliabilityRate,
                        minHeight: 8,
                        backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          s.reliabilityRate! >= 0.8
                              ? Colors.green.shade600
                              : s.reliabilityRate! >= 0.5
                              ? Colors.orange
                              : theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

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
                  if (s.taxId != null && s.taxId!.isNotEmpty)
                    _infoRow(Icons.badge_outlined, l10n.taxId, s.taxId!, theme),
                  _infoRow(Icons.schedule, l10n.leadTime,
                      '${s.leadTimeDays} ${l10n.days}', theme),
                  _infoRow(Icons.payments_outlined, l10n.paymentTerms,
                      _paymentTermsLabel(s.paymentTermsDays, l10n), theme),
                  if (s.bankAccount != null && s.bankAccount!.isNotEmpty)
                    _infoRow(Icons.account_balance_outlined,
                        l10n.bankAccount, s.bankAccount!, theme),
                  if (s.notes != null && s.notes!.isNotEmpty)
                    _infoRow(Icons.notes, l10n.notes, s.notes!, theme),
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
                  if (s.phone != null && s.phone!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: Text(s.phone!),
                      trailing: IconButton(
                        icon: Icon(Icons.call, color: Colors.green.shade700),
                        onPressed: () => _launch('tel', s.phone!),
                      ),
                    ),
                  if (s.email != null && s.email!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: Text(s.email!),
                      trailing: IconButton(
                        icon: Icon(Icons.send,
                            color: theme.colorScheme.primary),
                        onPressed: () => _launch('mailto', s.email!),
                      ),
                    ),
                  if (s.address != null && s.address!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(s.address!),
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
            if (state.purchases.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(l10n.noPurchaseHistory,
                      style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
              )
            else
              ...state.purchases.map((p) {
                final dateLabel =
                    '${p.createdAt.day.toString().padLeft(2, '0')}/${p.createdAt.month.toString().padLeft(2, '0')}/${p.createdAt.year}';
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
                          purchaseId: p.id,
                          title: '${l10n.payment} — ${s.name}',
                        ),
                      ));
                      if (mounted) {
                        ref
                            .read(supplierDetailProvider.notifier)
                            .load(s.id);
                      }
                    },
                    child: ListTile(
                      leading: Icon(
                        p.isFullyPaid
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined,
                        color: p.isFullyPaid
                            ? Colors.green.shade700
                            : theme.colorScheme.error,
                      ),
                      title: Text(
                        p.reference != null && p.reference!.isNotEmpty
                            ? '${p.reference} · ${p.total.toStringAsFixed(2)} DT'
                            : '${p.total.toStringAsFixed(2)} DT',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        p.isFullyPaid
                            ? '$dateLabel · ${l10n.paid}'
                            : '$dateLabel · ${p.balance.toStringAsFixed(2)} DT ${l10n.unpaid}',
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