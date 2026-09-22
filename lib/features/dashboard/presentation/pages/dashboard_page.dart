import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../providers/dashboard_provider.dart';
import '../providers/report_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int trendDays = 30;

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

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  // ── Top bar ──

  Widget _topBar(String greeting, String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: AppTheme.label),
              const SizedBox(height: 4),
              Text(name, style: AppTheme.greeting, maxLines: 2),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Builder(
          builder: (context) => AppIconButton(
            icon: Icons.menu,
            onTap: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }

  // ── "This month": terracotta, taller, white text ──

  Widget _revenueCard(DashboardKpis kpis, AppLocalizations l10n) {
    final growth = kpis.revenueGrowthPercent;
    final whiteSoft = Colors.white.withValues(alpha: 0.78);

    return Container(
      width: double.infinity,
      // A minimum height keeps this card the tallest even when the growth
      // line is hidden for lack of previous-month data.
      constraints: const BoxConstraints(minHeight: 176),
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.thisMonth,
                  style: AppTheme.font(
                      size: 14, weight: FontWeight.w500, color: whiteSoft),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${kpis.salesCountThisMonth} ${l10n.sales.toLowerCase()}',
                  style: AppTheme.font(
                    size: 12,
                    weight: FontWeight.w600,
                    color: Colors.white,
                    tabularFigures: true,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    kpis.revenueThisMonth.toStringAsFixed(2),
                    maxLines: 1,
                    style: AppTheme.kpi.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'DT',
                style: AppTheme.font(
                    size: 16, weight: FontWeight.w500, color: whiteSoft),
              ),
            ],
          ),

          // Shown only when there is a previous month to compare against.
          if (growth != null) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  '${growth.abs().toStringAsFixed(1)}%',
                  style: AppTheme.font(
                    size: 15,
                    weight: FontWeight.w600,
                    color: Colors.white,
                    tabularFigures: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.vsLastMonth,
                    style: AppTheme.font(size: 13, color: whiteSoft),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Secondary KPIs ──

  Widget _iconTile(IconData icon, Color color, Color background) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    bool wide = false,
  }) {
    final valueText = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        maxLines: 1,
        style: AppTheme.font(
          size: 22,
          weight: FontWeight.w700,
          letterSpacing: -0.6,
          height: 1.1,
          tabularFigures: true,
        ),
      ),
    );
    final tile = _iconTile(icon, iconColor, iconBackground);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: wide
          ? Row(
        children: [
          tile,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.label, maxLines: 2),
                const SizedBox(height: 4),
                valueText,
              ],
            ),
          ),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tile,
          const SizedBox(height: 16),
          valueText,
          const SizedBox(height: 4),
          Text(label, style: AppTheme.label, maxLines: 2),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTheme.sectionTitle)),
          ?action,
        ],
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }

  Widget _badge(String text, Color foreground, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: AppTheme.font(
            size: 12, weight: FontWeight.w600, color: foreground),
      ),
    );
  }

  /// Standard list row: leading icon, title, gray subtitle, optional
  /// trailing widget, chevron.
  Widget _row({
    required Widget leading,
    required String title,
    String subtitle = '',
    Widget? trailing,
    VoidCallback? onTap,
    bool showChevron = true,
    bool last = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTheme.rowTitle, maxLines: 2),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(subtitle, style: AppTheme.label, maxLines: 2),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing,
                  ],
                  if (showChevron) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right,
                        size: 22, color: AppColors.textMuted),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (!last) const Divider(height: 1),
      ],
    );
  }

  // ── Revenue chart: one terracotta bar per day ──

  Widget _revenueChart(
      List<SalesTrendPoint> fullTrend, AppLocalizations l10n) {
    final trend = fullTrend.length > trendDays
        ? fullTrend.sublist(fullTrend.length - trendDays)
        : fullTrend;

    final hasData = trend.any((p) => p.revenue > 0);
    final total = trend.fold<double>(0, (sum, p) => sum + p.revenue);
    final peak = hasData
        ? trend.map((p) => p.revenue).reduce((a, b) => a > b ? a : b)
        : 0.0;

    // Days without sales still get a short stub so the month keeps its rhythm.
    final emptyHeight = peak * 0.05;
    final barWidth = trendDays <= 7 ? 22.0 : 6.0;
    final labelStep = trendDays <= 7 ? 1 : 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${total.toStringAsFixed(2)} DT',
                    style: AppTheme.font(
                      size: 24,
                      weight: FontWeight.w700,
                      letterSpacing: -0.7,
                      height: 1.1,
                      tabularFigures: true,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$trendDays ${l10n.days}', style: AppTheme.label),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(children: [_periodChip(7), _periodChip(30)]),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!hasData)
          SizedBox(
            height: 150,
            child: Center(
              child: Text(l10n.noSalesYet, style: AppTheme.label),
            ),
          )
        else
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: peak * 1.2,
                alignment: BarChartAlignment.spaceBetween,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (peak / 2).clamp(1, double.infinity),
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >= trend.length ||
                            index % labelStep != 0) {
                          return const SizedBox.shrink();
                        }
                        final day = trend[index].day;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${day.day}/${day.month}',
                            style: AppTheme.font(
                              size: 11,
                              color: AppColors.textMuted,
                              tabularFigures: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.black,
                    tooltipRoundedRadius: 12,
                    tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final point = trend[group.x];
                      if (point.revenue <= 0) return null;
                      return BarTooltipItem(
                        '${point.day.day}/${point.day.month}\n',
                        AppTheme.font(size: 12, color: AppColors.textMuted),
                        children: [
                          TextSpan(
                            text: '${point.revenue.toStringAsFixed(2)} DT',
                            style: AppTheme.font(
                              size: 15,
                              weight: FontWeight.w600,
                              color: Colors.white,
                              tabularFigures: true,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < trend.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: trend[i].revenue > 0
                              ? trend[i].revenue
                              : emptyHeight,
                          width: barWidth,
                          color: trend[i].revenue > 0
                              ? AppColors.accent
                              : AppColors.track,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _periodChip(int days) {
    final selected = trendDays == days;
    return GestureDetector(
      onTap: () => setState(() => trendDays = days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '${days}d',
          style: AppTheme.font(
            size: 13,
            weight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── Alerts ──

  IconData _alertIcon(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Icons.inventory_2_outlined;
      case AlertType.creditExceeded:
        return Icons.credit_card_off_outlined;
      case AlertType.overduePayment:
        return Icons.schedule_outlined;
      case AlertType.unknown:
        return Icons.info_outlined;
    }
  }

  /// Stock alerts say "Out of stock"; other types get their own label so a
  /// credit issue is never mislabelled.
  ({String label, Color fg, Color bg}) _alertBadge(
      DashboardAlert a, AppLocalizations l10n) {
    switch (a.type) {
      case AlertType.lowStock:
        return a.value <= 0
            ? (
        label: l10n.rupture,
        fg: AppColors.danger,
        bg: AppColors.dangerSoft
        )
            : (
        label: l10n.soon,
        fg: AppColors.warning,
        bg: AppColors.warningSoft
        );
      case AlertType.creditExceeded:
        return (
        label: l10n.creditLimitExceeded,
        fg: AppColors.danger,
        bg: AppColors.dangerSoft
        );
      case AlertType.overduePayment:
        return (
        label: l10n.overdue,
        fg: AppColors.danger,
        bg: AppColors.dangerSoft
        );
      case AlertType.unknown:
        return (
        label: l10n.alerts,
        fg: AppColors.danger,
        bg: AppColors.dangerSoft
        );
    }
  }

  String _alertDetail(DashboardAlert a, AppLocalizations l10n) {
    switch (a.type) {
      case AlertType.lowStock:
        return '${a.value.toInt()} ${l10n.inStock}';
      case AlertType.creditExceeded:
        return '${a.value.toStringAsFixed(2)} DT';
      case AlertType.overduePayment:
        return '${a.value.toStringAsFixed(2)} DT · ${a.days ?? 0} ${l10n.days}';
      case AlertType.unknown:
        return '';
    }
  }

  Widget _alerts(List<DashboardAlert> alerts, AppLocalizations l10n) {
    if (alerts.isEmpty) {
      return _card(
        child: Row(
          children: [
            _iconTile(Icons.check_circle_outline, AppColors.success,
                AppColors.successSoft),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.allGood, style: AppTheme.rowTitle),
                  const SizedBox(height: 3),
                  Text(l10n.noAlerts, style: AppTheme.label, maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        children: alerts.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          final badge = _alertBadge(a, l10n);

          return _row(
            leading:
            Icon(_alertIcon(a.type), size: 22, color: AppColors.icon),
            title: a.title,
            subtitle: _alertDetail(a, l10n),
            trailing: _badge(badge.label, badge.fg, badge.bg),
            onTap: () => context.push(a.route),
            last: i == alerts.length - 1,
          );
        }).toList(),
      ),
    );
  }

  // ── Top products: terracotta on a cream track ──

  Widget _topProducts(List<TopProduct> products, AppLocalizations l10n) {
    if (products.isEmpty) {
      return _card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l10n.noSalesYet, style: AppTheme.label),
          ),
        ),
      );
    }

    final maxRevenue = products.first.revenue;

    return _card(
      child: Column(
        children: products.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final ratio = maxRevenue > 0 ? p.revenue / maxRevenue : 0.0;

          return Padding(
            padding:
            EdgeInsets.only(bottom: i == products.length - 1 ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                      Text(p.name, style: AppTheme.rowTitle, maxLines: 2),
                    ),
                    const SizedBox(width: 12),
                    Text('${p.revenue.toStringAsFixed(2)} DT',
                        style: AppTheme.money),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: AppColors.track,
                    valueColor:
                    const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.unitsSold(p.quantitySold), style: AppTheme.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Recent activity ──

  Widget _activity(List<ActivityItem> items, AppLocalizations l10n) {
    if (items.isEmpty) {
      return _card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l10n.noActivity, style: AppTheme.label),
          ),
        ),
      );
    }

    final shown = items.take(5).toList();

    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        children: shown.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isSale = item.kind == 'sale';

          return _row(
            // Money coming in points into the business; money going out
            // points away — same convention as the receivables/payables cards.
            leading: isSale
                ? _iconTile(Icons.south_west_outlined, AppColors.success,
                AppColors.successSoft)
                : _iconTile(Icons.north_east_outlined, AppColors.warning,
                AppColors.warningSoft),
            title: item.label,
            subtitle:
            '${isSale ? l10n.sale : l10n.purchase} · ${_date(item.createdAt)} ${_time(item.createdAt)}',
            showChevron: false,
            trailing: Text(
              '${isSale ? '+' : '−'}${item.amount.toStringAsFixed(2)} DT',
              style: AppTheme.font(
                size: 15,
                weight: FontWeight.w600,
                color: isSale ? AppColors.success : AppColors.textPrimary,
                tabularFigures: true,
              ),
            ),
            last: i == shown.length - 1,
          );
        }).toList(),
      ),
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
      backgroundColor: AppColors.canvas,
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: SafeArea(
        bottom: false,
        child: dashboardState.isLoading || summary == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () => ref.read(dashboardProvider.notifier).load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              _topBar(_greeting(l10n), user?.displayName ?? ''),

              const SizedBox(height: 24),
              _revenueCard(summary.kpis, l10n),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      label: l10n.receivables,
                      value:
                      '${summary.kpis.receivables.toStringAsFixed(0)} DT',
                      icon: Icons.south_west_outlined,
                      iconColor: AppColors.success,
                      iconBackground: AppColors.successSoft,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      label: l10n.payables,
                      value:
                      '${summary.kpis.payables.toStringAsFixed(0)} DT',
                      icon: Icons.north_east_outlined,
                      iconColor: AppColors.warning,
                      iconBackground: AppColors.warningSoft,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _statCard(
                label: l10n.stockValue,
                value:
                '${summary.kpis.stockValue.toStringAsFixed(2)} DT',
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.accent,
                iconBackground: AppColors.accentSoft,
                wide: true,
              ),

              const SizedBox(height: 24),
              _sectionTitle(l10n.alerts),
              _alerts(summary.alerts, l10n),

              const SizedBox(height: 24),
              _sectionTitle(l10n.revenueTrend),
              _card(child: _revenueChart(summary.salesTrend, l10n)),

              const SizedBox(height: 24),
              _sectionTitle(
                l10n.topProducts,
                action: TextButton(
                  onPressed: () => context.push('/products'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l10n.products),
                ),
              ),
              _topProducts(summary.topProducts, l10n),

              const SizedBox(height: 24),
              _sectionTitle(l10n.recentActivity),
              _activity(summary.recentActivity, l10n),

              const SizedBox(height: 24),
              reportState.isLoading
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
                  : FilledButton(
                onPressed: () =>
                    ref.read(reportProvider.notifier).download(
                      locale: Localizations.localeOf(context)
                          .languageCode,
                    ),
                child: Text(l10n.generatePdfReport),
              ),
            ],
          ),
        ),
      ),
    );
  }
}