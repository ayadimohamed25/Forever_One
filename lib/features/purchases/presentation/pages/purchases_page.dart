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
import '../../../../shared/widgets/app_invoice_panel.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_side_panel.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../../../core/errors/error_text.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  /// The purchase open in the side panel (wide screens only).
  String? selectedId;

  /// Wide: open the purchase panel. Phone: the purchase on its own screen,
  /// with its main action (receive, else pay) and Edit at the bottom.
  void _open(PurchaseEntity p, AppLocalizations l10n) {
    if (AppBreakpoints.isWide(context)) {
      setState(() => selectedId = p.id);
    } else {
      _openInvoice(p, l10n);
    }
  }

  Future<void> _openInvoice(PurchaseEntity row, AppLocalizations l10n) async {
    final nav = Navigator.of(context, rootNavigator: true);
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final canPay = !row.isFullyPaid && row.status != 'cancelled';
    await nav.push(MaterialPageRoute(
      builder: (_) => AppInvoicePage(
        title: row.reference ?? l10n.purchase,
        body: _invoice(row, l10n, phone: true),
        primary: row.isPending || canPay
            ? FilledButton(
                style: FilledButton.styleFrom(shape: shape),
                onPressed: () {
                  nav.pop();
                  row.isPending
                      ? _receive(row, l10n)
                      : _openPayment(row, l10n);
                },
                child: Text(row.isPending
                    ? l10n.markAsReceived
                    : l10n.recordPayment),
              )
            : null,
        secondary: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 50), shape: shape),
          onPressed: () {
            nav.pop();
            _edit(row, l10n);
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l10n.edit),
        ),
      ),
    ));
    if (mounted) ref.read(purchaseListProvider.notifier).load();
  }

  Widget _panel(PurchaseEntity row, AppLocalizations l10n) => AppSidePanel(
        closeLabel: l10n.close,
        onClose: () => setState(() => selectedId = null),
        child: _invoice(row, l10n),
      );

  Widget _invoice(PurchaseEntity row, AppLocalizations l10n,
      {bool phone = false}) {
    final st = _status(row, l10n);
    return AppDetailLoader<PurchaseDetail>(
        key: ValueKey('${row.id}-${row.paid}-${row.total}-${row.status}'),
        id: row.id,
        load: (id) =>
            ref.read(purchaseRepositoryProvider).getPurchaseDetail(id),
        errorMessage: (code) => errorText(code, l10n),
        retryLabel: l10n.retry,
        builder: (d) => AppInvoicePanel(
          party: row.supplierName,
          reference: row.reference,
          status: AppBadge(label: st.label, tone: st.tone),
          dates: [
            l10n.issuedOn(formatDate(row.createdAt)),
            if (row.isPending && row.expectedDate != null)
              l10n.expectedOn(formatDate(row.expectedDate!)),
          ].join(' · '),
          subtotal: row.subtotalHt,
          vat: row.totalVat,
          total: row.total,
          paid: row.paid,
          phone: phone,
          lines: [
            for (final l in d.lines)
              AppInvoiceLine(l.productName, l.quantity, l.quantity * l.unitCost),
          ],
          actions: phone ? const [] : [
            if (row.isPending)
              FilledButton.icon(
                onPressed: () => _receive(row, l10n),
                icon: const Icon(Icons.inventory_outlined, size: 18),
                label: Text(l10n.markAsReceived),
              ),
            if (!row.isFullyPaid && row.status != 'cancelled')
              (row.isPending ? OutlinedButton.icon : FilledButton.icon)(
                onPressed: () => _openPayment(row, l10n),
                icon: const Icon(Icons.payments_outlined, size: 18),
                label: Text(l10n.recordPayment),
              ),
            OutlinedButton.icon(
              onPressed: () => _edit(row, l10n),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l10n.edit),
            ),
          ],
        ),
    );
  }

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
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          purchaseId: p.id,
          title: '${l10n.payment} — ${p.supplierName}',
        ),
      ),
    );
    if (mounted) ref.read(purchaseListProvider.notifier).load();
  }

  Future<void> _create() async {
    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(
            fullscreenDialog: true, builder: (_) => const CreatePurchasePage()));
    if (mounted) ref.read(purchaseListProvider.notifier).load();
  }

  Future<void> _edit(PurchaseEntity p, AppLocalizations l10n) async {
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreatePurchasePage(existingPurchaseId: p.id),
      ),
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
        content: Text(
          '${l10n.deleteConfirmMessage} ${l10n.stockWillBeRestored}',
        ),
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
    PurchaseEntity p,
    AppLocalizations l10n,
  ) {
    if (p.status == 'cancelled') {
      return (label: l10n.cancelled, tone: BadgeTone.neutral, rank: 0);
    }
    if (p.isPending) {
      final late = (p.daysUntilExpected ?? 1) < 0;
      return late
          ? (label: l10n.statusLateDelivery, tone: BadgeTone.danger, rank: 5)
          : (
              label: l10n.statusPendingDelivery,
              tone: BadgeTone.accent,
              rank: 4,
            );
    }
    if (p.isFullyPaid) {
      return (label: l10n.paid, tone: BadgeTone.success, rank: 1);
    }
    if (p.paid > 0.009) {
      return (label: l10n.partiallyPaid, tone: BadgeTone.warning, rank: 2);
    }
    return (label: l10n.statusToPay, tone: BadgeTone.warning, rank: 3);
  }

  // Order: name, information, amounts, Status, ⋮.
  List<AppTableColumn<PurchaseEntity>> _columns(AppLocalizations l10n) => [
    AppTableColumn(
      label: l10n.supplier,
      sortValue: (p) => p.supplierName.toLowerCase(),
      // The date sits under the name only when the Date column is hidden.
      cell: (p) => Builder(
        builder: (context) => AppCellText(
          p.supplierName,
          strong: true,
          maxLines: 2,
          sub: AppTableWidth.of(context) >= 760
              ? null
              : formatDate(p.createdAt),
        ),
      ),
    ),
    AppTableColumn(
      label: l10n.date,
      showFrom: 760,
      measure: (p) => formatDate(p.createdAt),
      sortValue: (p) => p.createdAt,
      cell: (p) =>
          AppCellText(formatDate(p.createdAt), color: AppColors.textSecondary),
    ),
    AppTableColumn(
      label: l10n.colBalance,
      numeric: true,
      showFrom: 600,
      measure: (p) => p.isFullyPaid ? '—' : formatDT(p.balance),
      sortValue: (p) => p.balance,
      cell: (p) => AppCellText(
        p.isFullyPaid ? '—' : formatDT(p.balance),
        numeric: true,
        color: AppColors.textSecondary,
      ),
    ),
    AppTableColumn(
      label: l10n.total,
      numeric: true,
      measure: (p) => formatDT(p.total),
      sortValue: (p) => p.total,
      cell: (p) => AppCellText(formatDT(p.total), numeric: true),
    ),
    AppTableColumn(
      label: l10n.status,
      chip: true,
      measure: (p) => _status(p, l10n).label,
      sortValue: (p) => _status(p, l10n).rank,
      cell: (p) {
        final st = _status(p, l10n);
        return AppBadge(label: st.label, tone: st.tone);
      },
    ),
  ];

  Widget _rowMenu(PurchaseEntity p, AppLocalizations l10n) => AppRowMenu(
    actions: [
      if (p.isPending)
        AppMenuAction(
          label: l10n.markAsReceived,
          icon: Icons.inventory_outlined,
          onTap: () => _receive(p, l10n),
        ),
      AppMenuAction(
        label: l10n.payment,
        icon: Icons.payments_outlined,
        onTap: () => _openPayment(p, l10n),
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
    ],
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(purchaseListProvider, (previous, next) {
      if (next.error != null) {
        _showSnack(errorText(next.error, l10n), isError: true);
      }
    });

    final subtitle = state.purchases.isEmpty
        ? null
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
              title: state.hasSearched ? l10n.noResults : l10n.noPurchases,
              subtitle: state.hasSearched
                  ? l10n.tryDifferentSearch
                  : l10n.tapPlusToRecord,
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(purchaseListProvider.notifier).load(),
              child: AppDataTable<PurchaseEntity>(
                columns: _columns(l10n),
                rows: state.purchases,
                initialSortColumn: 1,
                initialAscending: false,
                phoneGroup: (p) => phoneDayGroup(l10n,
                    Localizations.localeOf(context).toString(), p.createdAt),
                phoneLeading: (p) =>
                    AppAvatar(p.supplierName, size: 38, square: true),
                onRowTap: (p) => _open(p, l10n),
                rowMenu: (p) => _rowMenu(p, l10n),
                searchText: (p) => '${p.supplierName} ${p.reference ?? ''}',
                searchHint: l10n.searchPurchases,
                tabs: AppTableFilter(
                  label: l10n.status,
                  options: [
                    AppFilterOption(l10n.filterAll),
                    AppFilterOption(
                      l10n.statusPendingDelivery,
                      (p) => p.isPending,
                    ),
                    AppFilterOption(
                      l10n.statusToPay,
                      (p) => p.status != 'cancelled' && !p.isFullyPaid,
                    ),
                    AppFilterOption(
                      l10n.paid,
                      (p) => p.status != 'cancelled' && p.isFullyPaid,
                    ),
                  ],
                ),
                summary: [
                  AppTableStat(
                    label: l10n.statPurchased,
                    value: formatDT(state.purchases
                        .where((p) => p.status != 'cancelled')
                        .fold<double>(0, (t, p) => t + p.total)),
                    tab: 0,
                  ),
                  AppTableStat(
                    label: l10n.statusToPay,
                    value: formatDT(state.purchases
                        .where((p) => p.status != 'cancelled')
                        .fold<double>(
                            0, (t, p) => t + (p.balance > 0 ? p.balance : 0))),
                    color: AppColors.warningText,
                    tab: 2,
                  ),
                  AppTableStat(
                    label: l10n.statusPendingDelivery,
                    value: '${state.purchases.where((p) => p.isPending).length}',
                    color: AppColors.info,
                    tab: 1,
                  ),
                ],
                isSelected: (p) => p.id == selectedId,
                onSelectionHidden: () => setState(() => selectedId = null),
                detailPanel: selectedId == null ||
                        !state.purchases.any((p) => p.id == selectedId)
                    ? null
                    : _panel(state.purchases
                        .firstWhere((p) => p.id == selectedId), l10n),
                filters: [
                  AppTableFilter(
                    label: l10n.date,
                    options: [
                      AppFilterOption(l10n.periodAll),
                      AppFilterOption(l10n.periodThisMonth, (p) {
                        final now = DateTime.now();
                        return p.createdAt.year == now.year &&
                            p.createdAt.month == now.month;
                      }),
                      AppFilterOption(
                        l10n.periodLast30Days,
                        (p) => p.createdAt.isAfter(
                          DateTime.now().subtract(const Duration(days: 30)),
                        ),
                      ),
                    ],
                  ),
                ],
                onAdd: _create,
                addLabel: l10n.newPurchase,
              ),
            ),
      floatingActionButton: AppAddFab(
        onPressed: _create,
        label: l10n.newPurchase,
      ),
    );
  }
}
