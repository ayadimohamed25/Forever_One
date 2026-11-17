import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../l10n/app_localizations.dart';

/// Which sidebar group a destination belongs to, in sidebar order.
/// [overview] items sit at the top level; [account] lives in the account
/// block at the foot of the sidebar instead of the list.
enum NavGroup { overview, sales, purchasing, inventory, intelligence, admin, account }

/// One top-level screen: its route, the permission that opens it, and how it
/// appears in the navigation.
///
/// This list is the single source of truth for both the sidebar/drawer
/// (what a user sees) and the router guard (what a user may open), so the two
/// can never disagree. To add a screen: add its GoRoute inside the ShellRoute
/// in app_router.dart, then add one entry here.
class AppDestination {
  final String route;
  final IconData icon;
  final String Function(AppLocalizations l10n) label;

  /// Null means every signed-in user may open it.
  final String? permission;
  final NavGroup group;

  /// Position inside its group in the sidebar. The list order itself stays
  /// the home-screen priority used by [homeFor].
  final int navOrder;

  /// Sidebar label when it differs from the page title ("Overview" for the
  /// dashboard, "Invoices" for sales inside the Sales group).
  final String Function(AppLocalizations l10n)? navLabel;

  const AppDestination({
    required this.route,
    required this.icon,
    required this.label,
    required this.group,
    this.navOrder = 0,
    this.navLabel,
    this.permission,
  });

  String sidebarLabel(AppLocalizations l10n) => (navLabel ?? label)(l10n);

  bool allows(UserEntity? user) =>
      permission == null || (user?.can(permission!) ?? false);
}

final List<AppDestination> appDestinations = [
  AppDestination(
    route: '/dashboard',
    icon: Icons.grid_view_outlined,
    label: (l) => l.dashboard,
    permission: 'view_dashboard',
    group: NavGroup.overview,
    navOrder: 0,
    navLabel: (l) => l.navOverview,
  ),
  AppDestination(
    route: '/products',
    icon: Icons.inventory_2_outlined,
    label: (l) => l.products,
    permission: 'view_products',
    group: NavGroup.inventory,
    navOrder: 0,
  ),
  AppDestination(
    route: '/categories',
    icon: Icons.category_outlined,
    label: (l) => l.categories,
    permission: 'view_products',
    group: NavGroup.inventory,
    navOrder: 1,
  ),
  AppDestination(
    route: '/warehouses',
    icon: Icons.warehouse_outlined,
    label: (l) => l.warehouses,
    permission: 'view_warehouses',
    group: NavGroup.inventory,
    navOrder: 2,
  ),
  AppDestination(
    route: '/stock-movement',
    icon: Icons.swap_vert_outlined,
    label: (l) => l.movements,
    permission: 'manage_stock',
    group: NavGroup.inventory,
    navOrder: 3,
  ),
  AppDestination(
    route: '/customers',
    icon: Icons.people_outline,
    label: (l) => l.customers,
    permission: 'view_customers',
    group: NavGroup.sales,
    navOrder: 1,
  ),
  AppDestination(
    route: '/suppliers',
    icon: Icons.local_shipping_outlined,
    label: (l) => l.suppliers,
    permission: 'view_suppliers',
    group: NavGroup.purchasing,
    navOrder: 1,
  ),
  AppDestination(
    route: '/sales',
    icon: Icons.point_of_sale_outlined,
    label: (l) => l.sales,
    permission: 'view_sales',
    group: NavGroup.sales,
    navOrder: 0,
    navLabel: (l) => l.navInvoices,
  ),
  AppDestination(
    route: '/purchases',
    icon: Icons.shopping_cart_outlined,
    label: (l) => l.purchases,
    permission: 'view_purchases',
    group: NavGroup.purchasing,
    navOrder: 0,
  ),
  AppDestination(
    route: '/ai',
    icon: Icons.auto_awesome_outlined,
    label: (l) => l.aiCopilot,
    permission: 'use_ai',
    group: NavGroup.intelligence,
    navOrder: 1,
  ),
  AppDestination(
    route: '/insights',
    icon: Icons.insights_outlined,
    label: (l) => l.insights,
    permission: 'view_insights',
    group: NavGroup.intelligence,
    navOrder: 0,
  ),
  AppDestination(
    route: '/scan',
    icon: Icons.document_scanner_outlined,
    label: (l) => l.scanner,
    permission: 'scan_documents',
    group: NavGroup.intelligence,
    navOrder: 2,
  ),
  AppDestination(
    route: '/users',
    icon: Icons.group_outlined,
    label: (l) => l.users,
    permission: 'manage_users',
    group: NavGroup.admin,
    navOrder: 0,
  ),
  AppDestination(
    route: '/audit',
    icon: Icons.history_outlined,
    label: (l) => l.auditLog,
    permission: 'view_audit',
    group: NavGroup.admin,
    navOrder: 1,
  ),
  AppDestination(
    route: '/profile',
    icon: Icons.person_outline,
    label: (l) => l.myProfile,
    group: NavGroup.account,
    navOrder: 0,
  ),
];

/// The five screens in the phone's bottom bar, in tab order (mobile board:
/// Home · Sales · Stock · Customers · More). Each is a branch of the router's
/// StatefulShellRoute, so switching tabs keeps each tab's scroll position and
/// state. `/more` lists everything else, grouped like the web sidebar.
const tabRoutes = ['/dashboard', '/sales', '/products', '/customers', moreRoute];

/// The phone's More tab. Not in [appDestinations]: every signed-in user may
/// open it, and the sidebar never shows it.
const moreRoute = '/more';

/// The destination a location belongs to, matched on its first segment so
/// `/products/42` still selects Products.
AppDestination? destinationFor(String location) {
  final path = Uri.parse(location).path;
  final first = path.split('/').where((s) => s.isNotEmpty).firstOrNull;
  if (first == null) return null;
  for (final d in appDestinations) {
    if (d.route == '/$first') return d;
  }
  return null;
}

/// The sidebar items of [group] that [user] may open, in sidebar order.
List<AppDestination> navItems(NavGroup group, UserEntity? user) =>
    appDestinations.where((d) => d.group == group && d.allows(user)).toList()
      ..sort((a, b) => a.navOrder.compareTo(b.navOrder));

/// Where to send a signed-in user who has nowhere better to go: the first
/// screen they are allowed to open (Dashboard for most roles), else Profile,
/// which everyone may open. Never a route they would be bounced from.
String homeFor(UserEntity? user) {
  for (final d in appDestinations) {
    if (d.allows(user)) return d.route;
  }
  return '/profile';
}
