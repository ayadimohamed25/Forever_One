import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/locale_provider.dart';
import '../../core/di/sidebar_provider.dart';
import '../../core/router/app_destinations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import 'app_motion.dart';
import 'app_pressable.dart';

String roleLabelFor(String role, AppLocalizations l10n) {
  switch (role) {
    case 'admin':
      return l10n.roleAdmin;
    case 'finance':
      return l10n.roleFinance;
    case 'stock':
      return l10n.roleStock;
    case 'commercial':
      return l10n.roleCommercial;
    case 'employee':
      return l10n.roleEmployee;
    case 'auditor':
      return l10n.roleAuditor;
    default:
      return role;
  }
}

Future<void> confirmLogout(
    BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.logoutConfirmTitle),
      content: Text(l10n.logoutConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: Text(l10n.logout),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  // Clearing the auth state makes the router redirect to /login.
  await ref.read(authNotifierProvider.notifier).logout();
}

/// The groups shown as collapsible sections, in sidebar order. Overview items
/// sit above them; Account items live in the account block.
const _collapsibleGroups = [
  NavGroup.sales,
  NavGroup.purchasing,
  NavGroup.inventory,
  NavGroup.intelligence,
  NavGroup.admin,
];

IconData navGroupIcon(NavGroup g) {
  switch (g) {
    case NavGroup.sales:
      return Icons.point_of_sale_outlined;
    case NavGroup.purchasing:
      return Icons.local_shipping_outlined;
    case NavGroup.inventory:
      return Icons.inventory_2_outlined;
    case NavGroup.intelligence:
      return Icons.auto_awesome_outlined;
    case NavGroup.admin:
      return Icons.admin_panel_settings_outlined;
    case NavGroup.overview:
    case NavGroup.account:
      return Icons.circle_outlined;
  }
}

String navGroupLabel(NavGroup g, AppLocalizations l10n) {
  switch (g) {
    case NavGroup.sales:
      return l10n.navGroupSales;
    case NavGroup.purchasing:
      return l10n.navGroupPurchasing;
    case NavGroup.inventory:
      return l10n.navGroupInventory;
    case NavGroup.intelligence:
      return l10n.navGroupIntelligence;
    case NavGroup.admin:
      return l10n.navGroupAdmin;
    case NavGroup.overview:
    case NavGroup.account:
      return '';
  }
}

// ═════════════════════════ Shared navigation list ═════════════════════════

/// The navigation on the ink sidebar: Overview, then collapsible groups.
/// Built from [appDestinations], the same list the router guard uses, so a
/// user never sees an item they can't open (or misses one they can); a group
/// with nothing the user may open is hidden.
class AppNavList extends ConsumerWidget {
  final String location;

  /// Called after navigating (the modal drawer closes itself here).
  final VoidCallback? onNavigated;

  /// Icon-only rail mode: every item as an icon, no groups.
  final bool collapsed;

  const AppNavList({
    super.key,
    required this.location,
    this.onNavigated,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authNotifierProvider).user;
    ref.watch(navGroupsProvider);
    final groups = ref.read(navGroupsProvider.notifier);
    final current = destinationFor(location)?.route;

    void go(AppDestination d) {
      onNavigated?.call();
      // `go`, not `push`: switching sections replaces the page instead of
      // stacking it, so Back never walks through every screen visited.
      if (d.route != current) context.go(d.route);
    }

    final children = <Widget>[];

    if (collapsed) {
      for (final g in [NavGroup.overview, ..._collapsibleGroups]) {
        for (final d in navItems(g, user)) {
          children.add(_RailItem(
            destination: d,
            label: d.sidebarLabel(l10n),
            selected: d.route == current,
            onTap: () => go(d),
          ));
        }
      }
    } else {
      for (final d in navItems(NavGroup.overview, user)) {
        children.add(_TopItem(
          icon: d.icon,
          label: d.sidebarLabel(l10n),
          selected: d.route == current,
          onTap: () => go(d),
        ));
      }
      children.add(const SizedBox(height: 10));
      for (final g in _collapsibleGroups) {
        final items = navItems(g, user);
        if (items.isEmpty) continue;
        final active = items.any((d) => d.route == current);
        final open = groups.isOpen(g.name, active: active);
        children.add(_GroupHeader(
          icon: navGroupIcon(g),
          label: navGroupLabel(g, l10n),
          open: open,
          active: active,
          onTap: () => groups.toggle(g.name,
              active: active,
              all: [for (final x in _collapsibleGroups) x.name]),
        ));
        children.add(_GroupBody(
          open: open,
          children: [
            for (final d in items)
              _SubItem(
                label: d.sidebarLabel(l10n),
                selected: d.route == current,
                onTap: () => go(d),
              ),
          ],
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      children: children,
    );
  }
}

class _TopItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.sidebarText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: AppPressable(
        onTap: onTap,
        selected: selected,
        semanticLabel: label,
        color: selected ? AppColors.sidebarActive : Colors.transparent,
        hoverColor: AppColors.sidebarHover,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        size: 14, weight: FontWeight.w600, color: color)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool open;
  final bool active;
  final VoidCallback onTap;

  const _GroupHeader({
    required this.icon,
    required this.label,
    required this.open,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : AppColors.sidebarText;
    return Semantics(
      button: true,
      expanded: open,
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: AppPressable(
          onTap: onTap,
          hoverColor: AppColors.sidebarHover,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(children: [
                Icon(icon, size: 19, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.font(
                          size: 14, weight: FontWeight.w600, color: color)),
                ),
                AnimatedRotation(
                  turns: open ? 0.25 : 0,
                  duration: AppMotion.of(context, AppMotion.medium),
                  curve: AppMotion.curve,
                  child: const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.sidebarTextMuted),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// The items of an open group, indented on a thin guide line. Opens and
/// closes with a short size animation (instant with reduced motion).
class _GroupBody extends StatelessWidget {
  final bool open;
  final List<Widget> children;

  const _GroupBody({required this.open, required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: AppMotion.of(context, AppMotion.medium),
        curve: AppMotion.curve,
        alignment: Alignment.topCenter,
        child: open
            ? Padding(
                padding: const EdgeInsets.fromLTRB(19, 2, 0, 8),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                        left: BorderSide(color: AppColors.sidebarRule)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}

class _SubItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SubItem(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: AppPressable(
        onTap: onTap,
        selected: selected,
        semanticLabel: label,
        color: selected ? AppColors.sidebarActive : Colors.transparent,
        hoverColor: AppColors.sidebarHover,
        borderRadius: BorderRadius.circular(7),
        child: SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.font(
                    size: 13.5,
                    weight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? Colors.white : AppColors.sidebarText,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final AppDestination destination;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RailItem({
    required this.destination,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: AppPressable(
          onTap: onTap,
          selected: selected,
          semanticLabel: label,
          color: selected ? AppColors.sidebarActive : Colors.transparent,
          hoverColor: AppColors.sidebarHover,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 44,
            child: Center(
              child: Icon(destination.icon,
                  size: 20,
                  color: selected ? Colors.white : AppColors.sidebarText),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════ Brand + account ═════════════════════════

class _Brand extends ConsumerWidget {
  final bool collapsed;
  const _Brand({this.collapsed = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserEntity? user = ref.watch(authNotifierProvider).user;
    final mark = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text('F1',
          style: AppTheme.font(
              size: 13, weight: FontWeight.w700, color: Colors.white)),
    );
    if (collapsed) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 18), child: mark);
    }
    final company = user?.companyName ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 16, 14),
      child: Row(children: [
        mark,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Forever One',
                  style: AppTheme.heading(
                      size: 15, weight: FontWeight.w700, color: Colors.white)),
              if (company.isNotEmpty)
                Text(company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        size: 12, color: AppColors.sidebarTextMuted)),
            ],
          ),
        ),
      ]),
    );
  }
}

/// Avatar, name and role (opens My profile), the language switch and
/// sign-out, at the foot of the navigation.
class _AccountBlock extends ConsumerWidget {
  final bool collapsed;
  const _AccountBlock({this.collapsed = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final UserEntity? user = ref.watch(authNotifierProvider).user;
    final locale = ref.watch(localeProvider);

    void openProfile() {
      context.go('/profile');
    }

    final avatar = Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: Color(0xFF2A3550),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        user?.initials ?? '?',
        style: AppTheme.font(
            size: 12, weight: FontWeight.w600, color: Colors.white),
      ),
    );

    final logout = IconButton(
      tooltip: l10n.logout,
      onPressed: () => confirmLogout(context, ref, l10n),
      icon: const Icon(Icons.logout_outlined,
          size: 19, color: AppColors.sidebarTextMuted),
    );

    if (collapsed) {
      return Column(children: [
        Tooltip(
          message: user?.displayName ?? '',
          child: AppPressable(
            onTap: openProfile,
            semanticLabel: l10n.openProfile,
            borderRadius: BorderRadius.circular(20),
            hoverColor: AppColors.sidebarHover,
            child: Padding(padding: const EdgeInsets.all(6), child: avatar),
          ),
        ),
        logout,
      ]);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 4, 8),
            child: Row(children: [
              const Icon(Icons.language_outlined,
                  size: 18, color: AppColors.sidebarTextMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.language,
                    style: AppTheme.font(
                        size: 13, color: AppColors.sidebarText)),
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.sidebarHover,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Row(children: [
                  _LangChip(code: 'en', label: 'EN', current: locale.languageCode),
                  _LangChip(code: 'fr', label: 'FR', current: locale.languageCode),
                ]),
              ),
            ]),
          ),
          Row(children: [
            Expanded(
              child: AppPressable(
                onTap: openProfile,
                semanticLabel: l10n.openProfile,
                hoverColor: AppColors.sidebarHover,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(children: [
                    avatar,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.displayName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.font(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: Colors.white)),
                          Text(roleLabelFor(user?.role ?? '', l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.font(
                                  size: 12,
                                  color: AppColors.sidebarTextMuted)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            logout,
          ]),
        ],
      ),
    );
  }
}

class _LangChip extends ConsumerWidget {
  final String code;
  final String label;
  final String current;

  const _LangChip(
      {required this.code, required this.label, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = current == code;
    return AppPressable(
      onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(code)),
      selected: selected,
      semanticLabel: label,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      color: selected ? AppColors.primary : Colors.transparent,
      child: SizedBox(
        width: 44,
        height: 32,
        child: Center(
          child: Text(
            label,
            style: AppTheme.font(
              size: 12,
              weight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.sidebarText,
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════ Phone: modal drawer ═════════════════════════

/// The navigation as a modal drawer, for windows narrower than 840px. Same
/// ink look and groups as the desktop sidebar.
class AppDrawer extends StatelessWidget {
  final String location;
  const AppDrawer({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    void close() => Navigator.of(context).pop();
    // Light status bar icons over the navy drawer (dark ones vanished).
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Drawer(
      backgroundColor: AppColors.sidebar,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        // Phones: who is signed in and for which company at the top, the
        // same groups as the web sidebar, then language and logout.
        child: Column(
          children: [
            _DrawerUser(onNavigated: close),
            const Divider(height: 1, color: AppColors.sidebarActive),
            const SizedBox(height: 8),
            Expanded(
              child: AppNavList(location: location, onNavigated: close),
            ),
            const Divider(height: 1, color: AppColors.sidebarActive),
            const _DrawerFooter(),
          ],
        ),
      ),
    ),
    );
  }
}

/// Drawer top: initials, name, role · company; opens the profile.
class _DrawerUser extends ConsumerWidget {
  final VoidCallback onNavigated;
  const _DrawerUser({required this.onNavigated});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final UserEntity? user = ref.watch(authNotifierProvider).user;
    final detail = [
      if (user != null) roleLabelFor(user.role, l10n),
      if ((user?.companyName ?? '').isNotEmpty) user!.companyName,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: AppPressable(
        onTap: () {
          onNavigated();
          context.go('/profile');
        },
        semanticLabel: l10n.openProfile,
        hoverColor: AppColors.sidebarHover,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(user?.initials ?? '?',
                  style: AppTheme.heading(size: 15, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.displayName ?? '',
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
                          size: 12, color: AppColors.sidebarTextMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.sidebarTextMuted),
          ]),
        ),
      ),
    );
  }
}

/// Drawer bottom: language (EN / FR) and logout.
class _DrawerFooter extends ConsumerWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 12, 12),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.language_outlined,
              size: 18, color: AppColors.sidebarTextMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(l10n.language,
                style:
                    AppTheme.font(size: 14, color: AppColors.sidebarText)),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.sidebarHover,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Row(children: [
              _LangChip(code: 'en', label: 'EN', current: locale.languageCode),
              _LangChip(code: 'fr', label: 'FR', current: locale.languageCode),
            ]),
          ),
        ]),
        const SizedBox(height: 6),
        AppPressable(
          onTap: () => confirmLogout(context, ref, l10n),
          semanticLabel: l10n.logout,
          hoverColor: AppColors.sidebarHover,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 44,
            child: Row(children: [
              const Icon(Icons.logout_outlined,
                  size: 18, color: AppColors.sidebarTextMuted),
              const SizedBox(width: 10),
              Text(l10n.logout,
                  style: AppTheme.font(
                      size: 14, color: AppColors.sidebarText)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════ Desktop: permanent sidebar ═════════════════════════

/// The navigation as a permanent ink sidebar, from 840px. 248 wide below
/// 1200, 264 above; the user can collapse it to a 72-wide icon rail.
class AppSidebar extends ConsumerWidget {
  final String location;
  final double width;

  const AppSidebar({super.key, required this.location, required this.width});

  static const railWidth = 72.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final collapsed = ref.watch(sidebarCollapsedProvider);

    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.fast),
      curve: Curves.easeOut,
      width: collapsed ? railWidth : width,
      color: AppColors.sidebar,
      clipBehavior: Clip.hardEdge,
      child: SafeArea(
        right: false,
        // Labels or icons follow the width actually rendered, not the toggle:
        // during the collapse/expand animation the sidebar passes through
        // widths where labelled rows would overflow.
        child: LayoutBuilder(builder: (context, box) {
          final compact = box.maxWidth < 160;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Brand(collapsed: compact),
              Expanded(
                child: AppNavList(location: location, collapsed: compact),
              ),
              const Divider(height: 1, color: AppColors.sidebarActive),
              _AccountBlock(collapsed: compact),
              Align(
                alignment: compact ? Alignment.center : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: compact ? 0 : 8, bottom: 6),
                  child: IconButton(
                    tooltip:
                        collapsed ? l10n.expandSidebar : l10n.collapseSidebar,
                    onPressed: () =>
                        ref.read(sidebarCollapsedProvider.notifier).toggle(),
                    icon: Icon(
                      collapsed
                          ? Icons.keyboard_double_arrow_right
                          : Icons.keyboard_double_arrow_left,
                      size: 18,
                      color: AppColors.sidebarTextMuted,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
