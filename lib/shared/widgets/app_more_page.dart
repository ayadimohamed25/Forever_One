import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/locale_provider.dart';
import '../../core/router/app_destinations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import 'app_drawer.dart'
    show confirmLogout, navGroupLabel, roleLabelFor;
import 'app_motion.dart';
import 'app_page_header.dart';
import 'app_pressable.dart';

/// The phone's More tab: everything that is not a bottom-bar tab, grouped
/// like the web sidebar (Purchasing, Inventory, Intelligence, Administration),
/// under the account card. Built from [appDestinations], so a user only sees
/// what they may open. Screens open ON TOP of the tabs (pushed), with Back.
class AppMorePage extends ConsumerWidget {
  const AppMorePage({super.key});

  /// Icon tile colours per group, as on the mobile board.
  static (Color, Color) _tint(NavGroup g) => switch (g) {
        NavGroup.sales => (AppColors.successSoft, AppColors.successText),
        NavGroup.purchasing => (const Color(0xFFFFF4ED), const Color(0xFFB93815)),
        NavGroup.inventory => (const Color(0xFFEFF8FF), const Color(0xFF175CD3)),
        NavGroup.intelligence => (AppColors.primarySoft, AppColors.primary),
        _ => (AppColors.fill, AppColors.icon),
      };

  static const _groups = [
    NavGroup.sales,
    NavGroup.purchasing,
    NavGroup.inventory,
    NavGroup.intelligence,
    NavGroup.admin,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authNotifierProvider.select((s) => s.user));
    final locale = ref.watch(localeProvider);

    final sections = <Widget>[
      if (user != null)
        _AccountCard(
          initials: user.initials,
          name: user.displayName,
          detail: [
            roleLabelFor(user.role, l10n),
            if (user.companyName.isNotEmpty) user.companyName,
          ].join(' · '),
          onTap: () => context.push('/profile'),
          semanticLabel: l10n.openProfile,
        ),
      for (final g in _groups)
        if (navItems(g, user).where((d) => !tabRoutes.contains(d.route))
            case final items when items.isNotEmpty)
          _Group(
            label: navGroupLabel(g, l10n),
            children: [
              for (final d in items)
                _Item(
                  icon: d.icon,
                  tint: _tint(g),
                  label: d.sidebarLabel(l10n),
                  onTap: () => context.push(d.route),
                ),
            ],
          ),
      _Group(
        label: l10n.settings,
        children: [
          _Item(
            icon: Icons.language_outlined,
            tint: _tint(NavGroup.admin),
            label: l10n.language,
            trailing: SegmentedButton<String>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: AppTheme.font(size: 13, weight: FontWeight.w600),
              ),
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'fr', label: Text('FR')),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (s) => ref
                  .read(localeProvider.notifier)
                  .setLocale(Locale(s.first)),
            ),
          ),
          _Item(
            icon: Icons.logout_outlined,
            tint: (AppColors.dangerSoft, AppColors.dangerText),
            label: l10n.logout,
            labelColor: AppColors.dangerText,
            chevron: false,
            onTap: () => confirmLogout(context, ref, l10n),
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: l10n.moreShort,
        icon: Icons.grid_view_outlined,
        color: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          for (var i = 0; i < sections.length; i++)
            AppEntrance(index: i, child: sections[i]),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String initials;
  final String name;
  final String detail;
  final VoidCallback onTap;
  final String semanticLabel;

  const _AccountCard({
    required this.initials,
    required this.name,
    required this.detail,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      color: AppColors.sidebar,
      hoverColor: AppColors.sidebarHover,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(initials,
                style: AppTheme.heading(size: 15, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        size: 15,
                        weight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        size: 12, color: AppColors.textOnInkMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.sidebarText),
        ]),
      ),
    );
  }
}

/// A labelled card of rows ("PURCHASING" over Purchases, Suppliers).
class _Group extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _Group({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 6),
          child: Semantics(
            header: true,
            child: Text(label.toUpperCase(),
                style: AppTheme.font(
                    size: 12,
                    weight: FontWeight.w600,
                    color: AppColors.iconMuted,
                    letterSpacing: 0.5)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Divider(
                    height: 1, indent: 54, color: Color(0xFFF0F1F4)),
              children[i],
            ],
          ]),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final (Color, Color) tint;
  final String label;
  final Color? labelColor;
  final Widget? trailing;
  final bool chevron;
  final VoidCallback? onTap;

  const _Item({
    required this.icon,
    required this.tint,
    required this.label,
    this.labelColor,
    this.trailing,
    this.chevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: tint.$1,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: tint.$2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: AppTheme.font(
                  size: 15,
                  weight: FontWeight.w500,
                  color: labelColor ?? AppColors.textPrimary)),
        ),
        ?trailing,
        if (onTap != null && chevron)
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
      ]),
    );
    if (onTap == null) return row;
    return AppPressable(
      onTap: onTap,
      semanticLabel: label,
      borderRadius: BorderRadius.zero,
      hoverColor: AppColors.surfaceAlt,
      child: row,
    );
  }
}
