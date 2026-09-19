import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/prediction_provider.dart';
import '../../../../shared/widgets/app_page_header.dart';

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

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'critical':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  String _urgencyLabel(String urgency, AppLocalizations l10n) {
    switch (urgency) {
      case 'critical':
        return l10n.rupture;
      case 'warning':
        return l10n.soon;
      default:
        return l10n.ok;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionProvider);
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surfaceAlt,
        drawer: const AppDrawer(currentRoute: '/insights'),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(74 + 52),
          child: Column(
            children: [
              AppPageHeader(
                title: l10n.insightsAndForecasts,
                subtitle: state.stockForecast.isEmpty
                    ? null
                    : '${state.stockForecast.where((f) => f.urgency == 'critical').length} ${l10n.rupture.toLowerCase()}',
                icon: Icons.insights_rounded,
                color: AppColors.primary,
                actions: [
                  AppHeaderAction(
                    icon: Icons.refresh_rounded,
                    tooltip: l10n.refresh,
                    onTap: () =>
                        ref.read(predictionProvider.notifier).loadAll(),
                  ),
                ],
              ),
              Container(
                color: AppColors.surfaceAlt,
                child: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(
                        icon: const Icon(Icons.trending_down, size: 19),
                        text: l10n.stock),
                    Tab(
                        icon: const Icon(Icons.hourglass_empty, size: 19),
                        text: l10n.dormant),
                    Tab(
                        icon: const Icon(Icons.phone_callback, size: 19),
                        text: l10n.followUps),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            // ---------- Stock forecast ----------
            state.stockForecast.isEmpty
                ? AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: l10n.noStockData,
              subtitle: l10n.addProductsForForecasts,
              color: AppColors.stock,
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: state.stockForecast.length,
              itemBuilder: (context, index) {
                final f = state.stockForecast[index];
                final color = _urgencyColor(f.urgency);

                return AppCard(
                  accentColor: f.urgency == 'critical'
                      ? AppColors.danger
                      : null,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AppValueBadge(
                              value: '${f.currentStock}',
                              color: color),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(f.name,
                                    style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors
                                            .textPrimary),
                                    overflow:
                                    TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(
                                  f.daysOfCoverage != null
                                      ? l10n.daysOfCoverage(
                                      f.daysOfCoverage!,
                                      f.dailySalesRate
                                          .toString())
                                      : l10n.noRecentSales,
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors
                                          .textSecondary),
                                ),
                              ],
                            ),
                          ),
                          AppStatusChip(
                              label:
                              _urgencyLabel(f.urgency, l10n),
                              color: color),
                        ],
                      ),
                      if (f.suggestedOrder > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: AppColors.tintGradient(
                                AppColors.primary),
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline,
                                  size: 15,
                                  color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                l10n.orderUnits(f.suggestedOrder),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
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

            // ---------- Dormant products ----------
            state.dormantProducts.isEmpty
                ? AppEmptyState(
              icon: Icons.check_circle_outline,
              title: l10n.noDormantProducts,
              subtitle: l10n.allProductsSelling,
              color: AppColors.success,
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: state.dormantProducts.length,
              itemBuilder: (context, index) {
                final d = state.dormantProducts[index];
                return AppCard(
                  child: Row(
                    children: [
                      AppIconBadge(
                          icon: Icons.hourglass_empty,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(d.name,
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text(
                              d.neverSold
                                  ? l10n.neverSold
                                  : l10n.lastSaleDaysAgo(
                                  d.daysSinceSale ?? 0),
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (d.neverSold)
                        AppStatusChip(
                            label: l10n.neverSold,
                            color: AppColors.warning),
                    ],
                  ),
                );
              },
            ),

            // ---------- Customer scoring ----------
            state.customerScores.isEmpty
                ? AppEmptyState(
              icon: Icons.people_outline,
              title: l10n.noCustomersYet,
              subtitle: l10n.addCustomersForScores,
              color: AppColors.finance,
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: state.customerScores.length,
              itemBuilder: (context, index) {
                final c = state.customerScores[index];
                final scoreColor = c.score >= 60
                    ? AppColors.danger
                    : c.score >= 30
                    ? AppColors.warning
                    : AppColors.success;

                return AppCard(
                  accentColor:
                  c.score >= 60 ? AppColors.danger : null,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 46,
                        height: 46,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 46,
                              height: 46,
                              child: CircularProgressIndicator(
                                value: c.score / 100,
                                strokeWidth: 4,
                                strokeCap: StrokeCap.round,
                                backgroundColor:
                                AppColors.surfaceAlt,
                                valueColor: AlwaysStoppedAnimation(
                                    scoreColor),
                              ),
                            ),
                            Text('${c.score}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: scoreColor)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(c.name,
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(c.reason,
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    color:
                                    AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (c.balance > 0) ...[
                        const SizedBox(width: 8),
                        Text('${c.balance.toStringAsFixed(2)} DT',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.danger)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}