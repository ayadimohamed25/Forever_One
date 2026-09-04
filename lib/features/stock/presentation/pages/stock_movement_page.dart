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

    ref.listen(stockMovementProvider, (previous, next) {
      if (next.lastCurrentStock != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recorded. Current stock: ${next.lastCurrentStock}')),
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Record Stock Movement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedProductId,
              decoration: const InputDecoration(labelText: 'Product'),
              items: products
                  .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (v) => setState(() => selectedProductId = v),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedWarehouseId,
              decoration: const InputDecoration(labelText: 'Warehouse'),
              items: warehouses
                  .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                  .toList(),
              onChanged: (v) => setState(() => selectedWarehouseId = v),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'in', child: Text('In')),
                DropdownMenuItem(value: 'out', child: Text('Out')),
                DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                DropdownMenuItem(value: 'correction', child: Text('Correction')),
              ],
              onChanged: (v) => setState(() => selectedType = v!),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            const SizedBox(height: 24),
            movementState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                if (selectedProductId == null || selectedWarehouseId == null) return;
                final qty = int.tryParse(quantityController.text) ?? 0;
                if (qty <= 0) return;
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
              child: const Text('Record Movement'),
            ),
          ],
        ),
      ),
    );
  }
}
