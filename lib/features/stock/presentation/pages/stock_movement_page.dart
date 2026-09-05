import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/warehouse_provider.dart';
import '../providers/stock_movement_provider.dart';

class StockMovementPage extends ConsumerStatefulWidget {
  const StockMovementPage({super.key});

  @override
  ConsumerState<StockMovementPage> createState() => _StockMovementPageState();
}

class _StockMovementPageState extends ConsumerState<StockMovementPage> {
  String? selectedProductId;
  String? selectedWarehouseId;
  String selectedType = 'in';
  final quantityController = TextEditingController();
  final noteController = TextEditingController();

  static const types = <String, ({String label, IconData icon, Color color})>{
    'in': (label: 'Entrée', icon: Icons.arrow_downward, color: Colors.green),
    'out': (label: 'Sortie', icon: Icons.arrow_upward, color: Colors.red),
    'transfer': (label: 'Transfert', icon: Icons.swap_horiz, color: Colors.blue),
    'correction': (label: 'Correction', icon: Icons.tune, color: Colors.orange),
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productListProvider.notifier).load();
      ref.read(warehouseListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider).products;
    final warehouses = ref.watch(warehouseListProvider).warehouses;
    final movementState = ref.watch(stockMovementProvider);
    final theme = Theme.of(context);

    ref.listen(stockMovementProvider, (previous, next) {
      if (next.lastCurrentStock != null &&
          previous?.lastCurrentStock != next.lastCurrentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mouvement enregistré · Stock actuel : ${next.lastCurrentStock}'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        quantityController.clear();
        noteController.clear();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final canSubmit = selectedProductId != null &&
        selectedWarehouseId != null &&
        (int.tryParse(quantityController.text) ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Mouvement de stock')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Type de mouvement',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.6,
              children: types.entries.map((e) {
                final selected = selectedType == e.key;
                return InkWell(
                  onTap: () => setState(() => selectedType = e.key),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? e.value.color.withValues(alpha: 0.12)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? e.value.color
                            : theme.colorScheme.outlineVariant,
                        width: selected ? 1.6 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(e.value.icon,
                            size: 19,
                            color: selected
                                ? e.value.color
                                : theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          e.value.label,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            color: selected
                                ? e.value.color
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 22),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedProductId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Produit',
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: products
                          .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name, overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedProductId = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedWarehouseId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Dépôt',
                        prefixIcon: const Icon(Icons.warehouse_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: warehouses
                          .map((w) => DropdownMenuItem(
                          value: w.id, child: Text(w.name)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedWarehouseId = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Quantité',
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'Note (optionnel)',
                        prefixIcon: const Icon(Icons.notes),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: movementState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton.icon(
                onPressed: !canSubmit
                    ? null
                    : () {
                  final qty = int.tryParse(quantityController.text) ?? 0;
                  ref.read(stockMovementProvider.notifier).record(
                    productId: selectedProductId!,
                    warehouseId: selectedWarehouseId!,
                    type: selectedType,
                    quantity: qty,
                    note: noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim(),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Enregistrer le mouvement',
                    style: TextStyle(fontSize: 15)),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            if (movementState.lastCurrentStock != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green.shade700, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stock actuel après mouvement : ${movementState.lastCurrentStock}',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
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
  }
}