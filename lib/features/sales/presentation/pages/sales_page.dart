import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../../domain/entities/sale_entity.dart';
import '../providers/sale_provider.dart';
import 'create_sale_page.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../shared/widgets/app_invoice_panel.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_side_panel.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../../../core/errors/error_text.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  /// The sale open in the side panel (wide screens only).
  String? selectedId;

  /// Wide: open the invoice panel. Phone: the invoice on its own screen,
  /// with Record payment and Edit in a bar at the bottom.
  void _open(SaleEntity s, AppLocalizations l10n) {
    if (AppBreakpoints.isWide(context)) {
      setState(() => selectedId = s.id);
    } else {
      _openInvoice(s, l10n);
    }
  }

  Future<void> _openInvoice(SaleEntity row, AppLocalizations l10n) async {
    final nav = Navigator.of(context, rootNavigator: true);
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    await nav.push(MaterialPageRoute(
      builder: (_) => AppInvoicePage(
        title: row.reference ?? l10n.sale,
        body: _invoice(row, l10n, phone: true),
        primary: row.isFullyPaid
            ? null
            : FilledButton(
                style: FilledButton.styleFrom(shape: shape),
                onPressed: () {
                  nav.pop();
                  _openPayment(row, l10n);
                },
                child: Text(l10n.recordPayment),
              ),
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
    if (mounted) ref.read(saleListProvider.notifier).load();
  }

  Widget _panel(SaleEntity row, AppLocalizations l10n) => AppSidePanel(
        closeLabel: l10n.close,
        onClose: () => setState(() => selectedId = null),
        child: _invoice(row, l10n),
      );

  Widget _invoice(SaleEntity row, AppLocalizations l10n, {bool phone = false}) {
    final st = _paymentStatus(row, l10n);
    return AppDetailLoader<SaleDetail>(
        // A payment or edit changes the row; reload the panel with it.
        key: ValueKey('${row.id}-${row.paid}-${row.total}'),
        id: row.id,
        load: (id) => ref.read(saleRepositoryProvider).getSaleDetail(id),
        errorMessage: (code) => errorText(code, l10n),
        retryLabel: l10n.retry,
        builder: (d) => AppInvoicePanel(
          party: row.customerName,
          reference: row.reference,
          status: AppBadge(label: st.label, tone: st.tone),
          dates: [
            l10n.issuedOn(formatDate(row.createdAt)),
            if (row.dueDate != null) l10n.dueOn(formatDate(row.dueDate!)),
          ].join(' · '),
          subtotal: row.subtotalHt,
          vat: row.totalVat,
          total: row.total,
          paid: row.paid,
          phone: phone,
          lines: [
            for (final l in d.lines)
              AppInvoiceLine(l.productName, l.quantity, l.quantity * l.unitPrice),
          ],
          actions: phone ? const [] : [
            if (!row.isFullyPaid)
              FilledButton.icon(
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
    Future.microtask(() => ref.read(saleListProvider.notifier).load());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    AppSnack.show(context, message, error: isError);
  }

  Future<void> _openPayment(SaleEntity s, AppLocalizations l10n) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          saleId: s.id,
          title: '${l10n.payment} — ${s.customerName}',
        ),
      ),
    );
    if (mounted) ref.read(saleListProvider.notifier).load();
  }

  Future<void> _create() async {
    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(
            fullscreenDialog: true, builder: (_) => const CreateSalePage()));
    if (mounted) ref.read(saleListProvider.notifier).load();
  }

  Future<void> _edit(SaleEntity s, AppLocalizations l10n) async {
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(builder: (_) => CreateSalePage(existingSaleId: s.id)),
    );
    if (changed == true && mounted) {
      _showSnack(l10n.saleUpdated);
      ref.read(saleListProvider.notifier).load();
    }
  }

  Future<void> _delete(SaleEntity s, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(s.customerName)),
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

    final error = await ref.read(saleListProvider.notifier).remove(s.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.saleDeleted);
    } else if (error == 'SALE_HAS_PAYMENTS') {
      _showSnack(l10n.saleHasPayments, isError: true);
    } else {
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  /// One status per sale: overdue beats partially paid beats unpaid.
  ({String label, BadgeTone tone}) _paymentStatus(
    SaleEntity s,
    AppLocalizations l10n,
  ) {
    if (s.isFullyPaid) return (label: l10n.paid, tone: BadgeTone.success);
    if (s.isOverdue) return (label: l10n.overdue, tone: BadgeTone.danger);
    if (s.paid > 0.009) {
      return (label: l10n.partiallyPaid, tone: BadgeTone.warning);
    }
    return (label: l10n.unpaid, tone: BadgeTone.warning);
  }

  int _statusRank(SaleEntity s) => s.isFullyPaid
      ? 0
      : s.isOverdue
      ? 3
      : s.paid > 0.009
      ? 1
      : 2;

  // Order: name, information, amounts, Status, ⋮.
  List<AppTableColumn<SaleEntity>> _columns(AppLocalizations l10n) => [
    AppTableColumn(
      label: l10n.customer,
      sortValue: (s) => s.customerName.toLowerCase(),
      // The date sits under the name only when the Date column is hidden.
      cell: (s) => Builder(
        builder: (context) => AppCellText(
          s.customerName,
          strong: true,
          maxLines: 2,
          sub: AppTableWidth.of(context) >= 760
              ? null
              : formatDate(s.createdAt),
        ),
      ),
    ),
    AppTableColumn(
      label: l10n.date,
      showFrom: 760,
      measure: (s) => formatDate(s.createdAt),
      sortValue: (s) => s.createdAt,
      cell: (s) =>
          AppCellText(formatDate(s.createdAt), color: AppColors.textSecondary),
    ),
    AppTableColumn(
      label: l10n.colBalance,
      numeric: true,
      showFrom: 600,
      measure: (s) => s.isFullyPaid ? '—' : formatDT(s.balance),
      sortValue: (s) => s.balance,
      cell: (s) => AppCellText(
        s.isFullyPaid ? '—' : formatDT(s.balance),
        numeric: true,
        color: AppColors.textSecondary,
      ),
    ),
    AppTableColumn(
      label: l10n.colTotalInclVat,
      shortLabel: l10n.total,
      numeric: true,
      measure: (s) => formatDT(s.total),
      sortValue: (s) => s.total,
      cell: (s) => AppCellText(formatDT(s.total), numeric: true),
    ),
    AppTableColumn(
      label: l10n.status,
      chip: true,
      measure: (s) => _paymentStatus(s, l10n).label,
      sortValue: _statusRank,
      cell: (s) {
        final st = _paymentStatus(s, l10n);
        return AppBadge(label: st.label, tone: st.tone);
      },
    ),
  ];

  Widget _rowMenu(SaleEntity s, AppLocalizations l10n) => AppRowMenu(
    actions: [
      AppMenuAction(
        label: l10n.payment,
        icon: Icons.payments_outlined,
        onTap: () => _openPayment(s, l10n),
      ),
      AppMenuAction(
        label: l10n.edit,
        icon: Icons.edit_outlined,
        onTap: () => _edit(s, l10n),
      ),
      AppMenuAction(
        label: l10n.delete,
        icon: Icons.delete_outline,
        destructive: true,
        onTap: () => _delete(s, l10n),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saleListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(saleListProvider, (previous, next) {
      if (next.error != null) {
        _showSnack(errorText(next.error, l10n), isError: true);
      }
    });

    // Just the count: the amounts are in the summary strip below.
    final subtitle = state.sales.isEmpty
        ? null
        : '${state.sales.length} ${l10n.sales.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: searchVisible
          ? AppSearchHeader(
              controller: searchController,
              hint: l10n.searchSales,
              onChanged: (v) => ref.read(saleListProvider.notifier).search(v),
              onClose: () {
                setState(() => searchVisible = false);
                searchController.clear();
                ref.read(saleListProvider.notifier).clearSearch();
              },
            )
          : AppPageHeader(
              title: l10n.sales,
              subtitle: subtitle,
              icon: Icons.point_of_sale_outlined,
              color: AppColors.sales,
              actions: [
              ],
            ),
      body: state.isLoading
          ? AppSkeletonList(semanticLabel: l10n.loading)
          : state.error != null && state.sales.isEmpty
          ? AppErrorState(
              title: l10n.loadFailedTitle,
              message: l10n.serverUnreachable,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(saleListProvider.notifier).load(),
            )
          : state.sales.isEmpty
          ? AppEmptyState(
              icon: state.hasSearched
                  ? Icons.search_off
                  : Icons.point_of_sale_outlined,
              title: state.hasSearched ? l10n.noResults : l10n.noSales,
              subtitle: state.hasSearched
                  ? l10n.tryDifferentSearch
                  : l10n.tapPlusToCreate,
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(saleListProvider.notifier).load(),
              child: AppDataTable<SaleEntity>(
                columns: _columns(l10n),
                rows: state.sales,
                // Newest first, like an invoice book.
                initialSortColumn: 1,
                initialAscending: false,
                phoneGroup: (s) => phoneDayGroup(l10n,
                    Localizations.localeOf(context).toString(), s.createdAt),
                phoneLeading: (s) =>
                    AppAvatar(s.customerName, size: 38, square: true),
                onRowTap: (s) => _open(s, l10n),
                rowMenu: (s) => _rowMenu(s, l10n),
                searchText: (s) => '${s.customerName} ${s.reference ?? ''}',
                searchHint: l10n.searchSales,
                tabs: AppTableFilter(
                  label: l10n.status,
                  options: [
                    AppFilterOption(l10n.filterAll),
                    AppFilterOption(l10n.unpaid, (s) => !s.isFullyPaid),
                    AppFilterOption(
                      l10n.partiallyPaid,
                      (s) => !s.isFullyPaid && !s.isOverdue && s.paid > 0.009,
                    ),
                    AppFilterOption(l10n.overdue, (s) => s.isOverdue),
                    AppFilterOption(l10n.paid, (s) => s.isFullyPaid),
                  ],
                ),
                summary: [
                  AppTableStat(
                    label: l10n.statInvoiced,
                    value: formatDT(state.sales.fold<double>(0, (t, s) => t + s.total)),
                    tab: 0,
                  ),
                  AppTableStat(
                    label: l10n.paid,
                    value: formatDT(state.sales.fold<double>(0, (t, s) => t + s.paid)),
                    color: AppColors.successText,
                    tab: 4,
                  ),
                  AppTableStat(
                    label: l10n.toCollect,
                    value: formatDT(state.sales.fold<double>(
                        0, (t, s) => t + (s.balance > 0 ? s.balance : 0))),
                    color: AppColors.warningText,
                    tab: 1,
                  ),
                  AppTableStat(
                    label: l10n.overdue,
                    value: formatDT(state.sales
                        .where((s) => s.isOverdue)
                        .fold<double>(0, (t, s) => t + s.balance)),
                    color: AppColors.dangerText,
                    tab: 3,
                  ),
                ],
                isSelected: (s) => s.id == selectedId,
                onSelectionHidden: () => setState(() => selectedId = null),
                detailPanel: selectedId == null ||
                        !state.sales.any((s) => s.id == selectedId)
                    ? null
                    : _panel(
                        state.sales.firstWhere((s) => s.id == selectedId), l10n),
                filters: [
                  AppTableFilter(
                    label: l10n.date,
                    options: [
                      AppFilterOption(l10n.periodAll),
                      AppFilterOption(l10n.periodThisMonth, (s) {
                        final now = DateTime.now();
                        return s.createdAt.year == now.year &&
                            s.createdAt.month == now.month;
                      }),
                      AppFilterOption(
                        l10n.periodLast30Days,
                        (s) => s.createdAt.isAfter(
                          DateTime.now().subtract(const Duration(days: 30)),
                        ),
                      ),
                    ],
                  ),
                ],
                onAdd: _create,
                addLabel: l10n.newSale,
              ),
            ),
      floatingActionButton: AppAddFab(onPressed: _create, label: l10n.newSale),
    );
  }
}
