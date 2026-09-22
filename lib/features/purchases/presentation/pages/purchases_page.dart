import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
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

  Future<void> _openPayment(PurchaseEntity p, AppLocalizations l10n) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PaymentPage(
        purchaseId: p.id,
        title: '${l10n.payment} — ${p.supplierName}',
      ),
    ));
    if (mounted) ref.read(purchaseListProvider.notifier).load();
  }

  Future<void> _create() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreatePurchasePage()),
    );
    if (mounted) ref.read(purchaseListProvider.notifier).load();
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
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

  ({String label, BadgeTone tone}) _paymentStatus(
      PurchaseEntity p, AppLocalizations l10n) {
    if (p.isFullyPaid) return (label: l10n.paid, tone: BadgeTone.success);
    if (p.paid > 0.009) {
      return (label: l10n.partiallyPaid, tone: BadgeTone.warning);
    }
    return (label: l10n.unpaid, tone: BadgeTone.warning);
  }

  Widget _card(PurchaseEntity p, AppLocalizations l10n) {
    final payment = _paymentStatus(p, l10n);
    final hasVatBreakdown = p.subtotalHt > 0.009 || p.totalVat > 0.009;
    final expectedPassed = p.isPending && (p.daysUntilExpected ?? 1) < 0;

    final details = [
      if (p.reference != null && p.reference!.trim().isNotEmpty) p.reference!,
      formatDate(p.createdAt),
    ].join(' · ');

    return AppCard(
      onTap: () => _openPayment(p, l10n),
      padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLeadingTile.icon(Icons.local_shipping_outlined),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.supplierName,
                        style: AppTheme.rowTitle, maxLines: 2),
                    const SizedBox(height: 4),
                    Text(details, style: AppTheme.label, maxLines: 2),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        AppBadge(
                          label: p.isReceived
                              ? l10n.received
                              : l10n.pendingDelivery,
                          tone: p.isReceived
                              ? BadgeTone.success
                              : BadgeTone.warning,
                        ),
                        AppBadge(label: payment.label, tone: payment.tone),
                        if (p.wasLate == true || expectedPassed)
                          AppBadge(
                              label: l10n.overdue, tone: BadgeTone.danger)
                        else if (p.isPending && p.expectedDate != null)
                          AppBadge(
                            label: l10n.expectedOn(formatDate(p.expectedDate!)),
                            tone: BadgeTone.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatDT(p.total), style: AppTheme.money),
                  if (!p.isFullyPaid) ...[
                    const SizedBox(height: 3),
                    Text(
                      formatDT(p.balance),
                      style: AppTheme.font(
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.danger,
                        tabularFigures: true,
                      ),
                    ),
                  ],
                ],
              ),
              AppRowMenu(actions: [
                if (p.isPending)
                  AppMenuAction(
                    label: l10n.markAsReceived,
                    icon: Icons.inventory_outlined,
                    color: AppColors.success,
                    onTap: () => _receive(p, l10n),
                  ),
                AppMenuAction(
                  label: l10n.edit,
                  icon: Icons.edit_outlined,
                  onTap: () => _edit(p, l10n),
                ),
                AppMenuAction(
                  label: l10n.delete,
                  icon: Icons.delete_outline,
                  destructive: true,
                  onTap: () => _delete(p, l10n),
                ),
              ]),
            ],
          ),
          if (hasVatBreakdown)
            AppCardFooter(
              color: AppColors.textSecondary,
              children: [
                Expanded(
                  child: Text(
                    '${formatDT(p.subtotalHt)} ${l10n.exclVatShort}  ·  '
                        '${l10n.totalVat} ${formatDT(p.totalVat)}',
                    maxLines: 2,
                    style: AppTheme.font(
                      size: 12,
                      color: AppColors.textSecondary,
                      tabularFigures: true,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(purchaseListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    final pending = state.purchases.where((p) => p.isPending).length;
    final subtitle = state.purchases.isEmpty
        ? null
        : pending > 0
        ? '${state.purchases.length} · $pending ${l10n.pendingDelivery.toLowerCase()}'
        : '${state.purchases.length} ${l10n.purchases.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      drawer: const AppDrawer(currentRoute: '/purchases'),
      appBar: searchVisible
          ? AppSearchHeader(
        controller: searchController,
        hint: l10n.searchPurchases,
        onChanged: (v) =>
            ref.read(purchaseListProvider.notifier).search(v),
        onClose: () {
          setState(() => searchVisible = false);
          searchController.clear();
          ref.read(purchaseListProvider.notifier).clearSearch();
        },
      )
          : AppPageHeader(
        title: l10n.purchases,
        subtitle: subtitle,
        icon: Icons.shopping_cart_outlined,
        color: AppColors.purchases,
        actions: [
          AppHeaderAction(
            icon: Icons.search,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
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
        title:
        state.hasSearched ? l10n.noResults : l10n.noPurchases,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToRecord,
      )
          : RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () =>
            ref.read(purchaseListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: state.purchases.length,
          itemBuilder: (context, index) =>
              _card(state.purchases[index], l10n),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: AppColors.black,
        icon: const Icon(Icons.add),
        label: Text(l10n.newPurchase),
      ),
    );
  }
}