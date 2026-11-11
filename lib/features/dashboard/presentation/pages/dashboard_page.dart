import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../purchases/presentation/pages/create_purchase_page.dart';
import '../../../sales/presentation/pages/create_sale_page.dart';
import '../../../stock/presentation/providers/product_provider.dart';
import '../../../stock/presentation/widgets/product_form_route.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../providers/dashboard_provider.dart';
import '../providers/report_provider.dart';
import '../../../../shared/widgets/app_drawer.dart' show roleLabelFor;

/// Home: top bar, alert banner, 4 KPI cards, quick actions, revenue chart,
/// top products and recent activity. Phones get one column (KPIs 2×2);
/// from 840px a two-column layout.
///
///   ┌ AppPageHeader: ☰  Company / user · role            🔔9 ┐
///   │ ⚠ 9 alerts · 2 out of stock · 2 low stock · 5 overdue ›│
///   │ [Revenue] [Receivables] [Payables] [Stock value]       │
///   │ [New sale] [New purchase] [Add product] [Scan] [Cat.]   │
///   │ Revenue chart (7d/30d)          │ Top products (5)      │
///   │                                 │ Recent activity (5)   │
///   │                          [Download PDF report]          │
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int trendDays = 7;

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  Future<void> _reload() async {
    await Future.wait([
      ref.read(dashboardProvider.notifier).load(),
      ref.read(notificationProvider.notifier).load(),
    ]);
  }

  bool _can(UserEntity? user, String permission) =>
      user?.can(permission) ?? false;

  // ── Pieces ──

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _cardTitle(String title, {Widget? action}) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTheme.sectionTitle)),
          ?action,
        ],
      ),
    );
  }

  /// "9 alerts · 2 out of stock · 2 low stock · 5 overdue payments".
  /// Shown only when there are alerts; opens Notifications.
  Widget _alertBanner(NotificationState n, AppLocalizations l10n) {
    final out = n.countOf(NotificationType.outOfStock);
    final low = n.countOf(NotificationType.lowStock);
    final overdue = n.countOf(NotificationType.overduePayment);
    final other = n.count - out - low - overdue;
    final parts = [
      if (out > 0) l10n.alertsOutOfStock(out),
      if (low > 0) l10n.alertsLowStock(low),
      if (overdue > 0) l10n.alertsOverdue(overdue),
      if (other > 0) l10n.alertsOther(other),
    ];
    return AppPressable(
      onTap: () => openNotifications(context),
      borderRadius: BorderRadius.circular(AppRadius.card),
      color: AppColors.warningSoft,
      hoverColor: const Color(0xFFFEF3C7),
      semanticLabel: '${l10n.alertsBanner(n.count)}. ${parts.join(', ')}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.warningBorder),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 20, color: AppColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: l10n.alertsBanner(n.count),
                    style: AppTheme.font(size: 13, weight: FontWeight.w600),
                  ),
                  if (parts.isNotEmpty)
                    TextSpan(
                      text: ' · ${parts.join(' · ')}',
                      style: AppTheme.font(
                          size: 13, color: AppColors.textSecondary),
                    ),
                ]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.iconMuted),
          ],
        ),
      ),
    );
  }

  Widget _kpi({
    required String label,
    required String value,
    required IconData icon,
    String? caption,
    Color? captionColor,
    bool highlightIcon = false,
  }) {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: AppTheme.font(
                        size: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(icon,
                  size: 16,
                  color:
                      highlightIcon ? AppColors.primary : AppColors.iconMuted),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, maxLines: 1, style: AppTheme.kpi),
          ),
          const SizedBox(height: 6),
          Text(
            caption ?? ' ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.font(
              size: 12,
              weight: FontWeight.w500,
              color: captionColor ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _kpis(DashboardKpis k, AppLocalizations l10n) {
    final growth = k.revenueGrowthPercent;
    String? caption;
    Color? color;
    if (growth != null) {
      final sign = growth >= 0 ? '+' : '−';
      caption = l10n.vsLastMonth;
      caption = '$sign${growth.abs().toStringAsFixed(1)}% $caption';
      color = growth >= 0 ? AppColors.successText : AppColors.dangerText;
    }
    return [
      _kpi(
        label: l10n.revenueThisMonth,
        value: formatDT(k.revenueThisMonth),
        icon: Icons.trending_up,
        caption: caption,
        captionColor: color,
        highlightIcon: true,
      ),
      _kpi(
        label: l10n.receivables,
        value: formatDT(k.receivables),
        icon: Icons.south_west,
      ),
      _kpi(
        label: l10n.payables,
        value: formatDT(k.payables),
        icon: Icons.north_east,
      ),
      _kpi(
        label: l10n.stockValue,
        value: formatDT(k.stockValue),
        icon: Icons.inventory_2_outlined,
      ),
    ];
  }

  // ── Quick actions ──

  List<({IconData icon, String label, VoidCallback onTap})> _actions(
      UserEntity? user, AppLocalizations l10n) {
    final nav = Navigator.of(context, rootNavigator: true);
    return [
      if (_can(user, 'manage_sales'))
        (
          icon: Icons.add_shopping_cart_outlined,
          label: l10n.newSale,
          onTap: () async {
            await nav.push(MaterialPageRoute(builder: (_) => const CreateSalePage()));
            if (mounted) _reload();
          },
        ),
      if (_can(user, 'manage_purchases'))
        (
          icon: Icons.local_shipping_outlined,
          label: l10n.newPurchase,
          onTap: () async {
            await nav.push(MaterialPageRoute(builder: (_) => const CreatePurchasePage()));
            if (mounted) _reload();
          },
        ),
      if (_can(user, 'manage_products'))
        (
          icon: Icons.add_box_outlined,
          label: l10n.addProduct,
          onTap: () async {
            final input = await openProductForm(context, ref);
            if (input == null) return;
            await ref.read(productListProvider.notifier).add(input);
            if (mounted) _reload();
          },
        ),
      if (_can(user, 'scan_documents'))
        (
          icon: Icons.document_scanner_outlined,
          label: l10n.scanShort,
          onTap: () => context.go('/scan'),
        ),
      if (_can(user, 'view_products'))
        (
          icon: Icons.category_outlined,
          label: l10n.categories,
          onTap: () => context.go('/categories'),
        ),
    ];
  }

  Widget _quickActions(UserEntity? user, AppLocalizations l10n, bool wide) {
    final actions = _actions(user, l10n);
    if (actions.isEmpty) return const SizedBox.shrink();

    if (wide) {
      // Web: a row of secondary buttons; the first action is primary.
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < actions.length; i++)
            i == 0
                ? FilledButton.icon(
                    onPressed: actions[i].onTap,
                    icon: Icon(actions[i].icon, size: 18),
                    label: Text(actions[i].label),
                  )
                : OutlinedButton.icon(
                    onPressed: actions[i].onTap,
                    icon: Icon(actions[i].icon, size: 18),
                    label: Text(actions[i].label),
                  ),
        ],
      );
    }

    // Phone: equal tiles, icon over label, scrolling sideways if needed.
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final a = actions[i];
          return SizedBox(
            width: 84,
            child: AppPressable(
              onTap: a.onTap,
              borderRadius: BorderRadius.circular(AppRadius.card),
              color: AppColors.surface,
              semanticLabel: a.label,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(a.icon, size: 22, color: AppColors.primary),
                    const SizedBox(height: 6),
                    Text(a.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.font(
                            size: 12,
                            weight: FontWeight.w500,
                            color: AppColors.textLabel)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Revenue chart ──

  Widget _periodSwitch() {
    Widget seg(int days) {
      final selected = trendDays == days;
      return AppPressable(
        onTap: () => setState(() => trendDays = days),
        selected: selected,
        borderRadius: BorderRadius.zero,
        semanticLabel: '$days ${AppLocalizations.of(context)!.days}',
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          color: selected ? AppColors.fill : Colors.transparent,
          child: Text('${days}d',
              style: AppTheme.font(
                  size: 12,
                  weight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.fieldBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          seg(7),
          Container(width: 1, height: 32, color: AppColors.fieldBorder),
          seg(30),
        ],
      ),
    );
  }

  Widget _revenueChart(List<SalesTrendPoint> fullTrend, AppLocalizations l10n) {
    final trend = fullTrend.length > trendDays
        ? fullTrend.sublist(fullTrend.length - trendDays)
        : fullTrend;
    final hasData = trend.any((p) => p.revenue > 0);
    final total = trend.fold<double>(0, (sum, p) => sum + p.revenue);
    final peak = hasData
        ? trend.map((p) => p.revenue).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final labelStep = trendDays <= 7 ? 1 : 7;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(l10n.revenue, action: _periodSwitch()),
          const SizedBox(height: 4),
          Text(formatDT(total),
              style: AppTheme.font(
                  size: 18, weight: FontWeight.w600, tabularFigures: true)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: !hasData
                ? Center(child: Text(l10n.noSalesYet, style: AppTheme.label))
                : LayoutBuilder(builder: (context, box) {
                    final slot = box.maxWidth / trend.length;
                    final barWidth = (slot * 0.6).clamp(3.0, 28.0);
                    return BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: peak * 1.15,
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval:
                              (peak / 3).clamp(1, double.infinity),
                          getDrawingHorizontalLine: (_) => const FlLine(
                              color: AppColors.border, strokeWidth: 1),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                              bottom: BorderSide(color: AppColors.border)),
                        ),
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
                              reservedSize: 24,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 ||
                                    i >= trend.length ||
                                    (trend.length - 1 - i) % labelStep != 0) {
                                  return const SizedBox.shrink();
                                }
                                final d = trend[i].day;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text('${d.day}/${d.month}',
                                      style: AppTheme.font(
                                          size: 11,
                                          color: AppColors.textSecondary,
                                          tabularFigures: true)),
                                );
                              },
                            ),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => AppColors.black,
                            tooltipRoundedRadius: 8,
                            tooltipPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final p = trend[group.x];
                              if (p.revenue <= 0) return null;
                              return BarTooltipItem(
                                '${p.day.day}/${p.day.month}\n',
                                AppTheme.font(
                                    size: 11, color: AppColors.textOnInkMuted),
                                children: [
                                  TextSpan(
                                    text: formatDT(p.revenue),
                                    style: AppTheme.font(
                                        size: 13,
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                        tabularFigures: true),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < trend.length; i++)
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(
                                toY: trend[i].revenue > 0
                                    ? trend[i].revenue
                                    : peak * 0.02,
                                width: barWidth,
                                color: trend[i].revenue <= 0
                                    ? AppColors.track
                                    : i == trend.length - 1
                                        ? AppColors.primary
                                        : AppColors.primaryLight,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(3)),
                              ),
                            ]),
                        ],
                      ),
                    );
                  }),
          ),
        ],
      ),
    );
  }

  // ── Lists ──

  Widget _listCard({
    required String title,
    Widget? action,
    required List<Widget> rows,
    required String emptyText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: _cardTitle(title, action: action),
          ),
          if (rows.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border))),
              alignment: Alignment.center,
              child: Text(emptyText, style: AppTheme.label),
            )
          else
            ...rows,
        ],
      ),
    );
  }

  Widget _listRow({
    Widget? leading,
    required String title,
    String? subtitle,
    required String trailing,
    Color? trailingColor,
    VoidCallback? onTap,
  }) {
    final row = Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTheme.font(size: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTheme.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(trailing,
              style: AppTheme.font(
                  size: 14,
                  weight: FontWeight.w500,
                  color: trailingColor ?? AppColors.textPrimary,
                  tabularFigures: true)),
        ],
      ),
    );
    if (onTap == null) return row;
    return AppPressable(
        onTap: onTap, borderRadius: BorderRadius.zero, child: row);
  }

  Widget _topProducts(List<TopProduct> products, AppLocalizations l10n) {
    final shown = products.take(5).toList();
    return _listCard(
      title: l10n.topProducts,
      action: TextButton(
        onPressed: () => context.go('/products'),
        child: Text(l10n.seeAll),
      ),
      emptyText: l10n.noSalesYet,
      rows: [
        for (var i = 0; i < shown.length; i++)
          _listRow(
            leading: SizedBox(
              width: 18,
              child: Text('${i + 1}',
                  style: AppTheme.font(
                      size: 12, color: AppColors.textSecondary)),
            ),
            title: shown[i].name,
            subtitle: l10n.unitsSold(shown[i].quantitySold),
            trailing: formatDT(shown[i].revenue),
          ),
      ],
    );
  }

  Widget _activity(List<ActivityItem> items, UserEntity? user,
      AppLocalizations l10n) {
    final shown = items.take(5).toList();
    // "See all" goes to the full list the user can open.
    final seeAll = _can(user, 'view_audit')
        ? '/audit'
        : _can(user, 'view_sales')
            ? '/sales'
            : null;
    return _listCard(
      title: l10n.recentActivity,
      action: seeAll == null
          ? null
          : TextButton(
              onPressed: () => context.go(seeAll),
              child: Text(l10n.seeAll),
            ),
      emptyText: l10n.noActivity,
      rows: [
        for (final item in shown)
          _listRow(
            leading: Icon(
              item.kind == 'sale' ? Icons.south_west : Icons.north_east,
              size: 16,
              color: item.kind == 'sale'
                  ? AppColors.success
                  : AppColors.iconMuted,
            ),
            title: item.label,
            subtitle:
                '${item.kind == 'sale' ? l10n.sale : l10n.purchase} · ${formatDateTime(item.createdAt)}',
            trailing:
                formatSignedDT(item.amount, incoming: item.kind == 'sale'),
            trailingColor: item.kind == 'sale'
                ? AppColors.successText
                : AppColors.textPrimary,
          ),
      ],
    );
  }

  Widget _reportButton(ReportState report, AppLocalizations l10n) {
    return Align(
      alignment: Alignment.centerRight,
      child: OutlinedButton.icon(
        onPressed: report.isLoading
            ? null
            : () => ref.read(reportProvider.notifier).download(
                  locale: Localizations.localeOf(context).languageCode,
                ),
        icon: report.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.picture_as_pdf_outlined, size: 18),
        label: Text(l10n.downloadPdfReport),
      ),
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authNotifierProvider.select((s) => s.user));
    final dashboardState = ref.watch(dashboardProvider);
    final notifications = ref.watch(notificationProvider);
    final reportState = ref.watch(reportProvider);
    final summary = dashboardState.summary;

    ref.listen(reportProvider, (previous, next) {
      if (next.deliveredCount > (previous?.deliveredCount ?? 0)) {
        AppSnack.success(context, l10n.reportReady);
      }
      if (next.error != null && previous?.error == null) {
        AppSnack.error(context, l10n.reportFailed);
      }
    });

    final company = (user?.companyName.isNotEmpty ?? false)
        ? user!.companyName
        : l10n.dashboard;
    final who = user == null
        ? null
        : '${user.displayName} · ${roleLabelFor(user.role, l10n)}';

    final Widget body;
    if (summary != null && !dashboardState.isLoading) {
      body = RefreshIndicator(
        onRefresh: _reload,
        child: LayoutBuilder(builder: (context, box) {
          final wide = box.maxWidth >= 840;
          const gap = SizedBox(height: AppSpacing.gap, width: AppSpacing.gap);
          final kpis = _kpis(summary.kpis, l10n);

          final kpiGrid = wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < kpis.length; i++) ...[
                      if (i > 0) gap,
                      Expanded(child: kpis[i]),
                    ],
                  ],
                )
              : Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: kpis[0]),
                    gap,
                    Expanded(child: kpis[1]),
                  ]),
                  gap,
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: kpis[2]),
                    gap,
                    Expanded(child: kpis[3]),
                  ]),
                ]);

          final chart = _revenueChart(summary.salesTrend, l10n);
          final top = _topProducts(summary.topProducts, l10n);
          final activity = _activity(summary.recentActivity, user, l10n);

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(wide ? 24 : AppSpacing.page),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (notifications.count > 0) ...[
                        _alertBanner(notifications, l10n),
                        gap,
                      ],
                      kpiGrid,
                      gap,
                      _quickActions(user, l10n, wide),
                      gap,
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: chart),
                            gap,
                            Expanded(
                              flex: 2,
                              child: Column(children: [top, gap, activity]),
                            ),
                          ],
                        )
                      else ...[
                        chart,
                        gap,
                        top,
                        gap,
                        activity,
                      ],
                      const SizedBox(height: 16),
                      _reportButton(reportState, l10n),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      );
    } else if (dashboardState.error != null && !dashboardState.isLoading) {
      body = AppErrorState(
        title: l10n.loadFailedTitle,
        message: l10n.serverUnreachable,
        retryLabel: l10n.retry,
        onRetry: _reload,
      );
    } else {
      body = AppSkeletonList(rows: 5, semanticLabel: l10n.loading);
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: company,
        subtitle: who,
        icon: Icons.home_outlined,
        color: AppColors.primary,
      ),
      body: body,
    );
  }
}
