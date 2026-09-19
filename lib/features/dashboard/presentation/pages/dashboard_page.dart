import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../providers/dashboard_provider.dart';
import '../providers/report_provider.dart';
import '../../../../shared/widgets/app_page_header.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardProvider.notifier).load());
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  // ---------- Hero header with the headline number ----------

  Widget _hero({
    required String greeting,
    required String name,
    required String company,
    required DashboardKpis kpis,
    required AppLocalizations l10n,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.78),
              )),
          const SizedBox(height: 2),
          Text(name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.15,
              )),
          if (company.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.business,
                    size: 12, color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(company,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          const SizedBox(height: 22),

          // Headline metric
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.thisMonth.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.72),
                          )),
                      const SizedBox(height: 6),
                      Text(
                        '${kpis.revenueThisMonth.toStringAsFixed(2)} DT',
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (kpis.revenueGrowthPercent != null) ...[
                            Icon(
                                kpis.revenueGrowthPercent! >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                size: 13,
                                color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              '${kpis.revenueGrowthPercent! >= 0 ? '+' : ''}${kpis.revenueGrowthPercent!.toStringAsFixed(0)}% ${l10n.vsLastMonth}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ] else
                            Text(
                              '${kpis.salesCountThisMonth} ${l10n.sales.toLowerCase()}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.payments_outlined,
                      color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Coloured KPI tile ----------

  Widget _kpiTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.tintGradient(color),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppColors.softShadow(color),
            ),
            child: Icon(icon, size: 15, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    )),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Section header ----------

  Widget _sectionHeader(String title, IconData icon, Color color,
      {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          ?action,
        ],
      ),
    );
  }

  Widget _panel({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }

  // ---------- Revenue chart ----------

  Widget _revenueChart(List<SalesTrendPoint> trend, AppLocalizations l10n) {
    final hasData = trend.any((p) => p.revenue > 0);

    if (!hasData) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 38, color: AppColors.border),
              const SizedBox(height: 8),
              Text(l10n.noSalesYet,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final maxY = trend.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 165,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.25,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 3 : 1,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.border,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: maxY > 0 ? maxY / 2 : 1,
                getTitlesWidget: (value, meta) => Text(
                  value >= 1000
                      ? '${(value / 1000).toStringAsFixed(0)}k'
                      : value.toStringAsFixed(0),
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: 7,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= trend.length) {
                    return const SizedBox.shrink();
                  }
                  final day = trend[index].day;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${day.day}/${day.month}',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.textPrimary,
              tooltipRoundedRadius: 10,
              getTooltipItems: (spots) => spots.map((s) {
                final day = trend[s.x.toInt()].day;
                return LineTooltipItem(
                  '${day.day}/${day.month}\n${s.y.toStringAsFixed(2)} DT',
                  const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: trend
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
                  .toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Top products ----------

  Widget _topProducts(List<TopProduct> products, AppLocalizations l10n) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(l10n.noSalesYet,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ),
      );
    }

    final maxRevenue = products.first.revenue;
    const rankColors = [
      AppColors.sales,
      AppColors.info,
      AppColors.finance,
      AppColors.purchases,
      AppColors.textSecondary,
    ];

    return Column(
      children: products.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        final ratio = maxRevenue > 0 ? p.revenue / maxRevenue : 0.0;
        final color = rankColors[i % rankColors.length];

        return Padding(
          padding: EdgeInsets.only(bottom: i == products.length - 1 ? 0 : 14),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text('${i + 1}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(p.name,
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text('${p.revenue.toStringAsFixed(2)} DT',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 5,
                              backgroundColor: AppColors.surfaceAlt,
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.unitsSold(p.quantitySold),
                            style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------- Alerts ----------

  String _alertText(DashboardAlert a, AppLocalizations l10n) {
    switch (a.type) {
      case AlertType.lowStock:
        return a.value <= 0
            ? l10n.lowStockAlert(a.title)
            : l10n.lowStockWarning(a.title, a.value.toInt());
      case AlertType.creditExceeded:
        return l10n.creditExceededAlert(a.title);
      case AlertType.overduePayment:
        return l10n.overduePaymentAlert(a.title, a.days ?? 0);
      case AlertType.unknown:
        return a.title;
    }
  }

  IconData _alertIcon(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Icons.inventory_2_outlined;
      case AlertType.creditExceeded:
        return Icons.credit_card_off_outlined;
      case AlertType.overduePayment:
        return Icons.schedule;
      case AlertType.unknown:
        return Icons.info_outline;
    }
  }

  Widget _alerts(List<DashboardAlert> alerts, AppLocalizations l10n) {
    if (alerts.isEmpty) {
      return _panel(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: AppColors.success, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.allGood,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 1),
                  Text(l10n.noAlerts,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: alerts.map((a) {
        final color = a.isCritical ? AppColors.danger : AppColors.warning;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25)),
            boxShadow: AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(a.route),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(_alertIcon(a.type), size: 16, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_alertText(a, l10n),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------- Recent activity ----------

  Widget _activity(List<ActivityItem> items, AppLocalizations l10n) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(l10n.noActivity,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ),
      );
    }

    return Column(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isSale = item.kind == 'sale';
        final color = isSale ? AppColors.sales : AppColors.purchases;
        final date = item.createdAt;
        final dateLabel =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

        return Padding(
          padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 13),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                    isSale
                        ? Icons.arrow_outward
                        : Icons.south_west,
                    size: 15,
                    color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 1),
                    Text('${isSale ? l10n.sale : l10n.purchase} · $dateLabel',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(
                  '${isSale ? '+' : '−'}${item.amount.toStringAsFixed(2)} DT',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final reportState = ref.watch(reportProvider);
    final l10n = AppLocalizations.of(context)!;
    final user = authState.user;
    final summary = dashboardState.summary;

    ref.listen(reportProvider, (previous, next) {
      if (next.file != null && previous?.file != next.file) {
        OpenFilex.open(next.file!.path);
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      appBar: AppPageHeader(
        title: l10n.dashboard,
        subtitle: summary == null
            ? null
            : '${summary.kpis.salesCountThisMonth} ${l10n.sales.toLowerCase()} · ${l10n.thisMonth.toLowerCase()}',
        icon: Icons.dashboard_rounded,
        color: AppColors.primary,
        actions: [
          AppHeaderAction(
            icon: Icons.refresh_rounded,
            tooltip: l10n.refresh,
            onTap: () => ref.read(dashboardProvider.notifier).load(),
          ),
        ],
      ),
      body: dashboardState.isLoading || summary == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _hero(
              greeting: _greeting(l10n),
              name: user?.displayName ?? '',
              company: user?.companyName ?? '',
              kpis: summary.kpis,
              l10n: l10n,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI tiles
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.88,
                    children: [
                      _kpiTile(
                        label: l10n.receivables,
                        value:
                        '${summary.kpis.receivables.toStringAsFixed(0)} DT',
                        icon: Icons.call_received,
                        color: AppColors.sales,
                      ),
                      _kpiTile(
                        label: l10n.payables,
                        value:
                        '${summary.kpis.payables.toStringAsFixed(0)} DT',
                        icon: Icons.call_made,
                        color: AppColors.purchases,
                      ),
                      _kpiTile(
                        label: l10n.stockValue,
                        value:
                        '${summary.kpis.stockValue.toStringAsFixed(0)} DT',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.stock,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _sectionHeader(
                      l10n.alerts, Icons.notifications_none, AppColors.danger),
                  _alerts(summary.alerts, l10n),

                  const SizedBox(height: 24),

                  _sectionHeader(
                      l10n.revenueTrend, Icons.show_chart, AppColors.primary),
                  _panel(child: _revenueChart(summary.salesTrend, l10n)),

                  const SizedBox(height: 24),

                  _sectionHeader(
                    l10n.topProducts,
                    Icons.emoji_events_outlined,
                    AppColors.sales,
                    action: TextButton(
                      onPressed: () => context.push('/products'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(l10n.products,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  _panel(child: _topProducts(summary.topProducts, l10n)),

                  const SizedBox(height: 24),

                  _sectionHeader(l10n.recentActivity, Icons.history,
                      AppColors.info),
                  _panel(
                      child: _activity(summary.recentActivity, l10n)),

                  const SizedBox(height: 24),

                  // AI shortcuts
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:
                            AppColors.softShadow(AppColors.primary),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.push('/ai'),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.smart_toy,
                                        size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('AI Copilot',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppColors.cardShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.push('/insights'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.insights,
                                        size: 18,
                                        color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(l10n.insights,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  reportState.isLoading
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : OutlinedButton.icon(
                    onPressed: () => ref
                        .read(reportProvider.notifier)
                        .download(
                      locale: Localizations.localeOf(context)
                          .languageCode,
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: Text(l10n.generatePdfReport),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}