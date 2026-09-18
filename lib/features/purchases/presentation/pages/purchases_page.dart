import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../../domain/entities/purchase_entity.dart';
import '../providers/purchase_provider.dart';
import 'create_purchase_page.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(purchaseListProvider.notifier).load());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _receive(PurchaseEntity p, AppLocalizations l10n) async {
    final error = await ref.read(purchaseListProvider.notifier).receive(p.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.purchaseReceived);
    } else if (error == 'PURCHASE_ALREADY_RECEIVED') {
      _showSnack(l10n.alreadyReceived, isError: true);
    } else {
      _showSnack(error, isError: true);
    }
  }

  Future<void> _edit(PurchaseEntity p, AppLocalizations l10n) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => CreatePurchasePage(existingPurchaseId: p.id)),
    );
    if (changed == true && mounted) {
      _showSnack(l10n.purchaseUpdated);
      ref.read(purchaseListProvider.notifier).load();
    }
  }

  Future<void> _delete(PurchaseEntity p, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(p.supplierName)),
        content:
        Text('${l10n.deleteConfirmMessage} ${l10n.stockWillBeRestored}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final error = await ref.read(purchaseListProvider.notifier).remove(p.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.purchaseDeleted);
    } else if (error == 'PURCHASE_HAS_PAYMENTS') {
      _showSnack(l10n.purchaseHasPayments, isError: true);
    } else {
      _showSnack(error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/purchases'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: searchVisible
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchPurchases,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (v) =>
              ref.read(purchaseListProvider.notifier).search(v),
        )
            : Text(l10n.purchases),
        actions: [
          IconButton(
            icon: Icon(searchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => searchVisible = !searchVisible);
              if (!searchVisible) {
                searchController.clear();
                ref.read(purchaseListProvider.notifier).clearSearch();
              }
            },
          ),
          if (!searchVisible)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(purchaseListProvider.notifier).load(),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.purchases.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.shopping_cart_outlined,
        title: state.hasSearched ? l10n.noResults : l10n.noPurchases,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToRecord,
        color: AppColors.purchases,
      )
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(purchaseListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: state.purchases.length,
          itemBuilder: (context, index) {
            final p = state.purchases[index];

            return AppCard(
              accentColor: p.isPending ? AppColors.warning : null,
              padding: const EdgeInsets.fromLTRB(14, 14, 4, 12),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PaymentPage(
                    purchaseId: p.id,
                    title: '${l10n.payment} — ${p.supplierName}',
                  ),
                ));
                if (mounted) {
                  ref.read(purchaseListProvider.notifier).load();
                }
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      AppIconBadge(
                          icon: Icons.local_shipping_outlined,
                          color: AppColors.purchases),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(p.supplierName,
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            AppMetaRow(items: [
                              if (p.reference != null)
                                (icon: Icons.tag, text: p.reference!),
                              (
                              icon: Icons.calendar_today_outlined,
                              text: _fmt(p.createdAt)
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${p.total.toStringAsFixed(3)} DT',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.purchases)),
                          Text(
                              '${p.subtotalHt.toStringAsFixed(3)} HT',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            size: 19,
                            color: AppColors.textSecondary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _edit(p, l10n);
                          } else if (value == 'delete') {
                            _delete(p, l10n);
                          } else if (value == 'receive') {
                            _receive(p, l10n);
                          }
                        },
                        itemBuilder: (context) => [
                          if (p.isPending)
                            PopupMenuItem(
                              value: 'receive',
                              child: Row(children: [
                                const Icon(Icons.inventory,
                                    size: 18,
                                    color: AppColors.success),
                                const SizedBox(width: 10),
                                Text(l10n.markAsReceived,
                                    style: const TextStyle(
                                        color: AppColors.success)),
                              ]),
                            ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [
                              const Icon(Icons.edit_outlined,
                                  size: 18),
                              const SizedBox(width: 10),
                              Text(l10n.edit),
                            ]),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [
                              const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.danger),
                              const SizedBox(width: 10),
                              Text(l10n.delete,
                                  style: const TextStyle(
                                      color: AppColors.danger)),
                            ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        AppStatusChip(
                          label: p.isReceived
                              ? l10n.received
                              : l10n.pendingDelivery,
                          color: p.isReceived
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        AppStatusChip(
                          label: p.isFullyPaid
                              ? l10n.paid
                              : '${p.balance.toStringAsFixed(3)} ${l10n.unpaid}',
                          color: p.isFullyPaid
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                        if (p.wasLate == true) ...[
                          const SizedBox(width: 6),
                          AppStatusChip(
                              label: l10n.overdue,
                              color: AppColors.danger),
                        ],
                        const Spacer(),
                        if (p.expectedDate != null && !p.isReceived)
                          Text(_fmt(p.expectedDate!),
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.purchases,
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