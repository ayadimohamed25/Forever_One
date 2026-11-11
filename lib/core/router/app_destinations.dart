import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../l10n/app_localizations.dart';

/// Which sidebar group a destination belongs to.
enum NavSection { home, business, intelligence, system }

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
  final NavSection section;

  /// Drawn as a sub-item of the entry above it (Categories under Products).
  final bool indent;

  const AppDestination({
    required this.route,
    required this.icon,
    required this.label,
    required this.section,
    this.permission,
    this.indent = false,
  });

  bool allows(UserEntity? user) =>
      permission == null || (user?.can(permission!) ?? false);
}

final List<AppDestination> appDestinations = [
  AppDestination(
      route: '/dashboard',
      icon: Icons.grid_view_outlined,
      label: (l) => l.dashboard,
      permission: 'view_dashboard',
      section: NavSection.home),
  AppDestination(
      route: '/products',
      icon: Icons.inventory_2_outlined,
      label: (l) => l.products,
      permission: 'view_products',
      section: NavSection.business),
  AppDestination(
      route: '/categories',
      icon: Icons.category_outlined,
      label: (l) => l.categories,
      permission: 'view_products',
      section: NavSection.business,
      indent: true),
  AppDestination(
      route: '/warehouses',
      icon: Icons.warehouse_outlined,
      label: (l) => l.warehouses,
      permission: 'view_warehouses',
      section: NavSection.business),
  AppDestination(
      route: '/stock-movement',
      icon: Icons.swap_vert_outlined,
      label: (l) => l.movements,
      permission: 'manage_stock',
      section: NavSection.business),
  AppDestination(
      route: '/customers',
      icon: Icons.people_outline,
      label: (l) => l.customers,
      permission: 'view_customers',
      section: NavSection.business),
  AppDestination(
      route: '/suppliers',
      icon: Icons.local_shipping_outlined,
      label: (l) => l.suppliers,
      permission: 'view_suppliers',
      section: NavSection.business),
  AppDestination(
      route: '/sales',
      icon: Icons.point_of_sale_outlined,
      label: (l) => l.sales,
      permission: 'view_sales',
      section: NavSection.business),
  AppDestination(
      route: '/purchases',
      icon: Icons.shopping_cart_outlined,
      label: (l) => l.purchases,
      permission: 'view_purchases',
      section: NavSection.business),
  AppDestination(
      route: '/ai',
      icon: Icons.auto_awesome_outlined,
      label: (l) => l.aiCopilot,
      permission: 'use_ai',
      section: NavSection.intelligence),
  AppDestination(
      route: '/insights',
      icon: Icons.insights_outlined,
      label: (l) => l.insights,
      permission: 'view_insights',
      section: NavSection.intelligence),
  AppDestination(
      route: '/scan',
      icon: Icons.document_scanner_outlined,
      label: (l) => l.scanner,
      permission: 'scan_documents',
      section: NavSection.intelligence),
  AppDestination(
      route: '/users',
      icon: Icons.group_outlined,
      label: (l) => l.users,
      permission: 'manage_users',
      section: NavSection.system),
  AppDestination(
      route: '/audit',
      icon: Icons.history_outlined,
      label: (l) => l.auditLog,
      permission: 'view_audit',
      section: NavSection.system),
  AppDestination(
      route: '/profile',
      icon: Icons.person_outline,
      label: (l) => l.myProfile,
      section: NavSection.system),
];

/// The five screens in the phone's bottom bar, in tab order. Each is a branch
/// of the router's StatefulShellRoute, so switching tabs keeps each tab's
/// scroll position and state.
const tabRoutes = ['/dashboard', '/products', '/sales', '/customers', '/ai'];

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

/// Where to send a signed-in user who has nowhere better to go: the first
/// screen they are allowed to open (Dashboard for most roles), else Profile,
/// which everyone may open. Never a route they would be bounced from.
String homeFor(UserEntity? user) {
  for (final d in appDestinations) {
    if (d.allows(user)) return d.route;
  }
  return '/profile';
}
