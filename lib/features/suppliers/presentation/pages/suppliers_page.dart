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
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_side_panel.dart';
import '../widgets/supplier_detail_body.dart';
import '../../../../core/errors/error_text.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  /// The supplier open in the side panel (wide screens only).
  String? selectedId;

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
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  /// Wide: open the side panel. Phone: open the detail page.
  Future<void> _openDetail(SupplierEntity s) async {
    if (AppBreakpoints.isWide(context)) {
      setState(() => selectedId = s.id);
      return;
    }
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => SupplierDetailPage(supplierId: s.id)),
    );
    if (mounted) ref.read(supplierListProvider.notifier).load();
  }

  // Delivery reliability is shown on the supplier's detail page only.
  Widget _statusBadge(SupplierEntity s, AppLocalizations l10n) => s.owesMoney
      ? AppBadge(label: l10n.statusToPay, tone: BadgeTone.warning)
      : AppBadge(label: l10n.statusNoBalance, tone: BadgeTone.success);

  // Order: name, information, amounts, Status, ⋮.
  List<AppTableColumn<SupplierEntity>> _columns(AppLocalizations l10n) => [
    AppTableColumn(
      label: l10n.supplier,
      sortValue: (s) => s.name.toLowerCase(),
      cell: (s) =>
          AppCellText(s.name, strong: true, maxLines: 2, sub: s.contactPerson),
    ),
    AppTableColumn(
      label: l10n.phone,
      showFrom: 760,
      measure: (s) => s.phone ?? '—',
      sortValue: (s) => s.phone ?? '',
      cell: (s) => AppCellText(s.phone ?? '—', color: AppColors.textSecondary),
    ),
    AppTableColumn(
      label: l10n.orders,
      numeric: true,
      showFrom: 600,
      measure: (s) => '${s.orderCount}',
      sortValue: (s) => s.orderCount,
      cell: (s) => AppCellText('${s.orderCount}', numeric: true),
    ),
    AppTableColumn(
      label: l10n.amountOwed,
      numeric: true,
      measure: (s) => formatDT(s.balance > 0 ? s.balance : 0),
      sortValue: (s) => s.balance,
      cell: (s) =>
          AppCellText(formatDT(s.balance > 0 ? s.balance : 0), numeric: true),
    ),
    AppTableColumn(
      label: l10n.status,
      chip: true,
      measure: (s) => s.owesMoney ? l10n.statusToPay : l10n.statusNoBalance,
      sortValue: (s) => s.owesMoney ? 1 : 0,
      cell: (s) => _statusBadge(s, l10n),
    ),
  ];

  Widget _rowMenu(SupplierEntity s, AppLocalizations l10n) => AppRowMenu(
    actions: [
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
    final state = ref.watch(supplierListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(supplierListProvider, (previous, next) {
      if (next.error != null) {
        _showSnack(errorText(next.error, l10n), isError: true);
      }
    });

    final subtitle = state.suppliers.isEmpty
        ? null
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
              title: state.hasSearched ? l10n.noResults : l10n.noSuppliers,
              subtitle: state.hasSearched ? l10n.tryDifferentSearch : '',
              actionLabel: state.hasSearched ? null : l10n.supplier,
              onAction: _create,
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(supplierListProvider.notifier).load(),
              child: AppDataTable<SupplierEntity>(
                columns: _columns(l10n),
                rows: state.suppliers,
                initialSortColumn: 0,
                onRowTap: _openDetail,
                rowMenu: (s) => _rowMenu(s, l10n),
                searchText: (s) =>
                    '${s.name} ${s.contactPerson ?? ''} ${s.phone ?? ''}',
                searchHint: l10n.searchSuppliers,
                tabs: AppTableFilter(
                  label: l10n.status,
                  options: [
                    AppFilterOption(l10n.filterAll),
                    AppFilterOption(l10n.statusToPay, (s) => s.owesMoney),
                    AppFilterOption(
                      l10n.statusNoBalance,
                      (s) => !s.owesMoney,
                    ),
                  ],
                ),
                summary: [
                  AppTableStat(
                    label: l10n.suppliers,
                    value: '${state.suppliers.length}',
                    tab: 0,
                  ),
                  AppTableStat(
                    label: l10n.amountOwed,
                    value: formatDT(state.suppliers.fold<double>(
                        0, (t, s) => t + (s.balance > 0 ? s.balance : 0))),
                    color: AppColors.warningText,
                    tab: 1,
                  ),
                ],
                isSelected: (s) => s.id == selectedId,
                onSelectionHidden: () => setState(() => selectedId = null),
                detailPanel: selectedId == null
                    ? null
                    : AppSidePanel(
                        closeLabel: l10n.close,
                        onClose: () => setState(() => selectedId = null),
                        child: SupplierDetailBody(
                          supplierId: selectedId!,
                          compact: true,
                          onChanged: () =>
                              ref.read(supplierListProvider.notifier).load(),
                        ),
                      ),
                onAdd: _create,
                addLabel: l10n.supplier,
              ),
            ),
      floatingActionButton: AppAddFab(onPressed: _create, label: l10n.supplier),
    );
  }
}
