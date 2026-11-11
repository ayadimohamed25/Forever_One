import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../providers/warehouse_provider.dart';
import 'warehouse_form_page.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../core/errors/error_text.dart';

class WarehousesPage extends ConsumerStatefulWidget {
  const WarehousesPage({super.key});

  @override
  ConsumerState<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends ConsumerState<WarehousesPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(warehouseListProvider.notifier).load());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    AppSnack.show(context, message, error: isError);
  }

  Future<void> _openForm(AppLocalizations l10n,
      {WarehouseEntity? existing}) async {
    final input = await Navigator.of(context, rootNavigator: true).push<WarehouseInput>(
      MaterialPageRoute(
          builder: (_) => WarehouseFormPage(existing: existing)),
    );
    if (input == null) return;

    if (existing == null) {
      await ref.read(warehouseListProvider.notifier).add(input);
    } else {
      await ref
          .read(warehouseListProvider.notifier)
          .update(existing.id, input);
      if (mounted) _showSnack(l10n.warehouseUpdated);
    }
  }

  Future<void> _delete(WarehouseEntity w, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(w.name)),
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

    final error =
    await ref.read(warehouseListProvider.notifier).remove(w.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.warehouseDeleted);
    } else if (error == 'WAREHOUSE_IN_USE') {
      _showSnack(l10n.warehouseInUse, isError: true);
    } else {
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  List<AppTableColumn<WarehouseEntity>> _columns(AppLocalizations l10n) => [
        AppTableColumn(
          label: l10n.warehouse,
          flex: 4,
          sortValue: (w) => w.name.toLowerCase(),
          cell: (w) => Opacity(
            opacity: w.isActive ? 1 : 0.55,
            child: AppCellText(w.name, strong: true, sub: w.location),
          ),
        ),
        AppTableColumn(
          label: l10n.manager,
          flex: 3,
          showFrom: 760,
          sortValue: (w) => (w.managerName ?? '').toLowerCase(),
          cell: (w) => AppCellText(w.managerName ?? '—'),
        ),
        AppTableColumn(
          label: l10n.colProducts,
          width: 80,
          numeric: true,
          sortValue: (w) => w.productCount,
          cell: (w) => AppCellText('${w.productCount}', numeric: true),
        ),
        AppTableColumn(
          label: l10n.stockValue,
          width: 120,
          numeric: true,
          sortValue: (w) => w.stockValue,
          cell: (w) => AppCellText(formatDT(w.stockValue), numeric: true),
        ),
      ];

  Widget _rowMenu(WarehouseEntity w, AppLocalizations l10n) => AppRowMenu(actions: [
        AppMenuAction(
            label: l10n.edit,
            icon: Icons.edit_outlined,
            onTap: () => _openForm(l10n, existing: w)),
        AppMenuAction(
            label: l10n.delete,
            icon: Icons.delete_outline,
            destructive: true,
            onTap: () => _delete(w, l10n)),
      ]);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(warehouseListProvider, (previous, next) {
      if (next.error != null) _showSnack(errorText(next.error, l10n), isError: true);
    });

    final totalValue =
    state.warehouses.fold<double>(0, (sum, w) => sum + w.stockValue);
    final subtitle = state.warehouses.isEmpty
        ? null
        : '${state.warehouses.length} · ${formatDT(totalValue)}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: searchVisible
          ? AppSearchHeader(
        controller: searchController,
        hint: l10n.searchWarehouses,
        onChanged: (v) =>
            ref.read(warehouseListProvider.notifier).search(v),
        onClose: () {
          setState(() => searchVisible = false);
          searchController.clear();
          ref.read(warehouseListProvider.notifier).clearSearch();
        },
      )
          : AppPageHeader(
        title: l10n.warehouses,
        subtitle: subtitle,
        icon: Icons.warehouse_outlined,
        color: AppColors.stock,
        actions: [
          AppHeaderAction(
            icon: Icons.search,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
          AppHeaderAddButton(onPressed: () => _openForm(l10n), label: l10n.warehouse),
        ],
      ),
      body: state.isLoading
          ? AppSkeletonList(semanticLabel: l10n.loading)
          : state.error != null && state.warehouses.isEmpty
          ? AppErrorState(
              title: l10n.loadFailedTitle,
              message: l10n.serverUnreachable,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(warehouseListProvider.notifier).load(),
            )
          : state.warehouses.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.warehouse_outlined,
        title: state.hasSearched
            ? l10n.noResults
            : l10n.noWarehouses,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : '',
          actionLabel: state.hasSearched ? null : l10n.warehouse,
          onAction: () => _openForm(l10n),
      )
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(warehouseListProvider.notifier).load(),
        child: AppDataTable<WarehouseEntity>(
          columns: _columns(l10n),
          rows: state.warehouses,
          initialSortColumn: 0,
          onRowTap: (w) => _openForm(l10n, existing: w),
          rowMenu: (w) => _rowMenu(w, l10n),
        ),
      ),
      floatingActionButton: AppAddFab(onPressed: () => _openForm(l10n), label: l10n.warehouse),
    );
  }
}