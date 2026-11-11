import 'package:flutter/material.dart';
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

// ═════════════════════════ Shared navigation list ═════════════════════════

/// The navigation items, grouped by section and filtered by permission.
/// Built from [appDestinations], the same list the router guard uses, so a
/// user never sees an item they can't open (or misses one they can).
class AppNavList extends ConsumerWidget {
  final String location;

  /// Called after navigating (the modal drawer closes itself here).
  final VoidCallback? onNavigated;

  /// Icon-only rail mode.
  final bool collapsed;

  /// 48 on touch (drawer), 44 on desktop (sidebar).
  final double itemHeight;

  const AppNavList({
    super.key,
    required this.location,
    this.onNavigated,
    this.collapsed = false,
    this.itemHeight = 48,
  });

  String? _sectionTitle(NavSection s, AppLocalizations l10n) {
    switch (s) {
      case NavSection.home:
        return null;
      case NavSection.business:
        return l10n.business;
      case NavSection.intelligence:
        return l10n.intelligence;
      case NavSection.system:
        return l10n.system;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authNotifierProvider).user;
    final current = destinationFor(location)?.route;

    final children = <Widget>[];
    for (final section in NavSection.values) {
      final items =
          appDestinations.where((d) => d.section == section && d.allows(user));
      if (items.isEmpty) continue;
      final title = _sectionTitle(section, l10n);
      if (title != null) {
        children.add(collapsed
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Divider(height: 1),
              )
            : _SectionLabel(title));
      }
      for (final d in items) {
        children.add(_NavItem(
          indent: d.indent && !collapsed,
          destination: d,
          label: d.label(l10n),
          selected: d.route == current,
          collapsed: collapsed,
          height: itemHeight,
          onTap: () {
            onNavigated?.call();
            // `go`, not `push`: switching sections replaces the page instead
            // of stacking it, so Back never walks through every screen visited.
            if (d.route != current) context.go(d.route);
          },
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: children,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 20, 6),
      child: Text(
        text.toUpperCase(),
        style: AppTheme.font(
          size: 11,
          weight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool indent;
  final AppDestination destination;
  final String label;
  final bool selected;
  final bool collapsed;
  final double height;
  final VoidCallback onTap;

  const _NavItem({
    this.indent = false,
    required this.destination,
    required this.label,
    required this.selected,
    required this.collapsed,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      destination.icon,
      size: indent ? 18 : 20,
      color: selected ? AppColors.primary : AppColors.iconMuted,
    );

    final content = SizedBox(
      height: height,
      child: collapsed
          ? Center(child: icon)
          : Padding(
              padding: EdgeInsets.only(left: indent ? 32 : 12, right: 12),
              child: Row(
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.font(
                        size: 14,
                        weight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected ? AppColors.primary : AppColors.textLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );

    final item = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: DecoratedBox(
        // Selected: light blue fill, blue icon and label.
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: AppPressable(
          onTap: onTap,
          selected: selected,
          semanticLabel: label,
          hoverColor: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          child: content,
        ),
      ),
    );

    return collapsed ? Tooltip(message: label, child: item) : item;
  }
}

// ═════════════════════════ Identity + footer ═════════════════════════

class _IdentityBlock extends ConsumerWidget {
  final bool collapsed;
  const _IdentityBlock({this.collapsed = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final UserEntity? user = ref.watch(authNotifierProvider).user;

    final avatar = Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        user?.initials ?? '?',
        style: AppTheme.font(size: 14, weight: FontWeight.w600, color: AppColors.primary),
      ),
    );

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Tooltip(message: user?.displayName ?? '', child: avatar),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              avatar,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? '',
                      style: AppTheme.font(size: 15, weight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleLabelFor(user?.role ?? '', l10n),
                      style: AppTheme.label,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (user != null && user.companyName.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.business_outlined,
                    size: 16, color: AppColors.iconMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(user.companyName,
                      style: AppTheme.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NavFooter extends ConsumerWidget {
  final bool collapsed;
  const _NavFooter({this.collapsed = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    final logout = AppPressable(
      onTap: () => confirmLogout(context, ref, l10n),
      semanticLabel: l10n.logout,
      borderRadius: BorderRadius.circular(12),
      hoverColor: AppColors.dangerSoft,
      child: SizedBox(
        height: 48,
        child: collapsed
            ? const Center(
                child: Icon(Icons.logout_outlined,
                    size: 20, color: AppColors.danger))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.logout_outlined,
                        size: 20, color: AppColors.danger),
                    const SizedBox(width: 12),
                    Text(
                      l10n.logout,
                      style: AppTheme.font(
                        size: 14,
                        weight: FontWeight.w500,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Tooltip(message: l10n.logout, child: logout),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.language_outlined,
                    size: 20, color: AppColors.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.language, style: AppTheme.font(size: 14)),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.fill,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Row(
                    children: [
                      _LangChip(code: 'en', label: 'EN', current: locale.languageCode),
                      _LangChip(code: 'fr', label: 'FR', current: locale.languageCode),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          logout,
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
      // 48 wide x 40 high hit area inside a 46 pill (was about 28 high).
      child: SizedBox(
        width: 48,
        height: 40,
        child: Center(
          child: Text(
            label,
            style: AppTheme.font(
              size: 12,
              weight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════ Phone: modal drawer ═════════════════════════

/// The navigation as a modal drawer, for windows narrower than 840px.
class AppDrawer extends StatelessWidget {
  final String location;
  const AppDrawer({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            const _IdentityBlock(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1),
            ),
            Expanded(
              child: AppNavList(
                location: location,
                onNavigated: () => Navigator.of(context).pop(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1),
            ),
            const _NavFooter(),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════ Desktop: permanent sidebar ═════════════════════════

/// The navigation as a permanent sidebar, from 840px. 248 wide below 1200,
/// 264 above; the user can collapse it to a 72-wide icon rail.
class AppSidebar extends ConsumerWidget {
  final String location;
  final double width;

  const AppSidebar({super.key, required this.location, required this.width});

  static const railWidth = 72.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return AnimatedContainer(
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: collapsed ? railWidth : width,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
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
            _IdentityBlock(collapsed: compact),
            Expanded(
              child: AppNavList(
                location: location,
                collapsed: compact,
                itemHeight: 44,
              ),
            ),
            const Divider(height: 1),
            _NavFooter(collapsed: compact),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: compact ? Alignment.center : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: compact ? 0 : 12),
                  child: IconButton(
                    tooltip:
                        collapsed ? l10n.expandSidebar : l10n.collapseSidebar,
                    onPressed: () =>
                        ref.read(sidebarCollapsedProvider.notifier).toggle(),
                    icon: Icon(
                      collapsed
                          ? Icons.keyboard_double_arrow_right
                          : Icons.keyboard_double_arrow_left,
                      size: 20,
                      color: AppColors.iconMuted,
                    ),
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
