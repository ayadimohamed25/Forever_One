import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/supplier_entity.dart';
import '../providers/supplier_provider.dart';
import '../widgets/supplier_form_dialog.dart';
import 'supplier_detail_page.dart';
import '../../../../shared/widgets/app_drawer.dart';

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
    final input = await showSupplierFormDialog(context);
    if (input == null) return;
    await ref.read(supplierListProvider.notifier).add(input);
  }

  Future<void> _edit(SupplierEntity supplier, AppLocalizations l10n) async {
    final input = await showSupplierFormDialog(context, existing: supplier);
    if (input == null) return;
    await ref.read(supplierListProvider.notifier).update(supplier.id, input);
    if (mounted) _showSnack(l10n.supplierUpdated);
  }

  Future<void> _delete(SupplierEntity supplier, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteConfirmTitle(supplier.name)),
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

    final error = await ref.read(supplierListProvider.notifier).remove(supplier.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.supplierDeleted);
    } else if (error == 'SUPPLIER_IN_USE') {
      _showSnack(l10n.supplierInUse, isError: true);
    } else {
      _showSnack(error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierListProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/suppliers'),
      appBar: AppBar(
        title: searchVisible
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchSuppliers,
            border: InputBorder.none,
            hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
          ),
          onChanged: (value) =>
              ref.read(supplierListProvider.notifier).search(value),
        )
            : Text(l10n.suppliers),
        actions: [
          IconButton(
            icon: Icon(searchVisible ? Icons.close : Icons.search),
            tooltip: l10n.search,
            onPressed: () {
              setState(() => searchVisible = !searchVisible);
              if (!searchVisible) {
                searchController.clear();
                ref.read(supplierListProvider.notifier).clearSearch();
              }
            },
          ),
          if (!searchVisible)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refresh,
              onPressed: () => ref.read(supplierListProvider.notifier).load(),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.suppliers.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                state.hasSearched
                    ? Icons.search_off
                    : Icons.local_shipping_outlined,
                size: 64,
                color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(state.hasSearched ? l10n.noResults : l10n.noSuppliers,
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
        onRefresh: () => ref.read(supplierListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          itemCount: state.suppliers.length,
          itemBuilder: (context, index) {
            final s = state.suppliers[index];

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
                        SupplierDetailPage(supplierId: s.id),
                  ));
                  if (mounted) {
                    ref.read(supplierListProvider.notifier).load();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.local_shipping_outlined,
                            color:
                            theme.colorScheme.onTertiaryContainer),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (s.contactPerson != null &&
                                    s.contactPerson!.isNotEmpty) ...[
                                  Icon(Icons.person_outline,
                                      size: 13,
                                      color: theme.colorScheme
                                          .onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      s.contactPerson!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Icon(Icons.schedule,
                                    size: 13,
                                    color: theme
                                        .colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  '${s.leadTimeDays} ${l10n.days}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme
                                        .colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            s.owesMoney
                                ? '${s.balance.toStringAsFixed(2)} DT'
                                : 'â€”',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: s.owesMoney
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.amountOwed,
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
                            _edit(s, l10n);
                          } else if (value == 'delete') {
                            _delete(s, l10n);
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
        label: Text(l10n.supplier),
      ),
    );
  }
}
