import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../finance/presentation/pages/payment_page.dart';
import '../../domain/entities/sale_entity.dart';
import '../providers/sale_provider.dart';
import 'create_sale_page.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
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

  Future<void> _openPayment(SaleEntity s, AppLocalizations l10n) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PaymentPage(
        saleId: s.id,
        title: '${l10n.payment} — ${s.customerName}',
      ),
    ));
    if (mounted) ref.read(saleListProvider.notifier).load();
  }

  Future<void> _create() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateSalePage()),
    );
    if (mounted) ref.read(saleListProvider.notifier).load();
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
        content:
        Text('${l10n.deleteConfirmMessage} ${l10n.stockWillBeRestored}'),
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

  ({String label, BadgeTone tone}) _paymentStatus(
      SaleEntity s, AppLocalizations l10n) {
    if (s.isFullyPaid) return (label: l10n.paid, tone: BadgeTone.success);
    if (s.paid > 0.009) {
      return (label: l10n.partiallyPaid, tone: BadgeTone.warning);
    }
    return (label: l10n.unpaid, tone: BadgeTone.warning);
  }

  Widget _card(SaleEntity s, AppLocalizations l10n) {
    final status = _paymentStatus(s, l10n);

    // Sales from before VAT was introduced have no breakdown stored;
    // for those the line is hidden rather than guessed.
    final hasVatBreakdown = s.subtotalHt > 0.009 || s.totalVat > 0.009;

    final details = [
      if (s.reference != null && s.reference!.trim().isNotEmpty) s.reference!,
      formatDate(s.createdAt),
    ].join(' · ');

    return AppCard(
      onTap: () => _openPayment(s, l10n),
      padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppLeadingTile.initials(s.customerName),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.customerName,
                        style: AppTheme.rowTitle, maxLines: 2),
                    const SizedBox(height: 4),
                    Text(details, style: AppTheme.label, maxLines: 2),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        AppBadge(label: status.label, tone: status.tone),
                        if (s.isOverdue)
                          AppBadge(
                              label: l10n.overdue, tone: BadgeTone.danger)
                        else if (!s.isFullyPaid && s.dueDate != null)
                          AppBadge(
                            label: l10n.dueOn(formatDate(s.dueDate!)),
                            tone: BadgeTone.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatDT(s.total), style: AppTheme.money),
                  if (!s.isFullyPaid) ...[
                    const SizedBox(height: 3),
                    Text(
                      formatDT(s.balance),
                      style: AppTheme.font(
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.danger,
                        tabularFigures: true,
                      ),
                    ),
                  ],
                ],
              ),
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
          if (hasVatBreakdown)
            AppCardFooter(
              color: AppColors.textSecondary,
              children: [
                Expanded(
                  child: Text(
                    '${formatDT(s.subtotalHt)} ${l10n.exclVatShort}  ·  '
                        '${l10n.totalVat} ${formatDT(s.totalVat)}',
                    maxLines: 2,
                    style: AppTheme.font(
                      size: 12,
                      color: AppColors.textSecondary,
                      tabularFigures: true,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saleListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(saleListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    final outstanding = state.sales
        .where((s) => !s.isFullyPaid)
        .fold<double>(0, (sum, s) => sum + s.balance);
    final subtitle = state.sales.isEmpty
        ? null
        : outstanding > 0.009
        ? '${state.sales.length} · ${formatDT(outstanding)} ${l10n.unpaid.toLowerCase()}'
        : '${state.sales.length} ${l10n.sales.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
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
        subtitle: subtitle,
        icon: Icons.point_of_sale_outlined,
        color: AppColors.sales,
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
          : state.sales.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.point_of_sale_outlined,
        title: state.hasSearched ? l10n.noResults : l10n.noSales,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToCreate,
      )
          : RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => ref.read(saleListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: state.sales.length,
          itemBuilder: (context, index) =>
              _card(state.sales[index], l10n),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: AppColors.black,
        icon: const Icon(Icons.add),
        label: Text(l10n.newSale),
      ),
    );
  }
}