import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
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
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(customerListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/customers'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: searchVisible
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchCustomers,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (v) =>
              ref.read(customerListProvider.notifier).search(v),
        )
            : Text(l10n.customers),
        actions: [
          IconButton(
            icon: Icon(searchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => searchVisible = !searchVisible);
              if (!searchVisible) {
                searchController.clear();
                ref.read(customerListProvider.notifier).clearSearch();
              }
            },
          ),
          if (!searchVisible)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(customerListProvider.notifier).load(),
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
        title: state.hasSearched ? l10n.noResults : l10n.noCustomers,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToAdd,
        color: AppColors.finance,
      )
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(customerListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: state.customers.length,
          itemBuilder: (context, index) {
            final c = state.customers[index];

            return AppCard(
              accentColor:
              c.isOverCreditLimit ? AppColors.danger : null,
              padding: const EdgeInsets.fromLTRB(14, 14, 4, 12),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CustomerDetailPage(customerId: c.id),
                ));
                if (mounted) {
                  ref.read(customerListProvider.notifier).load();
                }
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      AppInitialsBadge(
                          name: c.name, color: AppColors.finance),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(c.name,
                                      style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color:
                                          AppColors.textPrimary),
                                      overflow:
                                      TextOverflow.ellipsis),
                                ),
                                if (c.isOverCreditLimit) ...[
                                  const SizedBox(width: 6),
                                  const Icon(
                                      Icons.warning_amber_rounded,
                                      size: 15,
                                      color: AppColors.danger),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            AppMetaRow(items: [
                              (
                              icon: Icons.receipt_long_outlined,
                              text:
                              '${c.orderCount} ${l10n.orders.toLowerCase()}'
                              ),
                              if (c.phone != null)
                                (
                                icon: Icons.phone_outlined,
                                text: c.phone!
                                ),
                            ]),
                          ],
                        ),
                      ),
                      AppTrailingStat(
                        value: c.owesMoney
                            ? '${c.balance.toStringAsFixed(2)} DT'
                            : '—',
                        label: l10n.outstandingBalance,
                        valueColor: c.owesMoney
                            ? AppColors.danger
                            : AppColors.textSecondary,
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            size: 19,
                            color: AppColors.textSecondary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _edit(c, l10n);
                          } else if (value == 'delete') {
                            _delete(c, l10n);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [
                              const Icon(Icons.edit_outlined,
                                  size: 18),
                              const SizedBox(width: 10),
                              Text(l10n.edit),
                            ]),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [
                              const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.danger),
                              const SizedBox(width: 10),
                              Text(l10n.delete,
                                  style: const TextStyle(
                                      color: AppColors.danger)),
                            ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (c.creditLimit > 0) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: c.creditUsage.clamp(0.0, 1.0),
                              minHeight: 5,
                              backgroundColor: AppColors.surfaceAlt,
                              valueColor: AlwaysStoppedAnimation(
                                c.isOverCreditLimit
                                    ? AppColors.danger
                                    : c.isNearCreditLimit
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(l10n.creditUsage,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color:
                                      AppColors.textSecondary)),
                              const Spacer(),
                              Text(
                                  '${c.balance.toStringAsFixed(0)} / ${c.creditLimit.toStringAsFixed(0)} DT',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color:
                                      AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: Text(l10n.customer),
      ),
    );
  }
}