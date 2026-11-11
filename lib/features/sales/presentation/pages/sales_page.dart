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
import '../../../../core/errors/error_text.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

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
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => PaymentPage(
        saleId: s.id,
        title: '${l10n.payment} — ${s.customerName}',
      ),
    ));
    if (mounted) ref.read(saleListProvider.notifier).load();
  }

  Future<void> _create() async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const CreateSalePage()),
    );
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
      SaleEntity s, AppLocalizations l10n) {
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

  List<AppTableColumn<SaleEntity>> _columns(AppLocalizations l10n) => [
        AppTableColumn(
          label: l10n.customer,
          flex: 4,
          sortValue: (s) => s.customerName.toLowerCase(),
          cell: (s) => AppCellText(s.customerName,
              strong: true, sub: formatDate(s.createdAt)),
        ),
        AppTableColumn(
          label: l10n.date,
          width: 96,
          showFrom: 760,
          sortValue: (s) => s.createdAt,
          cell: (s) => AppCellText(formatDate(s.createdAt),
              color: AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.colBalance,
          width: 108,
          numeric: true,
          showFrom: 600,
          sortValue: (s) => s.balance,
          cell: (s) => AppCellText(
              s.isFullyPaid ? '—' : formatDT(s.balance),
              numeric: true,
              color: AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.colTotalInclVat,
          width: 112,
          numeric: true,
          sortValue: (s) => s.total,
          cell: (s) => AppCellText(formatDT(s.total), numeric: true),
        ),
        AppTableColumn(
          label: l10n.status,
          width: 104,
          sortValue: _statusRank,
          cell: (s) {
            final st = _paymentStatus(s, l10n);
            return AppBadge(label: st.label, tone: st.tone);
          },
        ),
      ];

  Widget _rowMenu(SaleEntity s, AppLocalizations l10n) => AppRowMenu(actions: [
        AppMenuAction(
            label: l10n.payment,
            icon: Icons.payments_outlined,
            onTap: () => _openPayment(s, l10n)),
        AppMenuAction(
            label: l10n.edit, icon: Icons.edit_outlined, onTap: () => _edit(s, l10n)),
        AppMenuAction(
            label: l10n.delete,
            icon: Icons.delete_outline,
            destructive: true,
            onTap: () => _delete(s, l10n)),
      ]);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saleListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(saleListProvider, (previous, next) {
      if (next.error != null) _showSnack(errorText(next.error, l10n), isError: true);
    });

    final outstanding = state.sales
        .where((s) => !s.isFullyPaid)
        .fold<double>(0, (sum, s) => sum + s.balance);
    final subtitle = state.sales.isEmpty
        ? null
        : outstanding > 0.009
        ? '${state.sales.length} · ${formatDT(outstanding)} ${l10n.unpaid.toLowerCase()}'
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
          AppHeaderAction(
            icon: Icons.search,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
          AppHeaderAddButton(onPressed: _create, label: l10n.newSale),
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
          onRowTap: (s) => _openPayment(s, l10n),
          rowMenu: (s) => _rowMenu(s, l10n),
        ),
      ),
      floatingActionButton: AppAddFab(onPressed: _create, label: l10n.newSale),
    );
  }
}