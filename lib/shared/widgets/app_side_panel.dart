import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import '../../core/errors/failures.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'app_motion.dart';

/// The detail panel beside a table on wide screens: one white bordered card
/// that scrolls on its own, with a close button.
class AppSidePanel extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;
  final String closeLabel;

  const AppSidePanel({
    super.key,
    required this.child,
    required this.onClose,
    required this.closeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: child,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              tooltip: closeLabel,
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 20, color: AppColors.iconMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small grey figure tile (Balance, Orders…).
class AppStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const AppStatTile(
      {super.key, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                  size: 12,
                  weight: FontWeight.w500,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: AppTheme.heading(
                    size: 18,
                    tabularFigures: true,
                    color: color ?? AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

/// A titled block inside a panel or detail page.
class AppPanelSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const AppPanelSection(
      {super.key, required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Text(title,
                  style: AppTheme.font(
                      size: 13,
                      weight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ),
            ?trailing,
          ]),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Bars per month that grow from the bottom one after another; the last bar
/// (the current month) is in the primary colour.
class AppMonthBars extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double height;
  final String semanticLabel;

  const AppMonthBars({
    super.key,
    required this.values,
    required this.labels,
    required this.semanticLabel,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final maxV = values.fold<double>(0, (m, v) => v > m ? v : m);
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < values.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                            begin: 0,
                            end: maxV <= 0 ? 0 : values[i] / maxV),
                        duration: AppMotion.of(
                            context,
                            const Duration(milliseconds: 700) +
                                AppMotion.stagger * i),
                        curve: AppMotion.curve,
                        builder: (context, f, _) => Container(
                          height: values[i] <= 0 ? 2 : (height * f).clamp(2, height),
                          decoration: BoxDecoration(
                            color: i == values.length - 1
                                ? AppColors.primary
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < labels.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: Text(labels[i],
                        textAlign: TextAlign.center,
                        style: AppTheme.font(
                            size: 11, color: AppColors.textSecondary)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Totals per calendar month for the last [count] months, oldest first,
/// ending with the current month.
({List<double> values, List<DateTime> months}) lastMonths(
  Iterable<(DateTime, double)> entries, {
  int count = 6,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final months = [
    for (var i = count - 1; i >= 0; i--) DateTime(today.year, today.month - i),
  ];
  final values = List<double>.filled(count, 0);
  for (final (date, amount) in entries) {
    for (var i = 0; i < count; i++) {
      if (date.year == months[i].year && date.month == months[i].month) {
        values[i] += amount;
      }
    }
  }
  return (values: values, months: months);
}

/// Grey placeholder blocks while a panel loads.
class AppPanelSkeleton extends StatelessWidget {
  const AppPanelSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget block(double w, double h) => Container(
          width: w,
          height: h,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(8),
          ),
        );
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  color: AppColors.fill, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(child: block(double.infinity, 18)),
          ]),
          const SizedBox(height: 16),
          block(double.infinity, 64),
          block(double.infinity, 10),
          block(double.infinity, 90),
          block(220, 14),
          block(260, 14),
        ],
      ),
    );
  }
}

/// A panel that could not load: the reason and a Retry button.
class AppPanelError extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const AppPanelError({
    super.key,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(height: 8),
          Text(message, style: AppTheme.body),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}

/// Loads one record for a side panel and shows it: skeleton while loading,
/// an error with Retry on failure, then [builder]. The latest [id] always
/// wins: an answer for a row selected earlier is dropped.
class AppDetailLoader<T> extends StatefulWidget {
  final String id;
  final Future<Either<Failure, T>> Function(String id) load;
  final Widget Function(T value) builder;
  final String Function(String? code) errorMessage;
  final String retryLabel;

  const AppDetailLoader({
    super.key,
    required this.id,
    required this.load,
    required this.builder,
    required this.errorMessage,
    required this.retryLabel,
  });

  @override
  State<AppDetailLoader<T>> createState() => _AppDetailLoaderState<T>();
}

class _AppDetailLoaderState<T> extends State<AppDetailLoader<T>> {
  int _seq = 0;
  T? _value;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(AppDetailLoader<T> old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) _fetch();
  }

  Future<void> _fetch() async {
    final seq = ++_seq;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.load(widget.id);
    if (!mounted || seq != _seq) return;
    setState(() {
      _loading = false;
      result.fold((f) {
        _error = f.message;
        _value = null;
      }, (v) => _value = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const AppPanelSkeleton();
    final value = _value;
    if (value == null) {
      return AppPanelError(
        message: widget.errorMessage(_error),
        retryLabel: widget.retryLabel,
        onRetry: _fetch,
      );
    }
    return widget.builder(value);
  }
}
