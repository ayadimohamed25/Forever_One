import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../providers/warehouse_provider.dart';
import 'warehouse_form_page.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  Future<void> _openForm(AppLocalizations l10n,
      {WarehouseEntity? existing}) async {
    final input = await Navigator.of(context).push<WarehouseInput>(
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
      _showSnack(error, isError: true);
    }
  }

  Widget _card(WarehouseEntity w, AppLocalizations l10n) {
    final details = [w.code, w.location, w.managerName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Opacity(
      opacity: w.isActive ? 1 : 0.6,
      child: AppCard(
        onTap: () => _openForm(l10n, existing: w),
        padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLeadingTile.icon(Icons.warehouse_outlined),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.name, style: AppTheme.rowTitle, maxLines: 2),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(details.join(' · '),
                        style: AppTheme.label, maxLines: 2),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.unitsInStock(w.totalUnits)} · ${l10n.productCount(w.productCount)}',
                    style: AppTheme.label,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  AppBadge(
                    label: w.isActive ? l10n.active : l10n.inactive,
                    tone: w.isActive ? BadgeTone.success : BadgeTone.neutral,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatDT(w.stockValue), style: AppTheme.money),
                const SizedBox(height: 3),
                Text(l10n.stockValue, style: AppTheme.label),
              ],
            ),
            AppRowMenu(actions: [
              AppMenuAction(
                label: l10n.edit,
                icon: Icons.edit_outlined,
                onTap: () => _openForm(l10n, existing: w),
              ),
              AppMenuAction(
                label: l10n.delete,
                icon: Icons.delete_outline,
                destructive: true,
                onTap: () => _delete(w, l10n),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(warehouseListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    final totalValue =
    state.warehouses.fold<double>(0, (sum, w) => sum + w.stockValue);
    final subtitle = state.warehouses.isEmpty
        ? null
        : '${state.warehouses.length} · ${formatDT(totalValue)}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      drawer: const AppDrawer(currentRoute: '/warehouses'),
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
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
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
            : l10n.tapPlusToAdd,
      )
          : RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () =>
            ref.read(warehouseListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: state.warehouses.length,
          itemBuilder: (context, index) =>
              _card(state.warehouses[index], l10n),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(l10n),
        backgroundColor: AppColors.black,
        icon: const Icon(Icons.add),
        label: Text(l10n.warehouse),
      ),
    );
  }
}