import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_motion.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../purchases/presentation/pages/create_purchase_page.dart';
import '../../../purchases/presentation/providers/purchase_provider.dart';
import '../../../../shared/widgets/app_data_table.dart' show AppAvatar;
import '../../../sales/presentation/pages/create_sale_page.dart';
import '../../../stock/presentation/providers/product_provider.dart';
import '../../../stock/presentation/widgets/product_form_route.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../providers/dashboard_provider.dart';
import '../providers/report_provider.dart';
import '../widgets/revenue_trend_chart.dart';
import '../../../../shared/widgets/app_drawer.dart' show roleLabelFor;
import '../../../../shared/widgets/app_notification_bell.dart';
import '../../../../shared/widgets/app_shell.dart';

/// Overview, in the "Ledger" layout (inspired by Mercury):
///
///   Greeting + date                         [Monthly report] [New sale]
///   [ Revenue this month  48 320.00 DT ↑12%  7D 30D 90D 12M ] [ Cash   ]
///   [ ~~~~~~~~ line, dashed previous period ~~~~~~~~~~~~~~~  ] [ in/out ]
///   [To collect] [Overdue] [Low stock] [Sales this month]
///   [ Recent activity                      ] [ Needs attention ]
///                                            [ Top products    ]
///
/// Phones stack everything in one column (KPIs 2×2). Every figure comes from
/// the dashboard API; a card without data is left out, never faked.
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  Future<void> _reload() async {
    final user = ref.read(authNotifierProvider).user;
    await Future.wait([
      ref.read(dashboardProvider.notifier).load(),
      ref.read(notificationProvider.notifier).load(),
      // The cash card (wide screens) names who owes the most and which
      // supplier bills are oldest; only for users who may see those lists.
      if (_can(user, 'view_customers'))
        ref.read(customerListProvider.notifier).load(),
      if (_can(user, 'view_purchases'))
        ref.read(purchaseListProvider.notifier).load(),
    ]);
  }

  bool _can(UserEntity? user, String permission) =>
      user?.can(permission) ?? false;

  // ── Building blocks ──

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
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
      child: Row(children: [
        Expanded(child: Text(title, style: AppTheme.sectionTitle)),
        ?action,
      ]),
    );
  }

  // ── Header ──

  /// Follows the clock: morning until noon, afternoon until 18:00, then
  /// evening.
  String _greeting(AppLocalizations l10n, [DateTime? now]) {
    final h = (now ?? DateTime.now()).hour;
    if (h < 12) return l10n.goodMorning;
    if (h < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  void _downloadReport() => ref
      .read(reportProvider.notifier)
      .download(lang: ref.read(localeProvider).languageCode);

  /// Phones: every secondary action in one "More" menu next to New sale,
  /// instead of five buttons wrapping over three ragged rows.
  Widget _moreMenu(UserEntity? user, ReportState report, AppLocalizations l10n) {
    final items = <(IconData, String, VoidCallback)>[
      if (!report.isLoading)
        (Icons.download_outlined, l10n.downloadPdfReport, _downloadReport),
      if (_can(user, 'manage_purchases'))
        (Icons.local_shipping_outlined, l10n.newPurchase, _newPurchase),
      if (_can(user, 'manage_products'))
        (Icons.add_box_outlined, l10n.addProduct, _addProduct),
      if (_can(user, 'scan_documents'))
        (Icons.document_scanner_outlined, l10n.scanShort,
            () => context.push('/scan')),
      // Categories one tap from the overview (the web has them in the
      // sidebar's Inventory group).
      if (_can(user, 'view_products'))
        (Icons.category_outlined, l10n.categories,
            () => context.push('/categories')),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return PopupMenuButton<VoidCallback>(
      tooltip: l10n.moreActions,
      onSelected: (action) => action(),
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final (icon, label, action) in items)
          PopupMenuItem(
            value: action,
            child: Row(children: [
              Icon(icon, size: 20, color: AppColors.icon),
              const SizedBox(width: 12),
              Text(label, style: AppTheme.body),
            ]),
          ),
      ],
      child: _squareBox(
        report.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.more_horiz, size: 22, color: AppColors.icon),
      ),
    );
  }

  /// Phones: the white rounded square behind Scan / More (52px, thumb size).
  Widget _squareBox(Widget child, {double size = 52}) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(size >= 52 ? 14 : 12),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );

  Widget _squareButton(IconData icon, String tooltip, VoidCallback onTap,
          {double size = 52, Color color = AppColors.icon}) =>
      Tooltip(
        message: tooltip,
        child: AppPressable(
          onTap: onTap,
          semanticLabel: tooltip,
          borderRadius: BorderRadius.circular(size >= 52 ? 14 : 12),
          child: _squareBox(Icon(icon, size: 22, color: color), size: size),
        ),
      );

  /// Phones: New sale in the thumb zone, then Scan and More.
  Widget _phoneActions(
      UserEntity? user, ReportState report, AppLocalizations l10n) {
    return Row(children: [
      if (_can(user, 'manage_sales'))
        Expanded(
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: AppTheme.font(size: 15, weight: FontWeight.w600),
              ),
              onPressed: _newSale,
              icon: const Icon(Icons.add, size: 20),
              label: Text(l10n.newSale),
            ),
          ),
        )
      else
        const Spacer(),
      if (_can(user, 'scan_documents')) ...[
        const SizedBox(width: 10),
        _squareButton(Icons.qr_code_scanner, l10n.scanShort,
            () => context.push('/scan')),
      ],
      const SizedBox(width: 10),
      _moreMenu(user, report, l10n),
    ]);
  }

  Future<void> _newPurchase() async {
    await Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
            fullscreenDialog: true, builder: (_) => const CreatePurchasePage()));
    if (mounted) _reload();
  }

  Future<void> _addProduct() async {
    final input = await openProductForm(context, ref);
    if (input == null) return;
    await ref.read(productListProvider.notifier).add(input);
    if (mounted) _reload();
  }

  Widget _header(UserEntity? user, ReportState report, AppLocalizations l10n,
      bool wide) {
    final locale = Localizations.localeOf(context).toString();
    final name = (user?.fullName ?? '').trim().split(' ').first;
    final title = name.isEmpty
        ? _greeting(l10n)
        : l10n.greetingWithName(_greeting(l10n), name);
    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          // Day first, like every other date in the app (15/11/2026).
          toBeginningOfSentenceCase(
                  DateFormat('EEEE d MMMM y', locale).format(DateTime.now())) ??
              '',
          style: AppTheme.font(
              size: 13,
              weight: FontWeight.w500,
              color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(title,
            style: wide
                ? AppTheme.pageTitleWide
                : AppTheme.heading(
                    size: 26, weight: FontWeight.w800, height: 1.15)),
      ],
    );
    if (!wide) {
      // Phones: the greeting IS the header (no bar above it), with the AI
      // copilot and the bell as rounded squares on the right.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: greeting),
          if (_can(user, 'use_ai')) ...[
            _squareButton(Icons.auto_awesome_outlined, l10n.askAi,
                () => context.push('/ai'),
                size: 48, color: AppColors.primary),
            const SizedBox(width: 8),
          ],
          // 48: the bell button's own size, so its count badge sits on the
          // corner instead of covering the bell.
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const AppNotificationBell(),
          ),
        ],
      );
    }
    // Wide: every action on one row under the greeting: New sale first
    // (primary), then the other shortcuts, and the PDF report at the end.
    final download = OutlinedButton.icon(
      onPressed: report.isLoading
          ? null
          // The app's own language setting decides the PDF language.
          : _downloadReport,
      icon: report.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.download_outlined, size: 18),
      label: Text(l10n.downloadPdfReport),
    );
    final actions = [
      if (_can(user, 'manage_sales'))
        FilledButton.icon(
          onPressed: _newSale,
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.newSale),
        ),
      ..._shortcuts(user, l10n),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        greeting,
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, box) => box.maxWidth >= 860
              ? Row(children: [
                  for (final a in actions) ...[a, const SizedBox(width: 8)],
                  const Spacer(),
                  download,
                ])
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [...actions, download],
                ),
        ),
      ],
    );
  }

  Future<void> _newSale() async {
    await Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
            fullscreenDialog: true, builder: (_) => const CreateSalePage()));
    if (mounted) _reload();
  }

  /// The other shortcuts (purchase, product, scan), as quiet buttons.
  List<Widget> _shortcuts(UserEntity? user, AppLocalizations l10n) {
    final nav = Navigator.of(context, rootNavigator: true);
    final items = <Widget>[
      if (_can(user, 'manage_purchases'))
        OutlinedButton.icon(
          onPressed: () async {
            await nav.push(
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const CreatePurchasePage()));
            if (mounted) _reload();
          },
          icon: const Icon(Icons.local_shipping_outlined, size: 18),
          label: Text(l10n.newPurchase),
        ),
      if (_can(user, 'manage_products'))
        OutlinedButton.icon(
          onPressed: () async {
            final input = await openProductForm(context, ref);
            if (input == null) return;
            await ref.read(productListProvider.notifier).add(input);
            if (mounted) _reload();
          },
          icon: const Icon(Icons.add_box_outlined, size: 18),
          label: Text(l10n.addProduct),
        ),
      if (_can(user, 'scan_documents'))
        OutlinedButton.icon(
          onPressed: () => context.go('/scan'),
          icon: const Icon(Icons.document_scanner_outlined, size: 18),
          label: Text(l10n.scanShort),
        ),
    ];
    return items;
  }

  // ── Alerts ──

  /// The alert strip at the top of the overview: how many alerts, split by
  /// kind (overdue payments, out of stock, low stock), with a way to see
  /// them all. Red when one is critical, amber otherwise; hidden when clear.
  Widget? _alertStrip(NotificationState n, AppLocalizations l10n) {
    if (n.count == 0) return null;
    int count(NotificationType t) => n.items.where((i) => i.type == t).length;
    final overdue = count(NotificationType.overduePayment);
    final out = count(NotificationType.outOfStock);
    final low = count(NotificationType.lowStock);
    final critical = n.items.any((i) => i.isCritical);
    final fg = critical ? AppColors.dangerText : AppColors.warningText;
    final details = [
      if (overdue > 0) l10n.alertsOverdue(overdue),
      if (out > 0) l10n.alertsOutOfStock(out),
      if (low > 0) l10n.alertsLowStock(low),
    ].join(' · ');
    return AppPressable(
      onTap: () async {
        await openNotifications(context);
        if (mounted) _reload();
      },
      semanticLabel: '${l10n.alertsBanner(n.count)}. $details',
      borderRadius: BorderRadius.circular(AppRadius.card),
      color: critical ? AppColors.dangerSoft : AppColors.warningSoft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: fg.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          Icon(critical ? Icons.error_outline : Icons.warning_amber_rounded,
              size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: l10n.alertsBanner(n.count),
                    style: AppTheme.font(
                        size: 14, weight: FontWeight.w600, color: fg)),
                if (details.isNotEmpty)
                  TextSpan(
                      text: '  ·  $details',
                      style: AppTheme.font(size: 13, color: fg)),
              ]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(l10n.seeAll,
              style: AppTheme.font(
                  size: 13, weight: FontWeight.w600, color: fg)),
          Icon(Icons.chevron_right, size: 18, color: fg),
        ]),
      ),
    );
  }

  // ── Revenue hero ──

  Widget _periodSwitch(int selected, AppLocalizations l10n,
      {bool expand = false}) {
    final options = [
      (7, l10n.period7d),
      (30, l10n.period30d),
      (90, l10n.period90d),
      (365, l10n.period12m),
    ];
    return Semantics(
      label: l10n.chartPeriod,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.fill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
          for (final (days, label) in options)
            _maybeExpanded(expand, AppPressable(
              onTap: () =>
                  ref.read(dashboardProvider.notifier).setPeriod(days),
              selected: days == selected,
              semanticLabel: label,
              borderRadius: BorderRadius.circular(6),
              color: days == selected ? AppColors.surface : Colors.transparent,
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 11),
                alignment: Alignment.center,
                decoration: days == selected
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x14101828),
                              blurRadius: 2,
                              offset: Offset(0, 1)),
                        ],
                      )
                    : null,
                child: Text(label,
                    style: AppTheme.font(
                      size: 13,
                      weight:
                          days == selected ? FontWeight.w600 : FontWeight.w500,
                      color: days == selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    )),
              ),
            )),
        ]),
      ),
    );
  }

  Widget _maybeExpanded(bool expand, Widget child) =>
      expand ? Expanded(child: child) : child;

  /// The loading bar, the retry line and the chart: shared by both heroes.
  List<Widget> _chartBlock(DashboardState state, DashboardSummaryEntity s,
      AppLocalizations l10n, {double height = 200}) => [
        SizedBox(
          height: 2,
          child: state.trendLoading
              ? const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: AppColors.fill,
                  color: AppColors.primary)
              : null,
        ),
        if (state.trendFailed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              const Icon(Icons.error_outline,
                  size: 18, color: AppColors.danger),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(l10n.chartLoadFailed, style: AppTheme.label)),
              TextButton(
                onPressed: () => ref
                    .read(dashboardProvider.notifier)
                    .setPeriod(state.trendDays),
                child: Text(l10n.retry),
              ),
            ]),
          ),
        const SizedBox(height: 4),
        RevenueTrendChart(
          current: s.salesTrend,
          previous: s.salesTrendPrevious,
          trendDays: s.trendDays,
          height: height,
        ),
      ];

  /// Phones: label and growth on one line, the big figure, the comparison,
  /// the chart, then the period switch full width under it (thumb reach).
  Widget _phoneHero(DashboardState state, DashboardSummaryEntity s,
      AppLocalizations l10n) {
    final k = s.kpis;
    final growth = k.revenueGrowthPercent;
    return _card(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(l10n.revenueThisMonth,
                  style: AppTheme.font(
                      size: 13,
                      weight: FontWeight.w500,
                      color: AppColors.textSecondary)),
            ),
            if (growth != null)
              AppBadge(
                icon: growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                label: '${growth.abs().toStringAsFixed(1)}%',
                tone: growth >= 0 ? BadgeTone.success : BadgeTone.danger,
              ),
          ]),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(formatDT(k.revenueThisMonth),
                style: AppTheme.heading(
                    size: 34,
                    weight: FontWeight.w800,
                    height: 1.1,
                    tabularFigures: true)),
          ),
          if (growth != null) ...[
            const SizedBox(height: 2),
            Text('${l10n.vsLastMonth} (${formatDT(k.revenuePrevMonth)})',
                style: AppTheme.label),
          ],
          const SizedBox(height: 10),
          ..._chartBlock(state, s, l10n),
          const SizedBox(height: 10),
          _periodSwitch(state.trendDays, l10n, expand: true),
        ],
      ),
    );
  }

  Widget _hero(DashboardState state, DashboardSummaryEntity s,
      AppLocalizations l10n) {
    final k = s.kpis;
    final growth = k.revenueGrowthPercent;
    return _card(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.revenueThisMonth,
                      style: AppTheme.font(
                          size: 13,
                          weight: FontWeight.w500,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(formatDT(k.revenueThisMonth),
                        style: AppTheme.hero),
                  ),
                  if (growth != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // One indicator: the arrow replaces the badge's dot.
                        AppBadge(
                          icon: growth >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          label: '${growth.abs().toStringAsFixed(1)}%',
                          tone: growth >= 0
                              ? BadgeTone.success
                              : BadgeTone.danger,
                        ),
                        Text(
                            '${l10n.vsLastMonth} (${formatDT(k.revenuePrevMonth)})',
                            style: AppTheme.label),
                      ],
                    ),
                  ],
                ],
              ),
              _periodSwitch(state.trendDays, l10n),
            ],
          ),
          const SizedBox(height: 10),
          // A thin bar while another period loads; the old chart stays.
          // Taller on wide screens so the card lines up with the cash card
          // beside it (its customer and supplier lists).
          ..._chartBlock(state, s, l10n, height: 320),
        ],
      ),
    );
  }

  // ── Cash ──

  /// One name + amount line inside the cash card.
  Widget _cashRow({
    required Widget leading,
    required String name,
    String? sub,
    required double amount,
    required Color color,
    VoidCallback? onTap,
  }) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        leading,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.font(size: 13, weight: FontWeight.w500)),
              if (sub != null)
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        size: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(formatDT(amount),
            style: AppTheme.font(
                size: 13,
                weight: FontWeight.w600,
                tabularFigures: true,
                color: color)),
      ]),
    );
    if (onTap == null) return row;
    return AppPressable(
      onTap: onTap,
      semanticLabel: '$name ${formatDT(amount)}',
      borderRadius: BorderRadius.circular(8),
      hoverColor: AppColors.surfaceAlt,
      child: row,
    );
  }

  /// Wide screens: under the net position, the 3 customers who owe the most
  /// and the 2 oldest unpaid supplier bills, so the card has no empty space
  /// and says who is behind the figures.
  List<Widget> _cashDetails(AppLocalizations l10n) {
    final user = ref.watch(authNotifierProvider.select((s) => s.user));
    final debtors = _can(user, 'view_customers')
        ? (ref
              .watch(customerListProvider)
              .customers
              .where((c) => c.owesMoney)
              .toList()
            ..sort((a, b) => b.balance.compareTo(a.balance)))
            .take(3)
            .toList()
        : const [];
    // Per supplier: what is still owed, and the date of the oldest unpaid
    // bill (the one to settle first). Two suppliers, oldest first.
    final owed = <String, (double, DateTime)>{};
    if (_can(user, 'view_purchases')) {
      for (final p in ref.watch(purchaseListProvider).purchases) {
        // Delivered bills only: an order still awaiting delivery is not
        // the first thing to pay.
        if (p.isFullyPaid || p.status == 'cancelled' || p.isPending) continue;
        final was = owed[p.supplierName];
        owed[p.supplierName] = (
          (was?.$1 ?? 0) + p.balance,
          was == null || p.createdAt.isBefore(was.$2) ? p.createdAt : was.$2,
        );
      }
    }
    final bills = (owed.entries.toList()
          ..sort((a, b) => a.value.$2.compareTo(b.value.$2)))
        .take(2)
        .toList();
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: Text(text.toUpperCase(),
              style: AppTheme.font(
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.iconMuted,
                  letterSpacing: 0.5)),
        );
    return [
      if (debtors.isNotEmpty) ...[
        const Divider(height: 24),
        label(l10n.owesYouMost),
        for (final c in debtors)
          _cashRow(
            leading: AppAvatar(c.name, size: 28, square: true),
            name: c.name,
            amount: c.balance,
            color: c.isOverCreditLimit
                ? AppColors.dangerText
                : AppColors.warningText,
            onTap: () => context.go('/customers'),
          ),
      ],
      if (bills.isNotEmpty) ...[
        const Divider(height: 24),
        label(l10n.suppliersToPayFirst),
        for (final b in bills)
          _cashRow(
            leading: AppAvatar(b.key, size: 28, square: true),
            name: b.key,
            sub: l10n.issuedOn(formatDate(b.value.$2)),
            amount: b.value.$1,
            color: AppColors.textPrimary,
            onTap: () => context.go('/purchases'),
          ),
      ],
    ];
  }

  Widget _cash(DashboardKpis k, AppLocalizations l10n) {
    final maxV = [k.receivables, k.payables, 1.0]
        .reduce((a, b) => a > b ? a : b);
    final net = k.receivables - k.payables;
    Widget line(String label, double value, Color color) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                  child: Text(label,
                      style: AppTheme.font(
                          size: 14, color: AppColors.textSecondary))),
              Text(formatDT(value), style: AppTheme.money),
            ]),
            const SizedBox(height: 8),
            AppMeter(value: value / maxV, color: color),
          ],
        );
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.cashPosition, style: AppTheme.sectionTitle),
          const SizedBox(height: 16),
          line(l10n.toCollect, k.receivables, AppColors.primary),
          const SizedBox(height: 14),
          line(l10n.statusToPay, k.payables, AppColors.warning),
          const Divider(height: 28),
          Row(children: [
            Expanded(
                child: Text(l10n.netPosition,
                    style: AppTheme.font(
                        size: 13,
                        weight: FontWeight.w500,
                        color: AppColors.textSecondary))),
            Text('${net >= 0 ? '+' : '−'}${formatDT(net.abs())}',
                style: AppTheme.heading(
                    size: 20,
                    tabularFigures: true,
                    color: net >= 0
                        ? AppColors.successText
                        : AppColors.dangerText)),
          ]),
          ..._cashDetails(l10n),
        ],
      ),
    );
  }

  // ── KPI row ──

  Widget _kpi({
    required Color dot,
    required String label,
    required String value,
    required String sub,
    VoidCallback? onTap,
    Color? valueColor,
    bool compact = false,
  }) {
    final body = Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.font(
                      size: 13,
                      weight: FontWeight.w500,
                      color: AppColors.textSecondary)),
            ),
          ]),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: compact
                    ? AppTheme.heading(
                        size: 19,
                        tabularFigures: true,
                        color: valueColor ?? AppColors.textPrimary)
                    : valueColor == null
                        ? AppTheme.kpi
                        : AppTheme.kpi.copyWith(color: valueColor)),
          ),
          const SizedBox(height: 4),
          Text(sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.label),
        ],
      ),
    );
    return AppPressable(
      onTap: onTap,
      semanticLabel: '$label $value',
      borderRadius: BorderRadius.circular(AppRadius.card),
      color: AppColors.surface,
      hoverColor: AppColors.surfaceAlt,
      child: body,
    );
  }

  List<Widget> _kpis(DashboardSummaryEntity s, UserEntity? user,
      AppLocalizations l10n) {
    final k = s.kpis;
    final (overdue, overdueSum) = _overdue(s);
    void go(String route, String permission) {
      if (_can(user, permission)) context.go(route);
    }

    return [
      // Stock value, not "To collect" again: the cash card above already
      // shows what customers owe.
      _kpi(
        dot: AppColors.primary,
        label: l10n.stockValue,
        value: formatDT(k.stockValue),
        sub: l10n.navGroupInventory,
        onTap: () => go('/products', 'view_products'),
      ),
      _kpi(
        dot: AppColors.danger,
        label: l10n.overdue,
        value: '$overdue',
        sub: overdue == 0
            ? l10n.overdueInvoices(0)
            : formatDT(overdueSum),
        onTap: () => go('/sales', 'view_sales'),
      ),
      _kpi(
        dot: AppColors.warning,
        // The API counts low AND out of stock together; say so, so the
        // number matches Products (Low stock 3 + Out of stock 1 = 4).
        label: l10n.toReorder,
        value: '${k.lowStockCount}',
        sub: l10n.lowOrOutOfStock,
        onTap: () => go('/products', 'view_products'),
      ),
      _kpi(
        dot: AppColors.success,
        label: l10n.salesThisMonth,
        value: '${k.salesCountThisMonth}',
        sub: formatDT(k.revenueThisMonth),
        onTap: () => go('/sales', 'view_sales'),
      ),
    ];
  }

  /// Phones: the four figures of the mobile board, 2×2: cash (in − out),
  /// overdue amount, stock value, products to reorder. The separate cash
  /// card is folded into the first tile.
  List<Widget> _phoneKpis(DashboardSummaryEntity s, UserEntity? user,
      AppLocalizations l10n) {
    final k = s.kpis;
    final (overdue, overdueSum) = _overdue(s);
    final net = k.receivables - k.payables;
    void go(String route, String permission) {
      if (_can(user, permission)) context.go(route);
    }

    return [
      _kpi(
        compact: true,
        dot: AppColors.success,
        label: l10n.cashPosition,
        // Signed and coloured like the web cash card: +green, −red.
        value: '${net >= 0 ? '+' : '−'}${formatDT(net.abs())}',
        valueColor: net >= 0 ? AppColors.successText : AppColors.dangerText,
        sub: l10n.netPosition,
      ),
      _kpi(
        compact: true,
        dot: AppColors.danger,
        label: l10n.overdue,
        value: formatDT(overdueSum),
        // Zero is not an alarm: neutral, like the summary strips.
        valueColor: overdue == 0 ? null : AppColors.dangerText,
        sub: l10n.overdueInvoices(overdue),
        onTap: () => go('/sales', 'view_sales'),
      ),
      _kpi(
        compact: true,
        dot: AppColors.primary,
        label: l10n.stockValue,
        value: formatDT(k.stockValue),
        sub: l10n.navGroupInventory,
        onTap: () => go('/products', 'view_products'),
      ),
      _kpi(
        compact: true,
        dot: AppColors.warning,
        label: l10n.toReorder,
        value: '${k.lowStockCount}',
        valueColor: k.lowStockCount == 0 ? null : AppColors.warningText,
        sub: l10n.lowOrOutOfStock,
        onTap: () => go('/products', 'view_products'),
      ),
    ];
  }

  /// Overdue invoices: the count and what is still owed on them. The
  /// notifications list has every overdue invoice; the summary's alert list
  /// stops at the 5 most overdue, so it is only the fallback (it made the
  /// card say 5 while the alerts said 8).
  (int, double) _overdue(DashboardSummaryEntity s) {
    final all = ref
        .watch(notificationProvider)
        .items
        .where((i) => i.type == NotificationType.overduePayment)
        .map((i) => i.value)
        .toList();
    final values = all.isNotEmpty
        ? all
        : [
            for (final a in s.alerts)
              if (a.type == AlertType.overduePayment) a.value,
          ];
    return (values.length, values.fold<double>(0, (t, v) => t + v));
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
            padding: const EdgeInsets.fromLTRB(20, 12, 10, 10),
            child: _cardTitle(title, action: action),
          ),
          if (rows.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              alignment: Alignment.center,
              child: Text(emptyText, style: AppTheme.label),
            )
          else
            for (var i = 0; i < rows.length; i++)
              AppEntrance(
                  index: i, stagger: AppMotion.stagger, offset: 6, child: rows[i]),
        ],
      ),
    );
  }

  Widget _listRow({
    Widget? leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final row = Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        if (leading != null) ...[leading, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTheme.font(size: 14, weight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTheme.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing],
      ]),
    );
    if (onTap == null) return row;
    return AppPressable(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      hoverColor: AppColors.surfaceAlt,
      child: row,
    );
  }

  Widget _activity(List<ActivityItem> items, UserEntity? user,
      AppLocalizations l10n) {
    final shown = items.take(6).toList();
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
              onPressed: () => context.go(seeAll), child: Text(l10n.seeAll)),
      emptyText: l10n.noActivity,
      rows: [
        for (final item in shown)
          _listRow(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.kind == 'sale'
                    ? AppColors.successSoft
                    : AppColors.fill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.kind == 'sale' ? Icons.south_west : Icons.north_east,
                size: 16,
                color: item.kind == 'sale'
                    ? AppColors.successText
                    : AppColors.iconMuted,
              ),
            ),
            title: item.label,
            subtitle:
                '${item.kind == 'sale' ? l10n.sale : l10n.purchase} · ${formatDateTime(item.createdAt)}',
            trailing: Text(
              formatSignedDT(item.amount, incoming: item.kind == 'sale'),
              style: AppTheme.font(
                size: 14,
                weight: FontWeight.w600,
                tabularFigures: true,
                color: item.kind == 'sale'
                    ? AppColors.successText
                    : AppColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _attention(NotificationState n, AppLocalizations l10n) {
    final shown = n.items.take(5).toList();
    return _listCard(
      title: l10n.needsAttention,
      action: n.count > shown.length
          ? TextButton(
              onPressed: () => openNotifications(context),
              child: Text(l10n.seeAll))
          : null,
      emptyText: l10n.allClear,
      rows: [
        for (final item in shown)
          _listRow(
            leading: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.severity == 'critical'
                    ? AppColors.danger
                    : item.severity == 'warning'
                        ? AppColors.warning
                        : AppColors.info,
                shape: BoxShape.circle,
              ),
            ),
            title: item.title,
            subtitle: notificationDetail(item, l10n),
            // Stock lines already say "7 left · minimum 20"; a figure on
            // the right would only repeat it. Amounts keep theirs.
            trailing: item.type == NotificationType.lowStock ||
                    item.type == NotificationType.outOfStock
                ? null
                : Text(notificationFigure(item),
                    style: AppTheme.font(
                        size: 13,
                        weight: FontWeight.w600,
                        tabularFigures: true)),
            onTap: () async {
              await openNotificationItem(context, item, l10n);
              if (mounted) _reload();
            },
          ),
      ],
    );
  }

  Widget _topProducts(List<TopProduct> products, AppLocalizations l10n) {
    final shown = products.take(5).toList();
    return _listCard(
      title: l10n.topProducts,
      action: TextButton(
          onPressed: () => context.go('/products'), child: Text(l10n.seeAll)),
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
            trailing: Text(formatDT(shown[i].revenue),
                style: AppTheme.font(
                    size: 14, weight: FontWeight.w500, tabularFigures: true)),
          ),
      ],
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authNotifierProvider.select((s) => s.user));
    final state = ref.watch(dashboardProvider);
    final notifications = ref.watch(notificationProvider);
    final reportState = ref.watch(reportProvider);
    final summary = state.summary;

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
    if (summary != null && !state.isLoading) {
      body = RefreshIndicator(
        onRefresh: _reload,
        child: LayoutBuilder(builder: (context, box) {
          final wide = box.maxWidth >= 840;
          const gap = SizedBox(height: 20, width: 20);
          final kpis = wide
              ? _kpis(summary, user, l10n)
              : _phoneKpis(summary, user, l10n);
          final hero = wide
              ? _hero(state, summary, l10n)
              : _phoneHero(state, summary, l10n);
          final cash = _cash(summary.kpis, l10n);

          final alerts = _alertStrip(notifications, l10n);
          final sections = <Widget>[
            // Alerts first: the owner sees what needs doing before anything
            // else.
            ?alerts,
            _header(user, reportState, l10n, wide),
            if (wide)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 2, child: hero),
                    gap,
                    Expanded(child: cash),
                  ],
                ),
              )
            else ...[hero, _phoneActions(user, reportState, l10n)],
            if (wide)
              Row(children: [
                for (var i = 0; i < kpis.length; i++) ...[
                  if (i > 0) gap,
                  Expanded(child: kpis[i]),
                ],
              ])
            else
              Column(children: [
                IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: kpis[0]),
                        const SizedBox(width: 10),
                        Expanded(child: kpis[1]),
                      ]),
                ),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: kpis[2]),
                        const SizedBox(width: 10),
                        Expanded(child: kpis[3]),
                      ]),
                ),
              ]),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 2,
                      child: _activity(summary.recentActivity, user, l10n)),
                  gap,
                  Expanded(
                    child: Column(children: [
                      _attention(notifications, l10n),
                      gap,
                      _topProducts(summary.topProducts, l10n),
                    ]),
                  ),
                ],
              )
            else ...[
              _attention(notifications, l10n),
              _activity(summary.recentActivity, user, l10n),
              _topProducts(summary.topProducts, l10n),
            ],
          ];

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
                horizontal: wide ? 32 : AppSpacing.page,
                vertical: wide ? 28 : 12),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < sections.length; i++) ...[
                        if (i > 0) SizedBox(height: wide ? 20 : 14),
                        AppEntrance(index: i, child: sections[i]),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      );
    } else if (state.error != null && !state.isLoading) {
      body = AppErrorState(
        title: l10n.loadFailedTitle,
        message: l10n.serverUnreachable,
        retryLabel: l10n.retry,
        onRetry: _reload,
      );
    } else {
      body = AppSkeletonList(rows: 5, semanticLabel: l10n.loading);
    }

    // Phones have no bar: the greeting header scrolls with the page, as on
    // the mobile board. Wide screens keep the company bar.
    final wideShell = AppShellScope.maybeOf(context)?.sidebarVisible ??
        MediaQuery.sizeOf(context).width >= 840;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: wideShell
          ? AppPageHeader(
              title: company,
              subtitle: who,
              icon: Icons.home_outlined,
              color: AppColors.primary,
            )
          : null,
      body: wideShell ? body : SafeArea(bottom: false, child: body),
    );
  }
}
