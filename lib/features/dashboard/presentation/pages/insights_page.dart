import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailPage(productId: id)),
    );
  }

  void _openCustomer(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CustomerDetailPage(customerId: id)),
    );
  }

  // ── Stock rules: same colours as the Products list ──

  BadgeTone _stockTone(StockForecastEntity f) {
    if (f.currentStock <= 0) return BadgeTone.danger;
    if (f.urgency != 'ok' || f.currentStock <= f.minThreshold) {
      return BadgeTone.warning;
    }
    return BadgeTone.success;
  }

  String _stockLabel(StockForecastEntity f, AppLocalizations l10n) {
    if (f.currentStock <= 0) return l10n.rupture;
    if (f.urgency != 'ok' || f.currentStock <= f.minThreshold) {
      return l10n.soon;
    }
    return l10n.ok;
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
      preferredSize: const Size.fromHeight(76 + 64),
      child: Column(
        children: [
          AppPageHeader(
            title: l10n.insightsAndForecasts,
            subtitle: outOfStock > 0
                ? '$outOfStock · ${l10n.rupture.toLowerCase()}'
                : null,
            icon: Icons.insights_outlined,
            color: AppColors.accent,
            actions: [
              AppHeaderAction(
                icon: Icons.refresh,
                tooltip: l10n.refresh,
                onTap: () => ref.read(predictionProvider.notifier).loadAll(),
              ),
            ],
          ),
          // Pill segmented control: selected tab in dark ink, white text.
          Container(
            color: AppColors.canvas,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(100),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTheme.font(size: 13, weight: FontWeight.w600),
                unselectedLabelStyle:
                AppTheme.font(size: 13, weight: FontWeight.w500),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: [
                  Tab(height: 40, text: l10n.stock),
                  Tab(height: 40, text: l10n.dormant),
                  Tab(height: 40, text: l10n.followUps),
                ],
              ),
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        drawer: const AppDrawer(currentRoute: '/insights'),
        appBar: _header(state, l10n),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _stockTab(state.stockForecast, l10n),
            _dormantTab(state.dormantProducts, l10n),
            _followUpTab(state.customerScores, l10n),
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final f = items[index];
        final tone = _stockTone(f);

        return AppCard(
          onTap: () => _openProduct(f.productId),
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLeadingTile.value('${f.currentStock}', tone: tone),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.name, style: AppTheme.rowTitle, maxLines: 2),
                        const SizedBox(height: 4),
                        Text(
                          f.daysOfCoverage != null
                              ? l10n.daysOfCoverage(f.daysOfCoverage!,
                              f.dailySalesRate.toStringAsFixed(2))
                              : l10n.noRecentSales,
                          style: AppTheme.label,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        AppBadge(label: _stockLabel(f, l10n), tone: tone),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right,
                      size: 22, color: AppColors.textMuted),
                ],
              ),
              if (f.suggestedOrder > 0)
                AppCardFooter(
                  color: AppColors.accent,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 18, color: AppColors.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.orderUnits(f.suggestedOrder),
                        style:
                        AppTheme.font(size: 14, weight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final d = items[index];

        return AppCard(
          onTap: () => _openProduct(d.id),
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLeadingTile.icon(Icons.hourglass_bottom_outlined,
                  tone: BadgeTone.warning),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: AppTheme.rowTitle, maxLines: 2),
                    const SizedBox(height: 4),
                    Text(
                      d.neverSold
                          ? l10n.neverSold
                          : l10n.lastSaleDaysAgo(d.daysSinceSale ?? 0),
                      style: AppTheme.label,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    AppBadge(label: l10n.dormant, tone: BadgeTone.warning),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  size: 22, color: AppColors.textMuted),
            ],
          ),
        );
      },
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final c = items[index];

        final Widget badge;
        if (c.overCreditLimit) {
          badge = AppBadge(
              label: l10n.creditLimitExceeded, tone: BadgeTone.danger);
        } else if (c.balance > 0.009) {
          badge = AppBadge(label: l10n.unpaid, tone: BadgeTone.warning);
        } else {
          badge = AppBadge(label: l10n.reasonUpToDate, tone: BadgeTone.success);
        }

        return AppCard(
          onTap: () => _openCustomer(c.customerId),
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Follow-up score ring, in terracotta.
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            value: (c.score / 100).clamp(0.0, 1.0),
                            strokeWidth: 4,
                            strokeCap: StrokeCap.round,
                            backgroundColor: AppColors.accentSoft,
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.accent),
                          ),
                        ),
                        Text(
                          '${c.score}',
                          style: AppTheme.font(
                            size: 13,
                            weight: FontWeight.w700,
                            color: AppColors.accent,
                            tabularFigures: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: AppTheme.rowTitle, maxLines: 2),
                        const SizedBox(height: 4),
                        Text(_reason(c, l10n),
                            style: AppTheme.label, maxLines: 3),
                        const SizedBox(height: 10),
                        badge,
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right,
                      size: 22, color: AppColors.textMuted),
                ],
              ),
              if (c.balance > 0.009)
                AppCardFooter(
                  color: AppColors.danger,
                  children: [
                    Expanded(
                      child: Text(l10n.outstandingBalance,
                          style: AppTheme.label),
                    ),
                    Text(
                      formatDT(c.balance),
                      style: AppTheme.money.copyWith(color: AppColors.danger),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}