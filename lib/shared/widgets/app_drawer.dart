import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';

class AppDrawer extends ConsumerWidget {
  /// The route currently shown, so its entry reads as selected.
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        text.toUpperCase(),
        style: AppTheme.font(
          size: 12,
          weight: FontWeight.w500,
          letterSpacing: 0.8,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _navItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
      }) {
    final selected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Material(
        color: selected ? AppColors.fill : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            if (!selected) context.push(route);
          },
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColors.textPrimary : AppColors.icon,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.font(
                      size: 15,
                      weight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 2,
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
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

    bool can(String permission) => user?.can(permission) ?? false;

    final businessItems = <Widget>[
      if (can('view_products'))
        _navItem(context,
            icon: Icons.inventory_2_outlined,
            label: l10n.products,
            route: '/products'),
      if (can('view_warehouses'))
        _navItem(context,
            icon: Icons.warehouse_outlined,
            label: l10n.warehouses,
            route: '/warehouses'),
      if (can('manage_stock'))
        _navItem(context,
            icon: Icons.swap_vert_outlined,
            label: l10n.movements,
            route: '/stock-movement'),
      if (can('view_customers'))
        _navItem(context,
            icon: Icons.people_outline,
            label: l10n.customers,
            route: '/customers'),
      if (can('view_suppliers'))
        _navItem(context,
            icon: Icons.local_shipping_outlined,
            label: l10n.suppliers,
            route: '/suppliers'),
      if (can('view_sales'))
        _navItem(context,
            icon: Icons.point_of_sale_outlined,
            label: l10n.sales,
            route: '/sales'),
      if (can('view_purchases'))
        _navItem(context,
            icon: Icons.shopping_cart_outlined,
            label: l10n.purchases,
            route: '/purchases'),
    ];

    final intelligenceItems = <Widget>[
      if (can('use_ai'))
        _navItem(context,
            icon: Icons.auto_awesome_outlined,
            label: l10n.aiCopilot,
            route: '/ai'),
      if (can('view_insights'))
        _navItem(context,
            icon: Icons.insights_outlined,
            label: l10n.insights,
            route: '/insights'),
      if (can('scan_documents'))
        _navItem(context,
            icon: Icons.document_scanner_outlined,
            label: l10n.scanner,
            route: '/scan'),
    ];

    final systemItems = <Widget>[
      if (can('manage_users'))
        _navItem(context,
            icon: Icons.group_outlined,
            label: l10n.users,
            route: '/users'),
      if (can('view_audit'))
        _navItem(context,
            icon: Icons.history_outlined,
            label: l10n.auditLog,
            route: '/audit'),
      _navItem(context,
          icon: Icons.person_outline,
          label: l10n.myProfile,
          route: '/profile'),
    ];

    return Drawer(
      backgroundColor: AppColors.canvas,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Identity
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 28, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.fill,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user?.initials ?? '?',
                    style:
                    AppTheme.font(size: 16, weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? '',
                        style: AppTheme.font(
                          size: 17,
                          weight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _roleLabel(user?.role ?? '', l10n),
                        style: AppTheme.label,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (user != null && user.companyName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.business_outlined,
                      size: 16, color: AppColors.iconMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(user.companyName,
                        style: AppTheme.label, maxLines: 2),
                  ),
                ],
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              children: [
                if (can('view_dashboard'))
                  _navItem(context,
                      icon: Icons.grid_view_outlined,
                      label: l10n.dashboard,
                      route: '/dashboard'),
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

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.language_outlined,
                        size: 22, color: AppColors.icon),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(l10n.language,
                          style: AppTheme.font(size: 15)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.fill,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          _langChip(ref, 'en', 'EN', locale.languageCode),
                          _langChip(ref, 'fr', 'FR', locale.languageCode),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _confirmLogout(context, ref, l10n),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Row(
                        children: [
                          const Icon(Icons.logout_outlined,
                              size: 22, color: AppColors.danger),
                          const SizedBox(width: 16),
                          Text(
                            l10n.logout,
                            style: AppTheme.font(
                              size: 15,
                              weight: FontWeight.w500,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langChip(
      WidgetRef ref, String code, String label, String current) {
    final selected = current == code;
    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(code)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTheme.font(
            size: 12,
            weight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}