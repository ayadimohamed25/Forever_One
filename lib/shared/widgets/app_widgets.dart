import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

// ═════════════════════════ Status ═════════════════════════

/// Status tones. Neutral is only for counts or information with no status.
enum BadgeTone { success, warning, danger, neutral, accent }

/// Foreground / background pair for a tone.
({Color fg, Color bg}) badgeColors(BadgeTone tone) {
  switch (tone) {
    case BadgeTone.success:
      return (fg: AppColors.success, bg: AppColors.successSoft);
    case BadgeTone.warning:
      return (fg: AppColors.warning, bg: AppColors.warningSoft);
    case BadgeTone.danger:
      return (fg: AppColors.danger, bg: AppColors.dangerSoft);
    case BadgeTone.accent:
      return (fg: AppColors.accent, bg: AppColors.accentSoft);
    case BadgeTone.neutral:
      return (fg: AppColors.black, bg: AppColors.neutralSoft);
  }
}

/// Maps a colour argument onto a tone, so call sites that pass
/// AppColors.success / warning / danger / accent keep their meaning.
BadgeTone toneForColor(Color color) {
  if (color == AppColors.success) return BadgeTone.success;
  if (color == AppColors.warning) return BadgeTone.warning;
  if (color == AppColors.danger) return BadgeTone.danger;
  if (color == AppColors.accent) return BadgeTone.accent;
  return BadgeTone.neutral;
}

/// Fully rounded status pill.
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
      padding: EdgeInsets.symmetric(horizontal: icon != null ? 9 : 11, vertical: 5),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(100),
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
            style: AppTheme.font(size: 12, weight: FontWeight.w600, color: c.fg),
          ),
        ],
      ),
    );
  }
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
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTheme.font(size: 12, weight: FontWeight.w600, color: Colors.white),
        ),
      );
    }
    return AppBadge(label: label, tone: toneForColor(color), icon: icon);
  }
}

// ═════════════════════════ Cards & tiles ═════════════════════════

/// White card, radius 22, soft shadow. No side stripe.
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
    this.margin = const EdgeInsets.only(bottom: 12),
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
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
        borderRadius: BorderRadius.circular(size * 0.3),
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

/// Initials tile — accentSoft background, terracotta text.
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

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.font(size: 20, weight: FontWeight.w600, letterSpacing: -0.4),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTheme.font(size: 15, height: 1.45, color: AppColors.textSecondary),
              ),
            ],
          ],
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
            style: AppTheme.font(size: 15, weight: FontWeight.w600, color: color, tabularFigures: true)),
        const SizedBox(height: 3),
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
          if (i > 0) Text('·', style: AppTheme.font(size: 13, color: AppColors.textMuted)),
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
          padding: EdgeInsets.only(top: 16, bottom: 14),
          child: Divider(height: 1),
        ),
        Row(children: children),
      ],
    );
  }
}

// ═════════════════════════ Forms & detail pages ═════════════════════════

/// Optional title over a white card holding a vertical list of children.
class AppFormSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets padding;
  final double spacing;

  const AppFormSection({
    super.key,
    this.title,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(title!, style: AppTheme.font(size: 16, weight: FontWeight.w600)),
          ),
        Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                children[i],
              ],
            ],
          ),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.iconMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.label),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTheme.font(size: 15, color: valueColor ?? AppColors.textPrimary)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Text field with the app's styling. One per row in every form.
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

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
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      autofocus: autofocus,
      onChanged: onChanged,
      style: AppTheme.font(size: 15),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixText: suffix,
        suffixStyle: AppTheme.font(size: 14, color: AppColors.textSecondary),
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
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      style: AppTheme.font(size: 15),
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      icon: const Icon(Icons.expand_more, color: AppColors.iconMuted),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}

/// Pill segmented control: selected option in dark ink with white text.
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                  decoration: BoxDecoration(
                    color: o.value == selected ? AppColors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (o.icon != null) ...[
                        Icon(o.icon,
                            size: 16,
                            color: o.value == selected ? Colors.white : AppColors.textSecondary),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          o.label,
                          textAlign: TextAlign.center,
                          style: AppTheme.font(
                            size: 13,
                            weight: o.value == selected ? FontWeight.w600 : FontWeight.w500,
                            color: o.value == selected ? Colors.white : AppColors.textSecondary,
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
class AppBottomActionBar extends StatelessWidget {
  final Widget child;

  const AppBottomActionBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: AppColors.canvas,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: child,
      ),
    );
  }
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
                  style: AppTheme.font(size: 15, color: _color(actions[i])),
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