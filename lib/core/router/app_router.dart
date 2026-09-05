import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/stock/presentation/pages/products_page.dart';
import '../../features/stock/presentation/pages/warehouses_page.dart';
import '../../features/stock/presentation/pages/stock_movement_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/suppliers/presentation/pages/suppliers_page.dart';
import '../../features/sales/presentation/pages/sales_page.dart';
import '../../features/purchases/presentation/pages/purchases_page.dart';
import '../../features/scan/presentation/pages/scan_page.dart';
import '../../features/ai/presentation/pages/ai_chat_page.dart';
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsPage(),
    ),
    GoRoute(
      path: '/warehouses',
      builder: (context, state) => const WarehousesPage(),
    ),
    GoRoute(
      path: '/stock-movement',
      builder: (context, state) => const StockMovementPage(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersPage(),
    ),
    GoRoute(
      path: '/suppliers',
      builder: (context, state) => const SuppliersPage(),
    ),
    GoRoute(
      path: '/sales',
      builder: (context, state) => const SalesPage(),
    ),
    GoRoute(
      path: '/purchases',
      builder: (context, state) => const PurchasesPage(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanPage(),
    ),
    GoRoute(
      path: '/ai',
      builder: (context, state) => const AiChatPage(),
    ),
  ],
);




