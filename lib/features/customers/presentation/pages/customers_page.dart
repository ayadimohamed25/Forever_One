import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  void _showSnack(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? theme.colorScheme.error : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _create() async {
    final input = await showCustomerFormDialog(context);
    if (input == null) return;
    await ref.read(customerListProvider.notifier).add(input);
  }

  Future<void> _edit(CustomerEntity customer, AppLocalizations l10n) async {
    final input = await showCustomerFormDialog(context, existing: customer);
    if (input == null) return;
    await ref.read(customerListProvider.notifier).update(customer.id, input);
    if (mounted) _showSnack(l10n.customerUpdated);
  }

  Future<void> _delete(CustomerEntity customer, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteConfirmTitle(customer.name)),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final error = await ref.read(customerListProvider.notifier).remove(customer.id);
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: searchVisible
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchCustomers,
            border: InputBorder.none,
            hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
          ),
          onChanged: (value) =>
              ref.read(customerListProvider.notifier).search(value),
        )
            : Text(l10n.customers),
        actions: [
          IconButton(
            icon: Icon(searchVisible ? Icons.close : Icons.search),
            tooltip: l10n.search,
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
              tooltip: l10n.refresh,
              onPressed: () => ref.read(customerListProvider.notifier).load(),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.customers.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                state.hasSearched
                    ? Icons.search_off
                    : Icons.people_outline,
                size: 64,
                color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(state.hasSearched ? l10n.noResults : l10n.noCustomers,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(
                state.hasSearched
                    ? l10n.tryDifferentSearch
                    : l10n.tapPlusToAdd,
                style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () => ref.read(customerListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          itemCount: state.customers.length,
          itemBuilder: (context, index) {
            final c = state.customers[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side:
                BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: InkWell(
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        CustomerDetailPage(customerId: c.id),
                  ));
                  if (mounted) {
                    ref.read(customerListProvider.notifier).load();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 23,
                            backgroundColor:
                            theme.colorScheme.primaryContainer,
                            child: Text(
                              _initials(c.name),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme
                                    .colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          if (c.isOverCreditLimit)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                      theme.colorScheme.surface,
                                      width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 13,
                                    color: theme
                                        .colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  '${c.orderCount} ${l10n.orders.toLowerCase()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme
                                        .colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (c.phone != null &&
                                    c.phone!.isNotEmpty) ...[
                                  const SizedBox(width: 10),
                                  Icon(Icons.phone_outlined,
                                      size: 13,
                                      color: theme.colorScheme
                                          .onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      c.phone!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            c.owesMoney
                                ? '${c.balance.toStringAsFixed(2)} DT'
                                : '—',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: c.owesMoney
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.outstandingBalance,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant),
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
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined,
                                    size: 18),
                                const SizedBox(width: 10),
                                Text(l10n.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 18,
                                    color: theme.colorScheme.error),
                                const SizedBox(width: 10),
                                Text(l10n.delete,
                                    style: TextStyle(
                                        color:
                                        theme.colorScheme.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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