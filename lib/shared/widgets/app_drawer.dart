import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/locale_provider.dart';
import '../../core/theme/app_colors.dart';
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

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 18, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _navItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
        required Color color,
      }) {
    final selected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Material(
        color: selected ? color.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).pop(); // close the drawer first
            if (!selected) context.push(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: selected
                        ? color
                        : color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon,
                      size: 16, color: selected ? Colors.white : color),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? color : AppColors.textPrimary,
                    ),
                  ),
                ),
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
    final l10n = AppLocalizations.of(context)!;
    final UserEntity? user = ref.watch(authNotifierProvider).user;
    final locale = ref.watch(localeProvider);

    // Only show what this role is actually allowed to reach.
    bool can(String permission) => user?.can(permission) ?? false;

    final businessItems = <Widget>[
      if (can('view_products'))
        _navItem(context,
            icon: Icons.inventory_2_outlined,
            label: l10n.products,
            route: '/products',
            color: AppColors.stock),
      if (can('view_warehouses'))
        _navItem(context,
            icon: Icons.warehouse_outlined,
            label: l10n.warehouses,
            route: '/warehouses',
            color: AppColors.stock),
      if (can('manage_stock'))
        _navItem(context,
            icon: Icons.swap_vert,
            label: l10n.movements,
            route: '/stock-movement',
            color: AppColors.stock),
      if (can('view_customers'))
        _navItem(context,
            icon: Icons.people_outline,
            label: l10n.customers,
            route: '/customers',
            color: AppColors.finance),
      if (can('view_suppliers'))
        _navItem(context,
            icon: Icons.local_shipping_outlined,
            label: l10n.suppliers,
            route: '/suppliers',
            color: AppColors.purchases),
      if (can('view_sales'))
        _navItem(context,
            icon: Icons.point_of_sale_outlined,
            label: l10n.sales,
            route: '/sales',
            color: AppColors.sales),
      if (can('view_purchases'))
        _navItem(context,
            icon: Icons.shopping_cart_outlined,
            label: l10n.purchases,
            route: '/purchases',
            color: AppColors.purchases),
    ];

    final intelligenceItems = <Widget>[
      if (can('use_ai'))
        _navItem(context,
            icon: Icons.smart_toy_outlined,
            label: l10n.aiCopilot,
            route: '/ai',
            color: AppColors.primary),
      if (can('view_insights'))
        _navItem(context,
            icon: Icons.insights_outlined,
            label: l10n.insights,
            route: '/insights',
            color: AppColors.primary),
      if (can('scan_documents'))
        _navItem(context,
            icon: Icons.document_scanner_outlined,
            label: l10n.scanner,
            route: '/scan',
            color: AppColors.info),
    ];

    final systemItems = <Widget>[
      if (can('manage_users'))
        _navItem(context,
            icon: Icons.group_outlined,
            label: l10n.users,
            route: '/users',
            color: AppColors.primary),
      if (can('view_audit'))
        _navItem(context,
            icon: Icons.history,
            label: l10n.auditLog,
            route: '/audit',
            color: AppColors.info),
      _navItem(context,
          icon: Icons.person_outline,
          label: l10n.myProfile,
          route: '/profile',
          color: AppColors.textSecondary),
    ];

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          // User header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 24, 20, 24),
            decoration: const BoxDecoration(gradient: AppColors.brandGradient),
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
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _roleLabel(user?.role ?? '', l10n),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (user != null && user.companyName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.business,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.85)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          user.companyName,
                          style: TextStyle(
                            fontSize: 11.5,
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                const SizedBox(height: 10),
                if (can('view_dashboard'))
                  _navItem(context,
                      icon: Icons.dashboard_outlined,
                      label: l10n.dashboard,
                      route: '/dashboard',
                      color: AppColors.primary),

                if (businessItems.isNotEmpty) ...[
                  _sectionLabel(l10n.business),
                  ...businessItems,
                ],

                if (intelligenceItems.isNotEmpty) ...[
                  _sectionLabel(l10n.intelligence),
                  ...intelligenceItems,
                ],

                _sectionLabel(l10n.system),
                ...systemItems,
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.language,
                      size: 20, color: AppColors.textSecondary),
                  title: Text(l10n.language,
                      style: const TextStyle(fontSize: 13.5)),
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
                  leading: const Icon(Icons.logout,
                      size: 20, color: AppColors.danger),
                  title: Text(l10n.logout,
                      style: const TextStyle(
                          fontSize: 13.5, color: AppColors.danger)),
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