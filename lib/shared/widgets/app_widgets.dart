import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'app_pressable.dart';

// ═════════════════════════ Status ═════════════════════════

/// Status tones. Neutral is only for counts or information with no status.
enum BadgeTone { success, warning, danger, neutral, accent }

/// Foreground / background pair for a tone.
({Color fg, Color bg}) badgeColors(BadgeTone tone) {
  switch (tone) {
    case BadgeTone.success:
      return (fg: AppColors.successText, bg: AppColors.successSoft);
    case BadgeTone.warning:
      return (fg: AppColors.warningText, bg: AppColors.warningSoft);
    case BadgeTone.danger:
      return (fg: AppColors.dangerText, bg: AppColors.dangerSoft);
    case BadgeTone.accent:
      return (fg: AppColors.primary, bg: AppColors.primarySoft);
    case BadgeTone.neutral:
      return (fg: AppColors.textLabel, bg: AppColors.neutralSoft);
  }
}

/// Maps a colour argument onto a tone, so call sites that pass
/// AppColors.success / warning / danger / accent keep their meaning.
BadgeTone toneForColor(Color color) {
  if (color == AppColors.success || color == AppColors.successText) {
    return BadgeTone.success;
  }
  if (color == AppColors.warning || color == AppColors.warningText) {
    return BadgeTone.warning;
  }
  if (color == AppColors.danger || color == AppColors.dangerText) {
    return BadgeTone.danger;
  }
  if (color == AppColors.accent) return BadgeTone.accent;
  return BadgeTone.neutral;
}

/// Status chip: radius 6, 12px medium text, tinted background.
/// Labels are always sentence case ("Partially paid"); see [statusLabel].
class AppBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = badgeColors(tone);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon != null ? 6 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c.fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTheme.font(size: 12, weight: FontWeight.w500, color: c.fg),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// One capitalisation everywhere: "partially paid" / "PAID" → "Partially paid".
String statusLabel(String raw) {
  final t = raw.trim().replaceAll('_', ' ');
  if (t.isEmpty) return t;
  final lower = t.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}

/// Legacy status pill. Honours the semantic colour it is given.
class AppStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool solid;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    if (solid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Text(
          label,
          style: AppTheme.font(size: 12, weight: FontWeight.w500, color: Colors.white),
        ),
      );
    }
    return AppBadge(label: label, tone: toneForColor(color), icon: icon);
  }
}

// ═════════════════════════ Cards & tiles ═════════════════════════

/// White card: radius 12, 1px border, no shadow. Cards sit 12 apart.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets margin;

  /// No longer drawn — kept so existing call sites compile.
  final Color? accentColor;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: AppSpacing.gap),
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The 40×40 leading element of every list row: initials, an icon, or a
/// number, on a soft tinted square.
class AppLeadingTile extends StatelessWidget {
  final String? name;
  final IconData? icon;
  final String? value;
  final BadgeTone tone;
  final double size;

  const AppLeadingTile.initials(String this.name, {super.key, this.size = 40})
      : icon = null,
        value = null,
        tone = BadgeTone.accent;

  const AppLeadingTile.icon(
      IconData this.icon, {
        super.key,
        this.tone = BadgeTone.accent,
        this.size = 40,
      })  : name = null,
        value = null;

  const AppLeadingTile.value(
      String this.value, {
        super.key,
        required this.tone,
        this.size = 40,
      })  : name = null,
        icon = null;

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = badgeColors(tone);

    final Widget content;
    if (icon != null) {
      content = Icon(icon, size: size * 0.5, color: c.fg);
    } else {
      content = FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            value ?? initialsOf(name ?? ''),
            style: AppTheme.font(
              size: size * 0.38,
              weight: FontWeight.w700,
              color: c.fg,
              tabularFigures: value != null,
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      alignment: Alignment.center,
      child: content,
    );
  }
}

/// A plain outline icon, kept for screens not yet on [AppLeadingTile].
class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool solid;

  const AppIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) =>
      AppLeadingTile.icon(icon, size: size);
}

/// Initials tile — soft blue background, blue text.
class AppInitialsBadge extends StatelessWidget {
  final String name;
  final Color color;
  final double size;

  const AppInitialsBadge({
    super.key,
    required this.name,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) =>
      AppLeadingTile.initials(name, size: size);
}

/// A number on a tinted square; the colour passed sets the tone.
class AppValueBadge extends StatelessWidget {
  final String value;
  final Color color;
  final double size;
  final String? caption;

  const AppValueBadge({
    super.key,
    required this.value,
    required this.color,
    this.size = 40,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final c = badgeColors(toneForColor(color));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                value,
                style: AppTheme.font(
                  size: caption == null ? 15 : 14,
                  weight: FontWeight.w700,
                  color: c.fg,
                  height: 1,
                  tabularFigures: true,
                ),
              ),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(caption!,
                style: AppTheme.font(size: 8, weight: FontWeight.w600, color: c.fg)),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════ Text blocks ═════════════════════════

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;

  /// Optional call to action under the text, e.g. "New customer".
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.iconMuted),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.font(size: 16, weight: FontWeight.w600),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTheme.font(size: 14, height: 1.45, color: AppColors.textSecondary),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 20),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A screen whose data failed to load: what happened, and a way to retry.
/// Use instead of an empty state or an endless spinner when a load fails, so
/// a network error is never shown as "nothing here".
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_outlined,
                  size: 28, color: AppColors.danger),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.font(
                  size: 16, weight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.font(
                    size: 14, height: 1.45, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder rows while a list loads: white cards that mirror a real row
/// (leading tile, two text lines, trailing stub), gently pulsing.
/// Appears only after 200 ms so fast loads don't flash, and stays still when
/// the platform asks for reduced motion.
class AppSkeletonList extends StatefulWidget {
  final int rows;
  final EdgeInsets padding;
  final String semanticLabel;

  const AppSkeletonList({
    super.key,
    this.rows = 6,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 20),
    this.semanticLabel = 'Loading',
  });

  @override
  State<AppSkeletonList> createState() => _AppSkeletonListState();
}

class _AppSkeletonListState extends State<AppSkeletonList>
    with SingleTickerProviderStateMixin {
  // Created in initState, never lazily: a lazy controller would first be
  // built in dispose() when the list disappears within 200 ms, which crashes.
  late final AnimationController _pulse;
  bool _visible = false;

  static const _low = Color(0xFFF2F4F7);
  static const _high = Color(0xFFE4E7EC);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _visible = true);
      final reduceMotion =
          MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      if (!reduceMotion) _pulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Widget _block(double width, double height, Color color,
          {double radius = 6}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Semantics(
      label: widget.semanticLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final c = Color.lerp(_low, _high, _pulse.value)!;
            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: widget.padding,
              itemCount: widget.rows,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _block(36, 36, c, radius: 8),
                    const SizedBox(width: 14),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, box) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _block(box.maxWidth * 0.6, 12, c),
                            const SizedBox(height: 8),
                            _block(box.maxWidth * 0.35, 10, c),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _block(48, 14, c),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Value over a small gray label, right-aligned in list rows.
class AppTrailingStat extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const AppTrailingStat({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final tone = toneForColor(valueColor);
    final color = tone == BadgeTone.neutral ? AppColors.textPrimary : badgeColors(tone).fg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: AppTheme.font(size: 14, weight: FontWeight.w600, color: color, tabularFigures: true)),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.label),
      ],
    );
  }
}

/// Icon + text pairs separated by a dot, used for row subtitles.
class AppMetaRow extends StatelessWidget {
  final List<({IconData icon, String text})> items;

  const AppMetaRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) Text('·', style: AppTheme.font(size: 12, color: AppColors.textSecondary)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(items[i].icon, size: 14, color: AppColors.iconMuted),
              const SizedBox(width: 5),
              Text(items[i].text, style: AppTheme.label),
            ],
          ),
        ],
      ],
    );
  }
}

/// A divided strip under a card's main row for secondary detail.
class AppCardFooter extends StatelessWidget {
  final Color color;
  final List<Widget> children;

  const AppCardFooter({super.key, required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 12),
          child: Divider(height: 1),
        ),
        Row(children: children),
      ],
    );
  }
}

// ═════════════════════════ Forms & detail pages ═════════════════════════

/// A form or detail section: section title and content in ONE flat white
/// card (no card inside a card, no tinted field inside a white card).
class AppFormSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets padding;
  final double spacing;

  /// Optional widget at the right of the title (an action, a count).
  final Widget? trailing;

  const AppFormSection({
    super.key,
    this.title,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 14,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // A Material (not a coloured DecoratedBox) paints the white card, so
    // ListTiles / SwitchListTiles inside can draw their ink on it. With a
    // DecoratedBox they raise "ListTile background color or ink splashes may
    // be invisible" in debug builds.
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.gap),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(child: Text(title!, style: AppTheme.sectionTitle)),
                    ?trailing,
                  ],
                ),
                SizedBox(height: spacing),
              ],
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Label over value, with an outline icon, for detail pages.
class AppInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const AppInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // Label on the left, value on the right, thin divider below: the
    // detail-page row of business software.
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.iconMuted),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(label,
                style: AppTheme.font(size: 13, color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTheme.font(
                  size: 14,
                  weight: FontWeight.w500,
                  color: valueColor == null
                      ? AppColors.textPrimary
                      : AppColors.textOn(valueColor!)),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
    );
  }
}

/// A field label above its field (13px medium), with an optional
/// required mark. Use it to put any input under a label.
class AppLabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool required;

  const AppLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(text: label),
            if (required)
              TextSpan(
                  text: ' *',
                  style: AppTheme.font(
                      size: 13,
                      weight: FontWeight.w500,
                      color: AppColors.dangerText)),
          ]),
          style: AppTheme.fieldLabel,
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Text field with the app's styling: label above, white bordered field,
/// 48 high. One per row in every form (or two side by side in a Row).
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool required;
  final String? hint;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.suffix,
    this.onChanged,
    this.autofocus = false,
    this.required = false,
    this.hint,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return AppLabeledField(
      label: label,
      required: required,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        autofocus: autofocus,
        onChanged: onChanged,
        style: AppTheme.font(size: 14),
        decoration: InputDecoration(
          hintText: hint,
          errorText: errorText,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          suffixText: suffix,
          suffixStyle: AppTheme.font(size: 14, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

/// Dropdown with the app's styling. Give it a key that changes when its
/// items load, so the initial value is re-applied once the list arrives.
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const AppDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppLabeledField(
      label: label,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        items: items,
        onChanged: onChanged,
        style: AppTheme.font(size: 14),
        dropdownColor: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.control),
        icon: const Icon(Icons.expand_more, color: AppColors.iconMuted),
        decoration: InputDecoration(prefixIcon: Icon(icon, size: 20)),
      ),
    );
  }
}

/// Segmented control: bordered group, selected segment on a light blue fill.
class AppSegmentedControl<T> extends StatelessWidget {
  final List<({T value, String label, IconData? icon})> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const AppSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.fieldBorder),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: AppPressable(
                onTap: () => onChanged(o.value),
                selected: o.value == selected,
                borderRadius: BorderRadius.circular(8),
                semanticLabel: o.label,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                  decoration: BoxDecoration(
                    color: o.value == selected ? AppColors.primarySoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (o.icon != null) ...[
                        Icon(o.icon,
                            size: 16,
                            color: o.value == selected ? AppColors.primary : AppColors.textSecondary),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          o.label,
                          textAlign: TextAlign.center,
                          style: AppTheme.font(
                            size: 13,
                            weight: o.value == selected ? FontWeight.w600 : FontWeight.w500,
                            color: o.value == selected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom bar holding the primary action of a full-page form.
/// Below 840px the action spans the width (thumb reach); from 840px it sits
/// at the right, up to 320 wide, like a desktop dialog's primary button.
class AppBottomActionBar extends StatelessWidget {
  final Widget child;

  const AppBottomActionBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: wide
            // heightFactor: 1 keeps the bar as tall as the button. Without it
            // an Align in bottomNavigationBar grows to the whole window and
            // hides the form (blank page with only Save on the right).
            ? Align(
                alignment: Alignment.centerRight,
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 200, maxWidth: 320),
                  child: SizedBox(height: 48, child: child),
                ),
              )
            : SizedBox(width: double.infinity, height: 48, child: child),
      ),
    );
  }
}

/// A primary or secondary button that fills the width of its column, 48
/// high. The theme's buttons size to their label (min 88×48); use this where
/// a form's main action should span the form.
class AppBlockButton extends StatelessWidget {
  final Widget child;
  final double height;

  const AppBlockButton({super.key, required this.child, this.height = 48});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: double.infinity, height: height, child: child);
}

// ═════════════════════════ Row menu ═════════════════════════

class AppMenuAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;
  final Color? color;

  const AppMenuAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.destructive = false,
    this.color,
  });
}

/// The ⋮ menu at the end of a list row.
class AppRowMenu extends StatelessWidget {
  final List<AppMenuAction> actions;

  const AppRowMenu({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert, size: 20, color: AppColors.iconMuted),
      onSelected: (i) => actions[i].onTap(),
      itemBuilder: (context) => [
        for (var i = 0; i < actions.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                Icon(actions[i].icon,
                    size: 18, color: _color(actions[i], icon: true)),
                const SizedBox(width: 12),
                Text(
                  actions[i].label,
                  style: AppTheme.font(size: 14, color: _color(actions[i])),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _color(AppMenuAction a, {bool icon = false}) {
    if (a.color != null) return a.color!;
    if (a.destructive) return AppColors.danger;
    return icon ? AppColors.icon : AppColors.textPrimary;
  }
}