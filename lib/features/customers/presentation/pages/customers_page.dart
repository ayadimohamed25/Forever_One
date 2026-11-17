import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/customer_entity.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_form_route.dart';
import 'customer_detail_page.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_side_panel.dart';
import '../widgets/customer_detail_body.dart';
import '../../../../core/errors/error_text.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  /// The customer open in the side panel (wide screens only).
  String? selectedId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(customerListProvider.notifier).load());
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
    final input = await openCustomerForm(context);
    if (input == null) return;
    await ref.read(customerListProvider.notifier).add(input);
  }

  Future<void> _edit(CustomerEntity c, AppLocalizations l10n) async {
    final input = await openCustomerForm(context, existing: c);
    if (input == null) return;
    await ref.read(customerListProvider.notifier).update(c.id, input);
    if (mounted) _showSnack(l10n.customerUpdated);
  }

  Future<void> _delete(CustomerEntity c, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(c.name)),
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

    final error = await ref.read(customerListProvider.notifier).remove(c.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.customerDeleted);
    } else if (error == 'CUSTOMER_IN_USE') {
      _showSnack(l10n.customerInUse, isError: true);
    } else {
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  /// Wide: open the side panel. Phone: open the detail page.
  Future<void> _openDetail(CustomerEntity c) async {
    if (AppBreakpoints.isWide(context)) {
      setState(() => selectedId = c.id);
      return;
    }
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => CustomerDetailPage(customerId: c.id)),
    );
    if (mounted) ref.read(customerListProvider.notifier).load();
  }

  /// One status per customer: over the credit limit beats unpaid beats
  /// settled.
  Widget _statusBadge(CustomerEntity c, AppLocalizations l10n) {
    if (c.isOverCreditLimit) {
      return AppBadge(label: l10n.statusOverLimit, tone: BadgeTone.danger);
    }
    if (c.owesMoney) {
      return AppBadge(label: l10n.unpaid, tone: BadgeTone.warning);
    }
    return AppBadge(label: l10n.statusUpToDate, tone: BadgeTone.success);
  }

  // Order: name, information, amounts, Status, ⋮.
  List<AppTableColumn<CustomerEntity>> _columns(AppLocalizations l10n) => [
    AppTableColumn(
      label: l10n.customer,
      sortValue: (c) => c.name.toLowerCase(),
      cell: (c) => Row(
        children: [
          AppAvatar(c.name, size: 38, square: true),
          const SizedBox(width: 10),
          Expanded(
            child: AppCellText(c.name, strong: true, maxLines: 2, sub: c.phone),
          ),
        ],
      ),
    ),
    AppTableColumn(
      label: l10n.email,
      showFrom: 760,
      maxWidth: 220,
      measure: (c) => c.email ?? '—',
      sortValue: (c) => (c.email ?? '').toLowerCase(),
      cell: (c) => AppCellText(c.email ?? '—', color: AppColors.textSecondary),
    ),
    AppTableColumn(
      label: l10n.orders,
      numeric: true,
      showFrom: 480,
      measure: (c) => '${c.orderCount}',
      sortValue: (c) => c.orderCount,
      cell: (c) => AppCellText('${c.orderCount}', numeric: true),
    ),
    AppTableColumn(
      label: l10n.colBalance,
      numeric: true,
      // A settled customer shows a dash, not "0.00 DT": the eye goes
      // straight to the amounts that matter.
      measure: (c) => c.owesMoney ? formatDT(c.balance) : '—',
      sortValue: (c) => c.balance,
      cell: (c) => AppCellText(
        c.owesMoney ? formatDT(c.balance) : '—',
        numeric: true,
        color: !c.owesMoney
            ? AppColors.textSecondary
            : c.isOverCreditLimit
            ? AppColors.dangerText
            : AppColors.textPrimary,
      ),
    ),
    AppTableColumn(
      label: l10n.status,
      chip: true,
      measure: (c) => _statusLabel(c, l10n),
      sortValue: (c) => c.isOverCreditLimit ? 2 : (c.owesMoney ? 1 : 0),
      cell: (c) => _statusBadge(c, l10n),
    ),
  ];

  String _statusLabel(CustomerEntity c, AppLocalizations l10n) =>
      c.isOverCreditLimit
      ? l10n.statusOverLimit
      : c.owesMoney
      ? l10n.unpaid
      : l10n.statusUpToDate;

  Widget _rowMenu(CustomerEntity c, AppLocalizations l10n) => AppRowMenu(
    actions: [
      AppMenuAction(
        label: l10n.edit,
        icon: Icons.edit_outlined,
        onTap: () => _edit(c, l10n),
      ),
      AppMenuAction(
        label: l10n.delete,
        icon: Icons.delete_outline,
        destructive: true,
        onTap: () => _delete(c, l10n),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(customerListProvider, (previous, next) {
      if (next.error != null) {
        _showSnack(errorText(next.error, l10n), isError: true);
      }
    });

    // Just the count: the balance is in the summary strip below.
    final subtitle = state.customers.isEmpty
        ? null
        : '${state.customers.length} ${l10n.customers.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: searchVisible
          ? AppSearchHeader(
              controller: searchController,
              hint: l10n.searchCustomers,
              onChanged: (v) =>
                  ref.read(customerListProvider.notifier).search(v),
              onClose: () {
                setState(() => searchVisible = false);
                searchController.clear();
                ref.read(customerListProvider.notifier).clearSearch();
              },
            )
          : AppPageHeader(
              title: l10n.customers,
              subtitle: subtitle,
              icon: Icons.people_outline,
              color: AppColors.finance,
              actions: [
              ],
            ),
      body: state.isLoading
          ? AppSkeletonList(semanticLabel: l10n.loading)
          : state.error != null && state.customers.isEmpty
          ? AppErrorState(
              title: l10n.loadFailedTitle,
              message: l10n.serverUnreachable,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(customerListProvider.notifier).load(),
            )
          : state.customers.isEmpty
          ? AppEmptyState(
              icon: state.hasSearched ? Icons.search_off : Icons.people_outline,
              title: state.hasSearched ? l10n.noResults : l10n.noCustomers,
              subtitle: state.hasSearched ? l10n.tryDifferentSearch : '',
              actionLabel: state.hasSearched ? null : l10n.customer,
              onAction: _create,
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(customerListProvider.notifier).load(),
              child: AppDataTable<CustomerEntity>(
                columns: _columns(l10n),
                rows: state.customers,
                initialSortColumn: 0,
                onRowTap: _openDetail,
                rowMenu: (c) => _rowMenu(c, l10n),
                searchText: (c) =>
                    '${c.name} ${c.phone ?? ''} ${c.email ?? ''}',
                searchHint: l10n.searchCustomers,
                tabs: AppTableFilter(
                  label: l10n.status,
                  options: [
                    AppFilterOption(l10n.filterAll),
                    AppFilterOption(l10n.unpaid, (c) => c.owesMoney),
                    AppFilterOption(
                      l10n.statusOverLimit,
                      (c) => c.isOverCreditLimit,
                    ),
                    AppFilterOption(l10n.statusUpToDate, (c) => !c.owesMoney),
                  ],
                ),
                summary: [
                  AppTableStat(
                    label: l10n.customers,
                    value: '${state.customers.length}',
                    tab: 0,
                  ),
                  AppTableStat(
                    label: l10n.outstandingBalance,
                    value: formatDT(state.customers.fold<double>(
                        0, (s, c) => s + (c.balance > 0 ? c.balance : 0))),
                    color: AppColors.warningText,
                    tab: 1,
                  ),
                  AppTableStat(
                    label: l10n.statusOverLimit,
                    value:
                        '${state.customers.where((c) => c.isOverCreditLimit).length}',
                    color: AppColors.dangerText,
                    tab: 2,
                  ),
                ],
                isSelected: (c) => c.id == selectedId,
                onSelectionHidden: () => setState(() => selectedId = null),
                detailPanel: selectedId == null
                    ? null
                    : AppSidePanel(
                        closeLabel: l10n.close,
                        onClose: () => setState(() => selectedId = null),
                        child: CustomerDetailBody(
                          customerId: selectedId!,
                          compact: true,
                          onChanged: () =>
                              ref.read(customerListProvider.notifier).load(),
                        ),
                      ),
                onAdd: _create,
                addLabel: l10n.customer,
              ),
            ),
      floatingActionButton: AppAddFab(onPressed: _create, label: l10n.customer),
    );
  }
}
