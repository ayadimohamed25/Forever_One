import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../../domain/entities/purchase_entity.dart';
import '../providers/purchase_provider.dart';
import 'create_purchase_page.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../core/errors/error_text.dart';

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
    AppSnack.show(context, message, error: isError);
  }

  Future<void> _openPayment(PurchaseEntity p, AppLocalizations l10n) async {
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => PaymentPage(
        purchaseId: p.id,
        title: '${l10n.payment} — ${p.supplierName}',
      ),
    ));
    if (mounted) ref.read(purchaseListProvider.notifier).load();
  }

  Future<void> _create() async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const CreatePurchasePage()),
    );
    if (mounted) ref.read(purchaseListProvider.notifier).load();
  }

  Future<void> _edit(PurchaseEntity p, AppLocalizations l10n) async {
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
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
      _showSnack(errorText(error, l10n), isError: true);
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
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  /// ONE combined status per purchase (delivery + payment), most urgent
  /// first: cancelled, not yet delivered (late or pending), then payment.
  ({String label, BadgeTone tone, int rank}) _status(
      PurchaseEntity p, AppLocalizations l10n) {
    if (p.status == 'cancelled') {
      return (label: l10n.cancelled, tone: BadgeTone.neutral, rank: 0);
    }
    if (p.isPending) {
      final late = (p.daysUntilExpected ?? 1) < 0;
      return late
          ? (label: l10n.statusLateDelivery, tone: BadgeTone.danger, rank: 5)
          : (label: l10n.statusPendingDelivery, tone: BadgeTone.accent, rank: 4);
    }
    if (p.isFullyPaid) return (label: l10n.paid, tone: BadgeTone.success, rank: 1);
    if (p.paid > 0.009) {
      return (label: l10n.partiallyPaid, tone: BadgeTone.warning, rank: 2);
    }
    return (label: l10n.statusToPay, tone: BadgeTone.warning, rank: 3);
  }

  List<AppTableColumn<PurchaseEntity>> _columns(AppLocalizations l10n) => [
        AppTableColumn(
          label: l10n.supplier,
          flex: 4,
          sortValue: (p) => p.supplierName.toLowerCase(),
          cell: (p) => AppCellText(p.supplierName,
              strong: true, sub: formatDate(p.createdAt)),
        ),
        AppTableColumn(
          label: l10n.date,
          width: 96,
          showFrom: 760,
          sortValue: (p) => p.createdAt,
          cell: (p) => AppCellText(formatDate(p.createdAt),
              color: AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.colBalance,
          width: 108,
          numeric: true,
          showFrom: 600,
          sortValue: (p) => p.balance,
          cell: (p) => AppCellText(p.isFullyPaid ? '—' : formatDT(p.balance),
              numeric: true, color: AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.total,
          width: 112,
          numeric: true,
          sortValue: (p) => p.total,
          cell: (p) => AppCellText(formatDT(p.total), numeric: true),
        ),
        AppTableColumn(
          label: l10n.status,
          width: 116,
          sortValue: (p) => _status(p, l10n).rank,
          cell: (p) {
            final st = _status(p, l10n);
            return AppBadge(label: st.label, tone: st.tone);
          },
        ),
      ];

  Widget _rowMenu(PurchaseEntity p, AppLocalizations l10n) => AppRowMenu(actions: [
        if (p.isPending)
          AppMenuAction(
              label: l10n.markAsReceived,
              icon: Icons.inventory_outlined,
              onTap: () => _receive(p, l10n)),
        AppMenuAction(
            label: l10n.payment,
            icon: Icons.payments_outlined,
            onTap: () => _openPayment(p, l10n)),
        AppMenuAction(
            label: l10n.edit, icon: Icons.edit_outlined, onTap: () => _edit(p, l10n)),
        AppMenuAction(
            label: l10n.delete,
            icon: Icons.delete_outline,
            destructive: true,
            onTap: () => _delete(p, l10n)),
      ]);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(purchaseListProvider, (previous, next) {
      if (next.error != null) _showSnack(errorText(next.error, l10n), isError: true);
    });

    final pending = state.purchases.where((p) => p.isPending).length;
    final subtitle = state.purchases.isEmpty
        ? null
        : pending > 0
        ? '${state.purchases.length} · $pending ${l10n.pendingDelivery.toLowerCase()}'
        : '${state.purchases.length} ${l10n.purchases.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
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
          AppHeaderAddButton(onPressed: _create, label: l10n.newPurchase),
        ],
      ),
      body: state.isLoading
          ? AppSkeletonList(semanticLabel: l10n.loading)
          : state.error != null && state.purchases.isEmpty
          ? AppErrorState(
              title: l10n.loadFailedTitle,
              message: l10n.serverUnreachable,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(purchaseListProvider.notifier).load(),
            )
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
        onRefresh: () =>
            ref.read(purchaseListProvider.notifier).load(),
        child: AppDataTable<PurchaseEntity>(
          columns: _columns(l10n),
          rows: state.purchases,
          initialSortColumn: 1,
          initialAscending: false,
          onRowTap: (p) => _openPayment(p, l10n),
          rowMenu: (p) => _rowMenu(p, l10n),
        ),
      ),
      floatingActionButton: AppAddFab(onPressed: _create, label: l10n.newPurchase),
    );
  }
}