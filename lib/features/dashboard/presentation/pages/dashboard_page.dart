import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/report_provider.dart';

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

  Widget _featureCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color ?? Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
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
    final reportState = ref.watch(reportProvider);

    ref.listen(reportProvider, (previous, next) {
      if (next.file != null && previous?.file != next.file) {
        OpenFilex.open(next.file!.path);
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

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
                'Bienvenue, ${authState.user?.email ?? "Utilisateur"}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (dashboardState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (dashboardState.summary != null) ...[
                Row(
                  children: [
                    _kpiCard('Chiffre d\'affaires',
                        dashboardState.summary!.revenue.toStringAsFixed(2)),
                    const SizedBox(width: 8),
                    _kpiCard('Créances', dashboardState.summary!.receivables.toStringAsFixed(2),
                        color: dashboardState.summary!.receivables > 0 ? Colors.orange : null),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _kpiCard('Dettes', dashboardState.summary!.payables.toStringAsFixed(2),
                        color: dashboardState.summary!.payables > 0 ? Colors.orange : null),
                    const SizedBox(width: 8),
                    _kpiCard('Alertes stock', dashboardState.summary!.lowStockCount.toString(),
                        color: dashboardState.summary!.lowStockCount > 0 ? Colors.red : Colors.green),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/ai'),
                      icon: const Icon(Icons.smart_toy),
                      label: const Text('AI Copilot'),
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => context.push('/insights'),
                      icon: const Icon(Icons.insights),
                      label: const Text('Insights'),
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Gestion',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 8),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.0,
                children: [
                  _featureCard(
                    icon: Icons.inventory_2,
                    label: 'Produits',
                    onTap: () => context.push('/products'),
                  ),
                  _featureCard(
                    icon: Icons.warehouse,
                    label: 'Dépôts',
                    onTap: () => context.push('/warehouses'),
                  ),
                  _featureCard(
                    icon: Icons.swap_vert,
                    label: 'Mouvements',
                    onTap: () => context.push('/stock-movement'),
                  ),
                  _featureCard(
                    icon: Icons.people,
                    label: 'Clients',
                    onTap: () => context.push('/customers'),
                  ),
                  _featureCard(
                    icon: Icons.local_shipping,
                    label: 'Fournisseurs',
                    onTap: () => context.push('/suppliers'),
                  ),
                  _featureCard(
                    icon: Icons.point_of_sale,
                    label: 'Ventes',
                    onTap: () => context.push('/sales'),
                  ),
                  _featureCard(
                    icon: Icons.shopping_cart,
                    label: 'Achats',
                    onTap: () => context.push('/purchases'),
                  ),
                  _featureCard(
                    icon: Icons.document_scanner,
                    label: 'Scanner',
                    onTap: () => context.push('/scan'),
                  ),
                  _featureCard(
                    icon: Icons.history,
                    label: 'Audit',
                    onTap: () => context.push('/audit'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              reportState.isLoading
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
                  : OutlinedButton.icon(
                onPressed: () => ref.read(reportProvider.notifier).download(),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Générer le rapport PDF'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}