import 'package:flutter/material.dart';
import '../../core/utils/reduced_motion.dart';

/// Motion rules for the whole app: one place decides whether to animate and
/// how long things take. Every animated widget asks [AppMotion.enabled] and
/// shows its final state at once when motion is off (OS "reduce motion",
/// browser `prefers-reduced-motion`, or tests that disable animations).
class AppMotion {
  AppMotion._();

  static const fast = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 450);
  static const chart = Duration(milliseconds: 1400);
  static const curve = Cubic(0.2, 0.7, 0.2, 1);

  /// Delay between staggered items, and how many items get their own delay
  /// (later ones appear together so long lists never feel slow).
  static const stagger = Duration(milliseconds: 40);
  static const maxStaggered = 12;

  static bool enabled(BuildContext context) =>
      !(MediaQuery.maybeDisableAnimationsOf(context) ?? false) &&
      !platformPrefersReducedMotion();

  /// [d] when motion is on, zero otherwise.
  static Duration of(BuildContext context, Duration d) =>
      enabled(context) ? d : Duration.zero;
}

/// Fades and lifts its child into place once, when first built. [index]
/// staggers siblings (a page's sections, a table's rows).
class AppEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final double offset;
  final Duration? stagger;

  /// Read once, when the widget first appears: false shows the child at once
  /// (a table row scrolled back into view must not fade in again).
  final bool animate;

  const AppEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 10,
    this.stagger,
    this.animate = true,
  });

  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null || !widget.animate || !AppMotion.enabled(context)) return;
    final step = widget.stagger ?? const Duration(milliseconds: 60);
    final i = widget.index.clamp(0, AppMotion.maxStaggered);
    final delay = step * i;
    _c = AnimationController(vsync: this, duration: AppMotion.slow + delay);
    _c!.forward();
    _delayFraction = delay.inMicroseconds / _c!.duration!.inMicroseconds;
  }

  double _delayFraction = 0;

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.child;
    final t = CurvedAnimation(
      parent: c,
      curve: Interval(_delayFraction, 1, curve: AppMotion.curve),
    );
    return AnimatedBuilder(
      animation: t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: t.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - t.value)),
          child: child,
        ),
      ),
    );
  }
}

/// A horizontal bar that grows to [value] (0–1) from the left.
class AppMeter extends StatelessWidget {
  final double value;
  final Color color;
  final Color track;
  final double height;

  const AppMeter({
    super.key,
    required this.value,
    required this.color,
    this.track = const Color(0xFFF2F4F7),
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: ColoredBox(
          color: track,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: v),
              duration: AppMotion.of(context, const Duration(milliseconds: 900)),
              curve: AppMotion.curve,
              builder: (context, w, _) => FractionallySizedBox(
                widthFactor: w,
                heightFactor: 1,
                child: ColoredBox(color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Switches between section pages with a short fade and 4px rise, keyed on
/// [switchKey] (the active destination). Sections themselves have no route
/// transition (NoTransitionPage / indexedStack), so this is the one place
/// page navigation animates. The child is never remounted: only the
/// animation restarts, so each section keeps its state and scroll position.
class AppSectionSwitcher extends StatefulWidget {
  final Object? switchKey;
  final Widget child;

  const AppSectionSwitcher(
      {super.key, required this.switchKey, required this.child});

  @override
  State<AppSectionSwitcher> createState() => _AppSectionSwitcherState();
}

class _AppSectionSwitcherState extends State<AppSectionSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: AppMotion.fast, value: 1);

  @override
  void didUpdateWidget(AppSectionSwitcher old) {
    super.didUpdateWidget(old);
    if (old.switchKey != widget.switchKey && AppMotion.enabled(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        // Always the same wrapper shape: swapping it in and out would
        // remount the page underneath.
        final t = Curves.easeOut.transform(_c.value);
        return Opacity(
          opacity: t,
          child:
              Transform.translate(offset: Offset(0, 4 * (1 - t)), child: child),
        );
      },
    );
  }
}
