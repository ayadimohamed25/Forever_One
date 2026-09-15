import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../providers/purchase_provider.dart';
import 'create_purchase_page.dart';
import '../../../../shared/widgets/app_drawer.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(purchaseListProvider.notifier).load());
  }

  Color _statusColor(String status, ThemeData theme) {
    switch (status) {
      case 'received':
        return Colors.green.shade700;
      case 'cancelled':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'received':
        return l10n.received;
      case 'cancelled':
        return l10n.cancelled;
      case 'draft':
        return l10n.draft;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseListProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/purchases'),
      appBar: AppBar(
        title: Text(l10n.purchases),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: () => ref.read(purchaseListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.purchases.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(l10n.noPurchases,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(l10n.tapPlusToRecord,
                style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () => ref.read(purchaseListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          itemCount: state.purchases.length,
          itemBuilder: (context, index) {
            final p = state.purchases[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PaymentPage(
                      purchaseId: p.id,
                      title: '${l10n.payment} â€” ${p.supplierName}',
                    ),
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.local_shipping_outlined,
                            color: theme.colorScheme.onTertiaryContainer),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.supplierName,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(p.status, theme)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _statusLabel(p.status, l10n),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(p.status, theme),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${p.total.toStringAsFixed(2)} DT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(l10n.payment,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme
                                        .colorScheme.onSurfaceVariant,
                                  )),
                              Icon(Icons.chevron_right,
                                  size: 14,
                                  color: theme
                                      .colorScheme.onSurfaceVariant),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreatePurchasePage()),
          );
          ref.read(purchaseListProvider.notifier).load();
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newPurchase),
      ),
    );
  }
}
