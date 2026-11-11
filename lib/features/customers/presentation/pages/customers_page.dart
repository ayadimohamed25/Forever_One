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

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

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
      _showSnack(error, isError: true);
    }
  }

  Future<void> _openDetail(CustomerEntity c) async {
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => CustomerDetailPage(customerId: c.id),
    ));
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

  List<AppTableColumn<CustomerEntity>> _columns(AppLocalizations l10n) => [
        AppTableColumn(
          label: l10n.customer,
          flex: 4,
          sortValue: (c) => c.name.toLowerCase(),
          cell: (c) => AppCellText(c.name, strong: true, sub: c.phone),
        ),
        AppTableColumn(
          label: l10n.email,
          flex: 3,
          showFrom: 760,
          sortValue: (c) => (c.email ?? '').toLowerCase(),
          cell: (c) => AppCellText(c.email ?? '—', color: AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.orders,
          width: 60,
          numeric: true,
          sortValue: (c) => c.orderCount,
          cell: (c) => AppCellText('${c.orderCount}', numeric: true),
        ),
        AppTableColumn(
          label: l10n.status,
          width: 116,
          showFrom: 600,
          sortValue: (c) => c.isOverCreditLimit ? 2 : (c.owesMoney ? 1 : 0),
          cell: (c) => _statusBadge(c, l10n),
        ),
        AppTableColumn(
          label: l10n.colBalance,
          width: 118,
          numeric: true,
          sortValue: (c) => c.balance,
          cell: (c) => LayoutBuilder(builder: (context, _) {
            final amount = AppCellText(
              formatDT(c.balance > 0 ? c.balance : 0),
              numeric: true,
              color: c.isOverCreditLimit
                  ? AppColors.dangerText
                  : AppColors.textPrimary,
            );
            // On phones the status chip sits under the balance; from 600px
            // it has its own column.
            if (MediaQuery.sizeOf(context).width >= 600) return amount;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [amount, const SizedBox(height: 4), _statusBadge(c, l10n)],
            );
          }),
        ),
      ];

  Widget _rowMenu(CustomerEntity c, AppLocalizations l10n) => AppRowMenu(actions: [
        AppMenuAction(
            label: l10n.edit, icon: Icons.edit_outlined, onTap: () => _edit(c, l10n)),
        AppMenuAction(
            label: l10n.delete,
            icon: Icons.delete_outline,
            destructive: true,
            onTap: () => _delete(c, l10n)),
      ]);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(customerListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    final outstanding = state.customers
        .where((c) => c.owesMoney)
        .fold<double>(0, (sum, c) => sum + c.balance);
    final subtitle = state.customers.isEmpty
        ? null
        : outstanding > 0.009
        ? '${state.customers.length} · ${formatDT(outstanding)} ${l10n.outstandingBalance.toLowerCase()}'
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
          AppHeaderAction(
            icon: Icons.search,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
          AppHeaderAddButton(onPressed: _create, label: l10n.customer),
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
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.people_outline,
        title:
        state.hasSearched ? l10n.noResults : l10n.noCustomers,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : '',
          actionLabel: state.hasSearched ? null : l10n.customer,
          onAction: _create,
      )
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(customerListProvider.notifier).load(),
        child: AppDataTable<CustomerEntity>(
          columns: _columns(l10n),
          rows: state.customers,
          initialSortColumn: 0,
          onRowTap: _openDetail,
          rowMenu: (c) => _rowMenu(c, l10n),
        ),
      ),
      floatingActionButton: AppAddFab(onPressed: _create, label: l10n.customer),
    );
  }
}