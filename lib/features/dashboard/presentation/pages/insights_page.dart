import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../customers/domain/entities/customer_score_entity.dart';
import '../../../customers/presentation/pages/customer_detail_page.dart';
import '../../../stock/domain/entities/dormant_product_entity.dart';
import '../../../stock/domain/entities/stock_forecast_entity.dart';
import '../../../stock/presentation/pages/product_detail_page.dart';
import '../providers/prediction_provider.dart';

class InsightsPage extends ConsumerStatefulWidget {
  const InsightsPage({super.key});

  @override
  ConsumerState<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends ConsumerState<InsightsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(predictionProvider.notifier).loadAll());
  }

  void _openProduct(String id) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => ProductDetailPage(productId: id)),
    );
  }

  void _openCustomer(String id) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => CustomerDetailPage(customerId: id)),
    );
  }

  /// The follow-up reason, phrased from ARB strings in the app language.
  String _reason(CustomerScoreEntity c, AppLocalizations l10n) {
    final parts = <String>[];
    if (c.balance > 0.009) parts.add(l10n.reasonOwes(formatDT(c.balance)));
    if (c.neverPurchased) {
      parts.add(l10n.reasonNeverPurchased);
    } else if ((c.daysSincePurchase ?? 0) > 30) {
      parts.add(l10n.reasonNoPurchase(c.daysSincePurchase!));
    }
    if (c.overCreditLimit) parts.add(l10n.creditLimitExceeded);
    return parts.isEmpty ? l10n.reasonUpToDate : parts.join(' · ');
  }

  PreferredSizeWidget _header(PredictionState state, AppLocalizations l10n) {
    final outOfStock =
        state.stockForecast.where((f) => f.currentStock <= 0).length;

    return PreferredSize(
      preferredSize: const Size.fromHeight(64 + 48),
      child: Column(
        children: [
          AppPageHeader(
            title: l10n.insightsAndForecasts,
            subtitle: outOfStock > 0
                ? '$outOfStock · ${l10n.statusOutOfStock.toLowerCase()}'
                : null,
            icon: Icons.insights_outlined,
            color: AppColors.primary,
            actions: [
              AppHeaderAction(
                icon: Icons.refresh,
                tooltip: l10n.refresh,
                onTap: () => ref.read(predictionProvider.notifier).loadAll(),
              ),
            ],
          ),
          // Plain underline tabs on white, like the rest of the app.
          Container(
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TabBar(
              isScrollable: false,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: l10n.stock),
                Tab(text: l10n.dormant),
                Tab(text: l10n.followUps),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionProvider);
    final l10n = AppLocalizations.of(context)!;
    Future<void> reload() => ref.read(predictionProvider.notifier).loadAll();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: _header(state, l10n),
        body: state.isLoading
            ? AppSkeletonList(semanticLabel: l10n.loading)
            : state.error != null &&
                    state.stockForecast.isEmpty &&
                    state.dormantProducts.isEmpty &&
                    state.customerScores.isEmpty
                ? AppErrorState(
                    title: l10n.loadFailedTitle,
                    message: l10n.serverUnreachable,
                    retryLabel: l10n.retry,
                    onRetry: reload,
                  )
                : TabBarView(
                    children: [
                      RefreshIndicator(
                          onRefresh: reload,
                          child: _stockTab(state.stockForecast, l10n)),
                      RefreshIndicator(
                          onRefresh: reload,
                          child: _dormantTab(state.dormantProducts, l10n)),
                      RefreshIndicator(
                          onRefresh: reload,
                          child: _followUpTab(state.customerScores, l10n)),
                    ],
                  ),
      ),
    );
  }

  // ═════════ Stock ═════════

  Widget _stockTab(List<StockForecastEntity> items, AppLocalizations l10n) {
    if (items.isEmpty) {
      return AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.noStockData,
        subtitle: l10n.addProductsForForecasts,
      );
    }
    int rank(StockForecastEntity f) => f.currentStock <= 0
        ? 2
        : (f.urgency != 'ok' || f.currentStock <= f.minThreshold)
            ? 1
            : 0;

    return AppDataTable<StockForecastEntity>(
      bottomPadding: 24,
      rows: items,
      initialSortColumn: 4,
      initialAscending: false,
      onRowTap: (f) => _openProduct(f.productId),
      columns: [
        AppTableColumn(
          label: l10n.product,
          flex: 4,
          sortValue: (f) => f.name.toLowerCase(),
          cell: (f) => AppCellText(
            f.name,
            strong: true,
            sub: f.daysOfCoverage != null
                ? l10n.daysOfCoverage(
                    f.daysOfCoverage!, f.dailySalesRate.toStringAsFixed(2))
                : l10n.noRecentSales,
          ),
        ),
        AppTableColumn(
          label: l10n.stock,
          width: 60,
          numeric: true,
          sortValue: (f) => f.currentStock,
          cell: (f) => AppCellText('${f.currentStock}',
              numeric: true,
              color: f.currentStock <= 0
                  ? AppColors.dangerText
                  : rank(f) == 1
                      ? AppColors.warningText
                      : AppColors.textPrimary),
        ),
        AppTableColumn(
          label: l10n.minimum,
          width: 64,
          numeric: true,
          showFrom: 600,
          sortValue: (f) => f.minThreshold,
          cell: (f) => AppCellText('${f.minThreshold}',
              numeric: true, color: AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.suggestedOrder,
          width: 88,
          numeric: true,
          showFrom: 600,
          sortValue: (f) => f.suggestedOrder,
          cell: (f) => AppCellText(
              f.suggestedOrder > 0 ? '+${f.suggestedOrder}' : '—',
              numeric: true,
              color: f.suggestedOrder > 0
                  ? AppColors.primary
                  : AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.status,
          width: 100,
          sortValue: rank,
          cell: (f) => AppBadge(
            label: switch (rank(f)) {
              2 => l10n.statusOutOfStock,
              1 => l10n.statusLowStock,
              _ => l10n.ok,
            },
            tone: switch (rank(f)) {
              2 => BadgeTone.danger,
              1 => BadgeTone.warning,
              _ => BadgeTone.success,
            },
          ),
        ),
      ],
    );
  }

  // ═════════ Dormant ═════════

  Widget _dormantTab(List<DormantProductEntity> items, AppLocalizations l10n) {
    if (items.isEmpty) {
      return AppEmptyState(
        icon: Icons.check_circle_outline,
        title: l10n.noDormantProducts,
        subtitle: l10n.allProductsSelling,
      );
    }
    return AppDataTable<DormantProductEntity>(
      bottomPadding: 24,
      rows: items,
      initialSortColumn: 1,
      initialAscending: false,
      onRowTap: (d) => _openProduct(d.id),
      columns: [
        AppTableColumn(
          label: l10n.product,
          flex: 4,
          sortValue: (d) => d.name.toLowerCase(),
          cell: (d) => AppCellText(d.name, strong: true),
        ),
        AppTableColumn(
          label: l10n.lastSale,
          width: 132,
          numeric: true,
          // Never sold sorts as the oldest.
          sortValue: (d) => d.neverSold ? 1 << 30 : (d.daysSinceSale ?? 0),
          cell: (d) => AppCellText(
              d.neverSold
                  ? l10n.neverSold
                  : l10n.lastSaleDaysAgo(d.daysSinceSale ?? 0),
              numeric: true,
              color: AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.status,
          width: 92,
          cell: (d) => AppBadge(label: l10n.dormant, tone: BadgeTone.warning),
        ),
      ],
    );
  }

  // ═════════ Follow-ups ═════════

  Widget _followUpTab(List<CustomerScoreEntity> items, AppLocalizations l10n) {
    if (items.isEmpty) {
      return AppEmptyState(
        icon: Icons.people_outline,
        title: l10n.noCustomersYet,
        subtitle: l10n.addCustomersForScores,
      );
    }
    return AppDataTable<CustomerScoreEntity>(
      bottomPadding: 24,
      rows: items,
      initialSortColumn: 1,
      initialAscending: false,
      onRowTap: (c) => _openCustomer(c.customerId),
      columns: [
        AppTableColumn(
          label: l10n.customer,
          flex: 4,
          sortValue: (c) => c.name.toLowerCase(),
          cell: (c) => AppCellText(c.name, strong: true, sub: _reason(c, l10n)),
        ),
        AppTableColumn(
          label: l10n.score,
          width: 56,
          numeric: true,
          sortValue: (c) => c.score,
          cell: (c) => AppCellText('${c.score}',
              numeric: true,
              color: c.score >= 70
                  ? AppColors.dangerText
                  : c.score >= 40
                      ? AppColors.warningText
                      : AppColors.textPrimary),
        ),
        AppTableColumn(
          label: l10n.colBalance,
          width: 112,
          numeric: true,
          showFrom: 600,
          sortValue: (c) => c.balance,
          cell: (c) => AppCellText(
              c.balance > 0.009 ? formatDT(c.balance) : '—',
              numeric: true),
        ),
        AppTableColumn(
          label: l10n.status,
          width: 104,
          sortValue: (c) => c.overCreditLimit ? 2 : (c.balance > 0.009 ? 1 : 0),
          cell: (c) => c.overCreditLimit
              ? AppBadge(label: l10n.statusOverLimit, tone: BadgeTone.danger)
              : c.balance > 0.009
                  ? AppBadge(label: l10n.unpaid, tone: BadgeTone.warning)
                  : AppBadge(label: l10n.statusUpToDate, tone: BadgeTone.success),
        ),
      ],
    );
  }
}
