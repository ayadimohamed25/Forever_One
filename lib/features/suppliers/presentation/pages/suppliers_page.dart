import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/supplier_entity.dart';
import '../providers/supplier_provider.dart';
import '../widgets/supplier_form_dialog.dart';
import 'supplier_detail_page.dart';

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
      _showSnack(error, isError: true);
    }
  }

  Future<void> _openDetail(SupplierEntity s) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SupplierDetailPage(supplierId: s.id),
    ));
    if (mounted) ref.read(supplierListProvider.notifier).load();
  }

  /// Only shown when deliveries actually have expected and received dates;
  /// with no data there is nothing honest to display.
  Widget? _reliabilityBadge(SupplierEntity s, AppLocalizations l10n) {
    final tracked = s.trackedDeliveries;
    if (tracked <= 0) return null;

    final rate = s.onTimeDeliveries / tracked;
    final tone = rate > 0.8
        ? BadgeTone.success
        : rate >= 0.5
        ? BadgeTone.warning
        : BadgeTone.danger;

    return AppBadge(
      label: '${(rate * 100).toStringAsFixed(0)}% '
          '${l10n.onTimeDeliveries(s.onTimeDeliveries, tracked)}',
      tone: tone,
    );
  }

  Widget _card(SupplierEntity s, AppLocalizations l10n) {
    final owes = s.balance > 0.009;
    final reliability = _reliabilityBadge(s, l10n);
    final hasPhone = s.phone != null && s.phone!.trim().isNotEmpty;

    return AppCard(
      onTap: () => _openDetail(s),
      padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLeadingTile.icon(Icons.local_shipping_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: AppTheme.rowTitle, maxLines: 2),
                if (s.contactPerson != null &&
                    s.contactPerson!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(s.contactPerson!, style: AppTheme.label, maxLines: 2),
                ],
                if (hasPhone) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 14, color: AppColors.iconMuted),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          s.phone!,
                          maxLines: 1,
                          style: AppTheme.font(
                            size: 13,
                            color: AppColors.textSecondary,
                            tabularFigures: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    AppBadge(
                      label: owes ? l10n.unpaid : l10n.paid,
                      tone: owes ? BadgeTone.warning : BadgeTone.success,
                    ),
                    ?reliability,
                  ],
                ),
              ],
            ),
          ),
          if (owes) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatDT(s.balance),
                  style: AppTheme.money.copyWith(color: AppColors.danger),
                ),
                const SizedBox(height: 3),
                Text(l10n.amountOwed, style: AppTheme.label),
              ],
            ),
          ],
          AppRowMenu(actions: [
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
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(supplierListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    final owed =
    state.suppliers.fold<double>(0, (sum, s) => sum + (s.balance > 0 ? s.balance : 0));
    final subtitle = state.suppliers.isEmpty
        ? null
        : owed > 0.009
        ? '${state.suppliers.length} · ${formatDT(owed)} ${l10n.amountOwed.toLowerCase()}'
        : '${state.suppliers.length} ${l10n.suppliers.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
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
        subtitle: subtitle,
        icon: Icons.local_shipping_outlined,
        color: AppColors.purchases,
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
          : state.suppliers.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.local_shipping_outlined,
        title:
        state.hasSearched ? l10n.noResults : l10n.noSuppliers,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToAdd,
      )
          : RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () =>
            ref.read(supplierListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: state.suppliers.length,
          itemBuilder: (context, index) =>
              _card(state.suppliers[index], l10n),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: AppColors.black,
        icon: const Icon(Icons.add),
        label: Text(l10n.supplier),
      ),
    );
  }
}