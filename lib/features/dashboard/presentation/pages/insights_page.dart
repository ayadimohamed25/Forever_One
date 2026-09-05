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

  Color _urgencyColor(String urgency, ThemeData theme) {
    switch (urgency) {
      case 'critical':
        return theme.colorScheme.error;
      case 'warning':
        return Colors.orange.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  String _urgencyLabel(String urgency) {
    switch (urgency) {
      case 'critical':
        return 'Rupture';
      case 'warning':
        return 'Bientôt';
      default:
        return 'OK';
    }
  }

  Widget _emptyState(IconData icon, String title, String subtitle, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Insights & Prévisions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(predictionProvider.notifier).loadAll(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.trending_down, size: 20), text: 'Stock'),
              Tab(icon: Icon(Icons.hourglass_empty, size: 20), text: 'Dormants'),
              Tab(icon: Icon(Icons.phone_callback, size: 20), text: 'Relances'),
            ],
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            // ---------- Stock forecast ----------
            state.stockForecast.isEmpty
                ? _emptyState(Icons.inventory_2_outlined, 'Aucune donnée',
                'Ajoutez des produits pour voir les prévisions', theme)
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.stockForecast.length,
              itemBuilder: (context, index) {
                final f = state.stockForecast[index];
                final color = _urgencyColor(f.urgency, theme);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${f.currentStock}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.name,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(
                                    f.daysOfCoverage != null
                                        ? '${f.daysOfCoverage} jours de couverture · ${f.dailySalesRate}/jour'
                                        : 'Pas de ventes récentes',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _urgencyLabel(f.urgency),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (f.suggestedOrder > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb_outline,
                                    size: 16,
                                    color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Commander ${f.suggestedOrder} unités',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            // ---------- Dormant products ----------
            state.dormantProducts.isEmpty
                ? _emptyState(Icons.check_circle_outline, 'Aucun produit dormant',
                'Tous vos produits se vendent régulièrement', theme)
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.dormantProducts.length,
              itemBuilder: (context, index) {
                final d = state.dormantProducts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.hourglass_empty,
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                d.neverSold
                                    ? 'Jamais vendu'
                                    : 'Dernière vente il y a ${d.daysSinceSale} jours',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (d.neverSold)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Jamais vendu',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                )),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ---------- Customer scoring ----------
            state.customerScores.isEmpty
                ? _emptyState(Icons.people_outline, 'Aucun client',
                'Ajoutez des clients pour voir les scores', theme)
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.customerScores.length,
              itemBuilder: (context, index) {
                final c = state.customerScores[index];
                final scoreColor = c.score >= 60
                    ? theme.colorScheme.error
                    : c.score >= 30
                    ? Colors.orange.shade700
                    : Colors.green.shade700;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 46,
                          height: 46,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 46,
                                height: 46,
                                child: CircularProgressIndicator(
                                  value: c.score / 100,
                                  strokeWidth: 4,
                                  backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                                  valueColor:
                                  AlwaysStoppedAnimation(scoreColor),
                                ),
                              ),
                              Text('${c.score}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: scoreColor,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(c.reason,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  )),
                            ],
                          ),
                        ),
                        if (c.balance > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${c.balance.toStringAsFixed(2)} DT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
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