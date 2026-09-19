import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/supplier_entity.dart';
import '../providers/supplier_provider.dart';
import '../widgets/supplier_form_dialog.dart';
import 'supplier_detail_page.dart';
import '../../../../shared/widgets/app_page_header.dart';


class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  String? _subtitle(SupplierListState state, AppLocalizations l10n) {
    if (state.suppliers.isEmpty) return null;
    final total = state.suppliers.fold<double>(0, (sum, s) => sum + s.balance);
    if (total <= 0.009) {
      return '${state.suppliers.length} ${l10n.suppliers.toLowerCase()}';
    }
    return '${state.suppliers.length} · ${total.toStringAsFixed(0)} DT ${l10n.amountOwed.toLowerCase()}';
  }
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  Future<void> _create() async {
    final input = await showSupplierFormDialog(context);
    if (input == null) return;
    await ref.read(supplierListProvider.notifier).add(input);
  }

  Future<void> _edit(SupplierEntity s, AppLocalizations l10n) async {
    final input = await showSupplierFormDialog(context, existing: s);
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
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(supplierListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/suppliers'),
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
        subtitle: _subtitle(state, l10n),
        icon: Icons.local_shipping_rounded,
        color: AppColors.purchases,
        actions: [
          AppHeaderAction(
            icon: Icons.search_rounded,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
          AppHeaderAction(
            icon: Icons.refresh_rounded,
            tooltip: l10n.refresh,
            onTap: () => ref.read(supplierListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.suppliers.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.local_shipping_outlined,
        title: state.hasSearched ? l10n.noResults : l10n.noSuppliers,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToAdd,
        color: AppColors.purchases,
      )
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(supplierListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: state.suppliers.length,
          itemBuilder: (context, index) {
            final s = state.suppliers[index];
            final reliability = s.reliabilityRate;

            return AppCard(
              padding: const EdgeInsets.fromLTRB(14, 14, 4, 12),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SupplierDetailPage(supplierId: s.id),
                ));
                if (mounted) {
                  ref.read(supplierListProvider.notifier).load();
                }
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      AppIconBadge(
                          icon: Icons.local_shipping_outlined,
                          color: AppColors.purchases),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            AppMetaRow(items: [
                              if (s.contactPerson != null)
                                (
                                icon: Icons.person_outline,
                                text: s.contactPerson!
                                ),
                              (
                              icon: Icons.schedule,
                              text: '${s.leadTimeDays} ${l10n.days}'
                              ),
                            ]),
                          ],
                        ),
                      ),
                      AppTrailingStat(
                        value: s.owesMoney
                            ? '${s.balance.toStringAsFixed(2)} DT'
                            : '—',
                        label: l10n.amountOwed,
                        valueColor: s.owesMoney
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
                            _edit(s, l10n);
                          } else if (value == 'delete') {
                            _delete(s, l10n);
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
                  if (reliability != null) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        children: [
                          AppStatusChip(
                            label:
                            '${(reliability * 100).toStringAsFixed(0)}% ${l10n.onTimeDeliveries(s.onTimeDeliveries, s.trackedDeliveries)}',
                            color: reliability >= 0.8
                                ? AppColors.success
                                : reliability >= 0.5
                                ? AppColors.warning
                                : AppColors.danger,
                          ),
                          const Spacer(),
                          Text(
                              '${s.orderCount} ${l10n.orders.toLowerCase()}',
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textSecondary)),
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
        backgroundColor: AppColors.purchases,
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: Text(l10n.supplier),
      ),
    );
  }
}