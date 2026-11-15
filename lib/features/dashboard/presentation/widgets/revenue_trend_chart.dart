import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_motion.dart';
import '../../domain/entities/dashboard_summary_entity.dart';

/// Revenue over the chosen period as a line with a soft area, the previous
/// period of the same length as a dashed line, and the latest point marked.
///
/// Motion (skipped with reduced motion): the line draws in from the left,
/// then the latest point pulses three times. A new period replays it.
class RevenueTrendChart extends StatefulWidget {
  final List<SalesTrendPoint> current;
  final List<SalesTrendPoint> previous;

  /// 365 = monthly points (month labels); otherwise daily.
  final int trendDays;
  final double height;

  const RevenueTrendChart({
    super.key,
    required this.current,
    required this.previous,
    required this.trendDays,
    this.height = 200,
  });

  @override
  State<RevenueTrendChart> createState() => _RevenueTrendChartState();
}

class _RevenueTrendChartState extends State<RevenueTrendChart>
    with TickerProviderStateMixin {
  late final AnimationController _draw =
      AnimationController(vsync: this, duration: AppMotion.chart);
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600));
  int _pulses = 0;

  @override
  void initState() {
    super.initState();
    _pulse.addStatusListener((s) {
      // Three pulses, then rest: never an endless animation.
      if (s == AnimationStatus.completed && ++_pulses < 3) {
        _pulse.forward(from: 0);
      }
    });
    _draw.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        _pulses = 0;
        _pulse.forward(from: 0);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _start();
  }

  @override
  void didUpdateWidget(RevenueTrendChart old) {
    super.didUpdateWidget(old);
    if (old.trendDays != widget.trendDays ||
        !identical(old.current, widget.current)) {
      _start();
    }
  }

  void _start() {
    if (!AppMotion.enabled(context)) {
      _draw.value = 1;
      _pulse.value = 1;
      return;
    }
    _draw.forward(from: 0);
  }

  @override
  void dispose() {
    _draw.dispose();
    _pulse.dispose();
    super.dispose();
  }

  String _label(DateTime d, String locale) => widget.trendDays == 365
      ? DateFormat.MMM(locale).format(d)
      : '${d.day}/${d.month}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final cur = widget.current;
    final prev = widget.previous;
    final total = cur.fold<double>(0, (s, p) => s + p.revenue);
    final hasData = cur.any((p) => p.revenue > 0);

    if (cur.isEmpty || !hasData) {
      return SizedBox(
        height: widget.height,
        child: Center(
            child: Text(l10n.noSalesInPeriod, style: AppTheme.label)),
      );
    }

    final peak = [
      ...cur.map((p) => p.revenue),
      ...prev.map((p) => p.revenue),
    ].fold<double>(0, (m, v) => v > m ? v : m);
    final maxY = peak <= 0 ? 1.0 : peak * 1.15;
    final last = cur.length - 1;
    // About five labels whatever the period length.
    final step = (cur.length / 5).ceil().clamp(1, 1000);
    final showPrev = prev.isNotEmpty && prev.any((p) => p.revenue > 0);

    LineChartData data(double pulse) => LineChartData(
          minX: 0,
          maxX: last.toDouble().clamp(1, double.infinity),
          minY: 0,
          maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (value != i.toDouble() ||
                      i < 0 ||
                      i > last ||
                      (last - i) % step != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_label(cur[i].day, locale),
                        style: AppTheme.font(
                            size: 11,
                            color: AppColors.textSecondary,
                            tabularFigures: true)),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.black,
              tooltipRoundedRadius: 8,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  s.barIndex == 0
                      ? LineTooltipItem(
                          '${_label(cur[s.x.round()].day, locale)}\n',
                          AppTheme.font(
                              size: 11, color: AppColors.textOnInkMuted),
                          children: [
                            TextSpan(
                              text: formatDT(s.y),
                              style: AppTheme.font(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: Colors.white,
                                  tabularFigures: true),
                            ),
                          ],
                        )
                      : null,
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < cur.length; i++)
                  FlSpot(i.toDouble(), cur[i].revenue),
              ],
              isCurved: true,
              curveSmoothness: 0.25,
              preventCurveOverShooting: true,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, _) => spot.x == last.toDouble(),
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2 + 8 * pulse,
                  strokeColor: AppColors.primary
                      .withValues(alpha: 0.35 * (1 - pulse)),
                ),
              ),
            ),
            if (showPrev)
              LineChartBarData(
                spots: [
                  for (var i = 0; i < prev.length && i < cur.length; i++)
                    FlSpot(i.toDouble(), prev[i].revenue),
                ],
                isCurved: true,
                curveSmoothness: 0.25,
                preventCurveOverShooting: true,
                color: AppColors.textMuted,
                barWidth: 1.5,
                dashArray: const [4, 4],
                dotData: const FlDotData(show: false),
              ),
          ],
        );

    return Semantics(
      label: l10n.revenueTrendLabel(formatDT(total)),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: widget.height,
              child: AnimatedBuilder(
                animation: Listenable.merge([_draw, _pulse]),
                builder: (context, _) {
                  final t = AppMotion.curve.transform(_draw.value);
                  final pulse = _pulse.isAnimating ? _pulse.value : 1.0;
                  return ClipRect(
                    clipper: _RevealClipper(t),
                    child: LineChart(data(pulse), duration: Duration.zero),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 18, runSpacing: 4, children: [
              _legend(AppColors.primary, l10n.thisPeriod, dashed: false),
              if (showPrev)
                _legend(AppColors.textMuted, l10n.previousPeriod, dashed: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label, {required bool dashed}) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 16,
        height: 2,
        child: dashed
            ? Row(children: [
                Expanded(child: ColoredBox(color: color)),
                const SizedBox(width: 3),
                Expanded(child: ColoredBox(color: color)),
              ])
            : ColoredBox(color: color),
      ),
      const SizedBox(width: 6),
      Text(label,
          style: AppTheme.font(size: 12, color: AppColors.textSecondary)),
    ]);
  }
}

/// Shows the left [fraction] of the chart: the line "draws" from the left.
class _RevealClipper extends CustomClipper<Rect> {
  final double fraction;
  const _RevealClipper(this.fraction);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction.clamp(0, 1), size.height + 40);

  @override
  bool shouldReclip(_RevealClipper old) => old.fraction != fraction;
}
