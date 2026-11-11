import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A tappable surface with a keyboard focus ring.
///
/// Replaces bare GestureDetector / InkWell controls so every control can be
/// reached with Tab and shows where focus is. The ring is a 2px accent outline
/// drawn 2px outside the widget, only for keyboard focus (not on touch), and
/// it is painted outside any clip so cards don't cut it off.
class AppPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  /// Fill behind the child (for selected/hover states); transparent if null.
  final Color? color;
  final Color? hoverColor;
  final String? semanticLabel;
  final bool selected;

  const AppPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.color,
    this.hoverColor,
    this.semanticLabel,
    this.selected = false,
  });

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final keyboard =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final showRing = _focused && keyboard;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final ringRadius = widget.borderRadius.add(BorderRadius.circular(4));

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: widget.color ?? Colors.transparent,
            borderRadius: widget.borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onFocusChange: (f) => setState(() => _focused = f),
              hoverColor: widget.hoverColor ?? AppColors.fill,
              focusColor: Colors.transparent,
              child: widget.child,
            ),
          ),
          Positioned(
            left: -4,
            top: -4,
            right: -4,
            bottom: -4,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: showRing ? 1 : 0,
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 120),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: ringRadius,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
