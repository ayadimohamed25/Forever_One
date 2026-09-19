import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../../domain/entities/sale_entity.dart';
import '../providers/sale_provider.dart';
import 'create_sale_page.dart';
import '../../../../shared/widgets/app_page_header.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  String? _subtitle(SaleListState state, AppLocalizations l10n) {
    if (state.sales.isEmpty) return null;
    final unpaid = state.sales.where((s) => !s.isFullyPaid).length;
    final total = state.sales.fold<double>(0, (sum, s) => sum + s.total);
    if (unpaid == 0) {
      return '${state.sales.length} · ${total.toStringAsFixed(0)} DT';
    }
    return '${state.sales.length} · $unpaid ${l10n.unpaid}';
  }
  final searchController = TextEditingController();
  bool searchVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(saleListProvider.notifier).load());
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

  String _dueLabel(int? days, AppLocalizations l10n) {
    if (days == null) return '';
    if (days < 0) return l10n.overdue;
    if (days == 0) return l10n.dueToday;
    return l10n.dueIn(days);
  }

  Future<void> _edit(SaleEntity s, AppLocalizations l10n) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CreateSalePage(existingSaleId: s.id)),
    );
    if (changed == true && mounted) {
      _showSnack(l10n.saleUpdated);
      ref.read(saleListProvider.notifier).load();
    }
  }

  Future<void> _delete(SaleEntity s, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(s.customerName)),
        content: Text('${l10n.deleteConfirmMessage} ${l10n.stockWillBeRestored}'),
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

    final error = await ref.read(saleListProvider.notifier).remove(s.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.saleDeleted);
    } else if (error == 'SALE_HAS_PAYMENTS') {
      _showSnack(l10n.saleHasPayments, isError: true);
    } else {
      _showSnack(error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saleListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/sales'),
      appBar: searchVisible
          ? AppSearchHeader(
        controller: searchController,
        hint: l10n.searchSales,
        onChanged: (v) => ref.read(saleListProvider.notifier).search(v),
        onClose: () {
          setState(() => searchVisible = false);
          searchController.clear();
          ref.read(saleListProvider.notifier).clearSearch();
        },
      )
          : AppPageHeader(
        title: l10n.sales,
        subtitle: _subtitle(state, l10n),
        icon: Icons.point_of_sale_rounded,
        color: AppColors.sales,
        actions: [
          AppHeaderAction(
            icon: Icons.search_rounded,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
          AppHeaderAction(
            icon: Icons.refresh_rounded,
            tooltip: l10n.refresh,
            onTap: () => ref.read(saleListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.sales.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.point_of_sale_outlined,
        title: state.hasSearched ? l10n.noResults : l10n.noSales,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToCreate,
        color: AppColors.sales,
      )
          : RefreshIndicator(
        onRefresh: () => ref.read(saleListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: state.sales.length,
          itemBuilder: (context, index) {
            final s = state.sales[index];
            final d = s.createdAt;
            final dateLabel =
                '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

            return AppCard(
              accentColor: s.isOverdue ? AppColors.danger : null,
              padding: const EdgeInsets.fromLTRB(14, 14, 4, 12),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PaymentPage(
                    saleId: s.id,
                    title: '${l10n.payment} — ${s.customerName}',
                  ),
                ));
                if (mounted) {
                  ref.read(saleListProvider.notifier).load();
                }
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      AppInitialsBadge(
                          name: s.customerName,
                          color: AppColors.sales),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(s.customerName,
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            AppMetaRow(items: [
                              if (s.reference != null)
                                (icon: Icons.tag, text: s.reference!),
                              (
                              icon: Icons.calendar_today_outlined,
                              text: dateLabel
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${s.total.toStringAsFixed(3)} DT',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.sales)),
                          Text(
                              '${s.subtotalHt.toStringAsFixed(3)} HT',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
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
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        AppStatusChip(
                          label: s.isFullyPaid
                              ? l10n.paid
                              : '${s.balance.toStringAsFixed(3)} DT ${l10n.unpaid}',
                          color: s.isFullyPaid
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                        if (s.dueDate != null && !s.isFullyPaid) ...[
                          const SizedBox(width: 6),
                          AppStatusChip(
                            label: _dueLabel(s.daysUntilDue, l10n),
                            color: s.isOverdue
                                ? AppColors.danger
                                : AppColors.warning,
                          ),
                        ],
                        const Spacer(),
                        Text(
                            '${l10n.totalVat} ${s.totalVat.toStringAsFixed(3)}',
                            style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateSalePage()),
          );
          ref.read(saleListProvider.notifier).load();
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newSale),
      ),
    );
  }
}