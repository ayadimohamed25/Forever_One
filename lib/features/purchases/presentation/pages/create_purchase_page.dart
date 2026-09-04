import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';
import '../../../stock/presentation/providers/warehouse_provider.dart';
import '../../../stock/presentation/providers/product_provider.dart';
import '../../domain/entities/purchase_line_entity.dart';
import '../providers/purchase_provider.dart';

class CreatePurchasePage extends ConsumerStatefulWidget {
  const CreatePurchasePage({super.key});

  @override
  ConsumerState<CreatePurchasePage> createState() => _CreatePurchasePageState();
}

class _CreatePurchasePageState extends ConsumerState<CreatePurchasePage> {
  String? supplierId;
  String? warehouseId;
  final List<PurchaseLineEntity> lines = [];

  String? lineProductId;
  final qtyController = TextEditingController(text: '1');
  final costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(supplierListProvider.notifier).load();
      ref.read(warehouseListProvider.notifier).load();
      ref.read(productListProvider.notifier).load();
    });
  }

  void _addLine() {
    final products = ref.read(productListProvider).products;
    if (lineProductId == null) return;
    final product = products.firstWhere((p) => p.id == lineProductId);
    final qty = int.tryParse(qtyController.text) ?? 0;
    final cost = double.tryParse(costController.text) ?? product.cost;
    if (qty <= 0) return;

    setState(() {
      lines.add(PurchaseLineEntity(
        productId: product.id,
        productName: product.name,
        quantity: qty,
        unitCost: cost,
      ));
      lineProductId = null;
      qtyController.text = '1';
      costController.text = '';
    });
  }

  double get total => lines.fold(0, (sum, l) => sum + l.lineTotal);

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierListProvider).suppliers;
    final warehouses = ref.watch(warehouseListProvider).warehouses;
    final products = ref.watch(productListProvider).products;
    final purchaseState = ref.watch(purchaseListProvider);

    ref.listen(purchaseListProvider, (previous, next) {
      if (next.lastTotal != null && previous?.lastTotal != next.lastTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase recorded! Total: ${next.lastTotal!.toStringAsFixed(2)}')),
        );
        Navigator.of(context).pop();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('New Purchase')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: supplierId,
              decoration: const InputDecoration(labelText: 'Supplier'),
              items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => supplierId = v),
            ),
            DropdownButtonFormField<String>(
              initialValue: warehouseId,
              decoration: const InputDecoration(labelText: 'Warehouse'),
              items: warehouses.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
              onChanged: (v) => setState(() => warehouseId = v),
            ),
            const Divider(height: 32),
            const Align(alignment: Alignment.centerLeft, child: Text('Add product line', style: TextStyle(fontWeight: FontWeight.bold))),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: lineProductId,
                    decoration: const InputDecoration(labelText: 'Product'),
                    items: products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                    onChanged: (v) => setState(() => lineProductId = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: costController,
                    decoration: const InputDecoration(labelText: 'Cost'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(icon: const Icon(Icons.add_circle), onPressed: _addLine),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  final l = lines[index];
                  return ListTile(
                    title: Text(l.productName),
                    subtitle: Text('${l.quantity} × ${l.unitCost.toStringAsFixed(2)}'),
                    trailing: Text(l.lineTotal.toStringAsFixed(2)),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Total: ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            purchaseState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: (supplierId == null || warehouseId == null || lines.isEmpty)
                  ? null
                  : () => ref.read(purchaseListProvider.notifier).submit(
                supplierId: supplierId!,
                warehouseId: warehouseId!,
                lines: lines,
              ),
              child: const Text('Confirm Purchase'),
            ),
          ],
        ),
      ),
    );
  }
}