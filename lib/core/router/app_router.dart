import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/stock/presentation/pages/categories_page.dart';
import '../../features/stock/presentation/pages/products_page.dart';
import '../../features/stock/presentation/pages/warehouses_page.dart';
import '../../features/stock/presentation/pages/stock_movement_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/suppliers/presentation/pages/suppliers_page.dart';
import '../../features/sales/presentation/pages/sales_page.dart';
import '../../features/purchases/presentation/pages/purchases_page.dart';
import '../../features/scan/presentation/pages/scan_page.dart';
import '../../features/ai/presentation/pages/ai_chat_page.dart';
import '../../features/dashboard/presentation/pages/insights_page.dart';
import '../../features/dashboard/presentation/pages/audit_page.dart';
import '../../features/users/presentation/pages/profile_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/app_tabs_scaffold.dart';
import '../../shared/widgets/splash_page.dart';
import 'auth_redirect.dart';

/// Re-runs the router's redirect whenever the session status changes
/// (restored, signed in, signed out, token rejected).
class _AuthRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

/// Top-level pages use no transition: switching sections from the sidebar
/// or the bottom bar should feel instant, not like drilling into a screen.
/// Pages span the content area (business tables use the width); pages that
/// need a reading width (dashboard, forms, chat) cap their own body.
Page<void> _section(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

GoRoute _page(String path, Widget child) =>
    GoRoute(path: path, pageBuilder: (c, s) => _section(s, child));

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh();
  ref.listen<AuthStatus>(
    authNotifierProvider.select((s) => s.status),
    (_, _) => refresh.ping(),
  );
  // Permissions can change on restore/login without a status change in rare
  // cases (re-login as another user); refresh on user identity too.
  ref.listen(
    authNotifierProvider.select((s) => s.user?.id),
    (_, _) => refresh.ping(),
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: splashRoute,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      return computeRedirect(
        status: auth.status,
        user: auth.user,
        location: state.uri,
      );
    },
    routes: [
      GoRoute(
        path: splashRoute,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      // Every signed-in screen lives in the shell: drawer on phones,
      // permanent sidebar from 840px. See shared/widgets/app_shell.dart.
      //
      //   ShellRoute (AppShell: drawer | sidebar)
      //   ├─ StatefulShellRoute (AppTabsScaffold: bottom bar on phones)
      //   │    Home · Products · Sales · Customers · AI Copilot
      //   └─ the other drawer screens (no bottom bar)
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.toString(), child: child),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                AppTabsScaffold(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                  routes: [_page('/dashboard', const DashboardPage())]),
              StatefulShellBranch(
                  routes: [_page('/products', const ProductsPage())]),
              StatefulShellBranch(routes: [_page('/sales', const SalesPage())]),
              StatefulShellBranch(
                  routes: [_page('/customers', const CustomersPage())]),
              StatefulShellBranch(routes: [_page('/ai', const AiChatPage())]),
            ],
          ),
          _page('/categories', const CategoriesPage()),
          _page('/warehouses', const WarehousesPage()),
          _page('/stock-movement', const StockMovementPage()),
          _page('/suppliers', const SuppliersPage()),
          _page('/purchases', const PurchasesPage()),
          _page('/scan', const ScanPage()),
          _page('/insights', const InsightsPage()),
          _page('/audit', const AuditPage()),
          _page('/users', const UsersPage()),
          _page('/profile', const ProfilePage()),
        ],
      ),
    ],
  );
});
