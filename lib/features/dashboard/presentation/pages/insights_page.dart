import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/prediction_provider.dart';

class InsightsPage extends ConsumerStatefulWidget {
  const InsightsPage({super.key});

  @override
  ConsumerState<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends ConsumerState<InsightsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(predictionProvider.notifier).loadAll());
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Insights & Prévisions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Stock'),
              Tab(text: 'Dormants'),
              Tab(text: 'Relances'),
            ],
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            // Stock forecast
            state.stockForecast.isEmpty
                ? const Center(child: Text('Aucune donnée de stock'))
                : ListView.builder(
              itemCount: state.stockForecast.length,
              itemBuilder: (context, index) {
                final f = state.stockForecast[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _urgencyColor(f.urgency),
                      child: Text('${f.currentStock}',
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    title: Text(f.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.daysOfCoverage != null
                            ? 'Couverture : ${f.daysOfCoverage} jours (${f.dailySalesRate}/jour)'
                            : 'Pas de ventes récentes'),
                        if (f.suggestedOrder > 0)
                          Text('Commander : ${f.suggestedOrder} unités',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    isThreeLine: f.suggestedOrder > 0,
                  ),
                );
              },
            ),

            // Dormant products
            state.dormantProducts.isEmpty
                ? const Center(child: Text('Aucun produit dormant 🎉'))
                : ListView.builder(
              itemCount: state.dormantProducts.length,
              itemBuilder: (context, index) {
                final d = state.dormantProducts[index];
                return ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                  title: Text(d.name),
                  subtitle: Text(d.neverSold
                      ? 'Jamais vendu'
                      : 'Dernière vente il y a ${d.daysSinceSale} jours'),
                );
              },
            ),

            // Customer scoring
            state.customerScores.isEmpty
                ? const Center(child: Text('Aucun client'))
                : ListView.builder(
              itemCount: state.customerScores.length,
              itemBuilder: (context, index) {
                final c = state.customerScores[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: c.score >= 60
                          ? Colors.red
                          : c.score >= 30
                          ? Colors.orange
                          : Colors.green,
                      child: Text('${c.score}',
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    title: Text(c.name),
                    subtitle: Text(c.reason),
                    trailing: c.balance > 0
                        ? Text('${c.balance.toStringAsFixed(2)} DT',
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold))
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}