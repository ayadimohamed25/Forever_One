import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardProvider.notifier).load());
  }

  Widget _kpiCard(String label, String value, {Color? color}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forever One — Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).load(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${authState.user?.email ?? "User"}!',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (dashboardState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (dashboardState.summary != null) ...[
                Row(
                  children: [
                    _kpiCard('Revenue', dashboardState.summary!.revenue.toStringAsFixed(2)),
                    const SizedBox(width: 8),
                    _kpiCard('Receivables', dashboardState.summary!.receivables.toStringAsFixed(2),
                        color: dashboardState.summary!.receivables > 0 ? Colors.orange : null),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _kpiCard('Payables', dashboardState.summary!.payables.toStringAsFixed(2),
                        color: dashboardState.summary!.payables > 0 ? Colors.orange : null),
                    const SizedBox(width: 8),
                    _kpiCard('Low Stock Alerts', dashboardState.summary!.lowStockCount.toString(),
                        color: dashboardState.summary!.lowStockCount > 0 ? Colors.red : Colors.green),
                  ],
                ),
              ],
              const Divider(height: 32),
              ElevatedButton(onPressed: () => context.push('/products'), child: const Text('Manage Products')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => context.push('/warehouses'), child: const Text('View Warehouses')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => context.push('/stock-movement'), child: const Text('Record Stock Movement')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => context.push('/customers'), child: const Text('Manage Customers')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => context.push('/suppliers'), child: const Text('Manage Suppliers')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => context.push('/sales'), child: const Text('Sales')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => context.push('/purchases'), child: const Text('Purchases')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => context.push('/scan'), child: const Text('Scan Document')),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => context.push('/ai'),
                icon: const Icon(Icons.smart_toy),
                label: const Text('AI Copilot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}