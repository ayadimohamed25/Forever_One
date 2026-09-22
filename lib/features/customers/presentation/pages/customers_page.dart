import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/customer_entity.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_form_dialog.dart';
import 'customer_detail_page.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  Future<void> _create() async {
    final input = await showCustomerFormDialog(context);
    if (input == null) return;
    await ref.read(customerListProvider.notifier).add(input);
  }

  Future<void> _edit(CustomerEntity c, AppLocalizations l10n) async {
    final input = await showCustomerFormDialog(context, existing: c);
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
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CustomerDetailPage(customerId: c.id),
    ));
    if (mounted) ref.read(customerListProvider.notifier).load();
  }

  Widget _statusBadge(CustomerEntity c, AppLocalizations l10n) {
    if (c.isOverCreditLimit) {
      return AppBadge(label: l10n.creditLimitExceeded, tone: BadgeTone.danger);
    }
    if (c.owesMoney) {
      return AppBadge(label: l10n.unpaid, tone: BadgeTone.warning);
    }
    return AppBadge(label: l10n.reasonUpToDate, tone: BadgeTone.success);
  }

  /// Credit usage bar under the card's main row.
  Widget _creditFooter(CustomerEntity c, AppLocalizations l10n) {
    final color = c.isOverCreditLimit
        ? AppColors.danger
        : c.isNearCreditLimit
        ? AppColors.warning
        : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 14),
          child: Divider(height: 1),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: c.creditUsage.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.track,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.creditUsage} · ${formatDT(c.balance > 0 ? c.balance : 0)} / ${formatDT(c.creditLimit)}',
          maxLines: 2,
          style: AppTheme.font(
            size: 12,
            color: AppColors.textSecondary,
            tabularFigures: true,
          ),
        ),
      ],
    );
  }

  Widget _card(CustomerEntity c, AppLocalizations l10n) {
    final details = [
      '${c.orderCount} ${l10n.orders.toLowerCase()}',
      if (c.phone != null && c.phone!.trim().isNotEmpty) c.phone!,
    ].join(' · ');

    return AppCard(
      onTap: () => _openDetail(c),
      padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppLeadingTile.initials(c.name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wraps to two lines — never cut with "…".
                    Text(c.name, style: AppTheme.rowTitle, maxLines: 2),
                    const SizedBox(height: 4),
                    Text(details, style: AppTheme.label, maxLines: 2),
                    const SizedBox(height: 10),
                    _statusBadge(c, l10n),
                  ],
                ),
              ),
              if (c.owesMoney) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatDT(c.balance),
                      style: AppTheme.money.copyWith(color: AppColors.danger),
                    ),
                    const SizedBox(height: 3),
                    Text(l10n.outstandingBalance, style: AppTheme.label),
                  ],
                ),
              ],
              AppRowMenu(actions: [
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
              ]),
            ],
          ),
          if (c.creditLimit > 0) _creditFooter(c, l10n),
        ],
      ),
    );
  }

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
      drawer: const AppDrawer(currentRoute: '/customers'),
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
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.customers.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.people_outline,
        title:
        state.hasSearched ? l10n.noResults : l10n.noCustomers,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToAdd,
      )
          : RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () =>
            ref.read(customerListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: state.customers.length,
          itemBuilder: (context, index) =>
              _card(state.customers[index], l10n),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: AppColors.black,
        icon: const Icon(Icons.add),
        label: Text(l10n.customer),
      ),
    );
  }
}