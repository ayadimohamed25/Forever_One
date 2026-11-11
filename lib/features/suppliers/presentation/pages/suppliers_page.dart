import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/supplier_entity.dart';
import '../providers/supplier_provider.dart';
import 'supplier_form_page.dart';
import 'supplier_detail_page.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../shared/widgets/app_data_table.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(supplierListProvider.notifier).load());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    AppSnack.show(context, message, error: isError);
  }

  Future<void> _create() async {
    final input = await openSupplierForm(context);
    if (input == null) return;
    await ref.read(supplierListProvider.notifier).add(input);
  }

  Future<void> _edit(SupplierEntity s, AppLocalizations l10n) async {
    final input = await openSupplierForm(context, existing: s);
    if (input == null) return;
    await ref.read(supplierListProvider.notifier).update(s.id, input);
    if (mounted) _showSnack(l10n.supplierUpdated);
  }

  Future<void> _delete(SupplierEntity s, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(s.name)),
        content: Text(l10n.deleteConfirmMessage),
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

    final error = await ref.read(supplierListProvider.notifier).remove(s.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.supplierDeleted);
    } else if (error == 'SUPPLIER_IN_USE') {
      _showSnack(l10n.supplierInUse, isError: true);
    } else {
      _showSnack(error, isError: true);
    }
  }

  Future<void> _openDetail(SupplierEntity s) async {
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => SupplierDetailPage(supplierId: s.id),
    ));
    if (mounted) ref.read(supplierListProvider.notifier).load();
  }

  // Delivery reliability is shown on the supplier's detail page only.
  Widget _statusBadge(SupplierEntity s, AppLocalizations l10n) => s.owesMoney
      ? AppBadge(label: l10n.statusToPay, tone: BadgeTone.warning)
      : AppBadge(label: l10n.statusNoBalance, tone: BadgeTone.success);

  List<AppTableColumn<SupplierEntity>> _columns(AppLocalizations l10n) => [
        AppTableColumn(
          label: l10n.supplier,
          flex: 4,
          sortValue: (s) => s.name.toLowerCase(),
          cell: (s) => AppCellText(s.name, strong: true, sub: s.contactPerson),
        ),
        AppTableColumn(
          label: l10n.phone,
          flex: 2,
          showFrom: 760,
          sortValue: (s) => s.phone ?? '',
          cell: (s) => AppCellText(s.phone ?? '—', color: AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.orders,
          width: 60,
          numeric: true,
          showFrom: 600,
          sortValue: (s) => s.orderCount,
          cell: (s) => AppCellText('${s.orderCount}', numeric: true),
        ),
        AppTableColumn(
          label: l10n.amountOwed,
          width: 112,
          numeric: true,
          sortValue: (s) => s.balance,
          cell: (s) => AppCellText(formatDT(s.balance > 0 ? s.balance : 0),
              numeric: true),
        ),
        AppTableColumn(
          label: l10n.status,
          width: 84,
          sortValue: (s) => s.owesMoney ? 1 : 0,
          cell: (s) => _statusBadge(s, l10n),
        ),
      ];

  Widget _rowMenu(SupplierEntity s, AppLocalizations l10n) => AppRowMenu(actions: [
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
    final state = ref.watch(supplierListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(supplierListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    final owed =
    state.suppliers.fold<double>(0, (sum, s) => sum + (s.balance > 0 ? s.balance : 0));
    final subtitle = state.suppliers.isEmpty
        ? null
        : owed > 0.009
        ? '${state.suppliers.length} · ${formatDT(owed)} ${l10n.amountOwed.toLowerCase()}'
        : '${state.suppliers.length} ${l10n.suppliers.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: searchVisible
          ? AppSearchHeader(
        controller: searchController,
        hint: l10n.searchSuppliers,
        onChanged: (v) =>
            ref.read(supplierListProvider.notifier).search(v),
        onClose: () {
          setState(() => searchVisible = false);
          searchController.clear();
          ref.read(supplierListProvider.notifier).clearSearch();
        },
      )
          : AppPageHeader(
        title: l10n.suppliers,
        subtitle: subtitle,
        icon: Icons.local_shipping_outlined,
        color: AppColors.purchases,
        actions: [
          AppHeaderAction(
            icon: Icons.search,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
          AppHeaderAddButton(onPressed: _create, label: l10n.supplier),
        ],
      ),
      body: state.isLoading
          ? AppSkeletonList(semanticLabel: l10n.loading)
          : state.error != null && state.suppliers.isEmpty
          ? AppErrorState(
              title: l10n.loadFailedTitle,
              message: l10n.serverUnreachable,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(supplierListProvider.notifier).load(),
            )
          : state.suppliers.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.local_shipping_outlined,
        title:
        state.hasSearched ? l10n.noResults : l10n.noSuppliers,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : '',
          actionLabel: state.hasSearched ? null : l10n.supplier,
          onAction: _create,
      )
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(supplierListProvider.notifier).load(),
        child: AppDataTable<SupplierEntity>(
          columns: _columns(l10n),
          rows: state.suppliers,
          initialSortColumn: 0,
          onRowTap: _openDetail,
          rowMenu: (s) => _rowMenu(s, l10n),
        ),
      ),
      floatingActionButton: AppAddFab(onPressed: _create, label: l10n.supplier),
    );
  }
}