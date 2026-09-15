
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/locale_provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';

class AppDrawer extends ConsumerWidget {
  /// The route of the screen currently shown, so its entry can be highlighted.
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  String _roleLabel(String role, AppLocalizations l10n) {
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

  Widget _sectionLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _navItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
        Widget? trailing,
      }) {
    final theme = Theme.of(context);
    final selected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Material(
        color: selected
            ? theme.colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.of(context).pop(); // close the drawer first
            if (!selected) context.push(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon,
                    size: 21,
                    color: selected
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(authRepositoryProvider).logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final UserEntity? user = ref.watch(authNotifierProvider).user;
    final locale = ref.watch(localeProvider);

    return Drawer(
      child: Column(
        children: [
          // User header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 24, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?.initials ?? '?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _roleLabel(user?.role ?? '', l10n),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  user?.displayName ?? '',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (user != null && user.companyName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.business,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.85)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          user.companyName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                const SizedBox(height: 8),
                _navItem(context,
                    icon: Icons.dashboard_outlined,
                    label: l10n.dashboard,
                    route: '/dashboard'),

                _sectionLabel(l10n.business, theme),
                _navItem(context,
                    icon: Icons.inventory_2_outlined,
                    label: l10n.products,
                    route: '/products'),
                _navItem(context,
                    icon: Icons.warehouse_outlined,
                    label: l10n.warehouses,
                    route: '/warehouses'),
                _navItem(context,
                    icon: Icons.swap_vert,
                    label: l10n.movements,
                    route: '/stock-movement'),
                _navItem(context,
                    icon: Icons.people_outline,
                    label: l10n.customers,
                    route: '/customers'),
                _navItem(context,
                    icon: Icons.local_shipping_outlined,
                    label: l10n.suppliers,
                    route: '/suppliers'),
                _navItem(context,
                    icon: Icons.point_of_sale_outlined,
                    label: l10n.sales,
                    route: '/sales'),
                _navItem(context,
                    icon: Icons.shopping_cart_outlined,
                    label: l10n.purchases,
                    route: '/purchases'),

                _sectionLabel(l10n.intelligence, theme),
                _navItem(context,
                    icon: Icons.smart_toy_outlined,
                    label: l10n.aiCopilot,
                    route: '/ai'),
                _navItem(context,
                    icon: Icons.insights_outlined,
                    label: l10n.insights,
                    route: '/insights'),
                _navItem(context,
                    icon: Icons.document_scanner_outlined,
                    label: l10n.scanner,
                    route: '/scan'),

                _sectionLabel(l10n.system, theme),
                _navItem(context,
                    icon: Icons.history,
                    label: l10n.auditLog,
                    route: '/audit'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Language + logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.language, size: 21),
                  title: Text(l10n.language, style: const TextStyle(fontSize: 14)),
                  trailing: SegmentedButton<String>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('EN')),
                      ButtonSegment(value: 'fr', label: Text('FR')),
                    ],
                    selected: {locale.languageCode},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(s.first)),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.logout,
                      size: 21, color: theme.colorScheme.error),
                  title: Text(l10n.logout,
                      style: TextStyle(
                          fontSize: 14, color: theme.colorScheme.error)),
                  onTap: () => _confirmLogout(context, ref, l10n),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}