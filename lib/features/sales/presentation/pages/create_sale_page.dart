import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../stock/presentation/providers/warehouse_provider.dart';
import '../../../stock/presentation/providers/product_provider.dart';
import '../../domain/entities/sale_line_entity.dart';
import '../providers/sale_provider.dart';

class CreateSalePage extends ConsumerStatefulWidget {
  const CreateSalePage({super.key});

  @override
  ConsumerState<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends ConsumerState<CreateSalePage> {
  String? customerId;
  String? warehouseId;
  final List<SaleLineEntity> lines = [];

  String? lineProductId;
  final qtyController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customerListProvider.notifier).load();
      ref.read(warehouseListProvider.notifier).load();
      ref.read(productListProvider.notifier).load();
    });
  }

  void _addLine() {
    final products = ref.read(productListProvider).products;
    if (lineProductId == null) return;
    final product = products.firstWhere((p) => p.id == lineProductId);
    final qty = int.tryParse(qtyController.text) ?? 0;
    if (qty <= 0) return;

    setState(() {
      lines.add(SaleLineEntity(
        productId: product.id,
        productName: product.name,
        quantity: qty,
        unitPrice: product.price,
      ));
      lineProductId = null;
      qtyController.text = '1';
    });
  }

  double get total => lines.fold(0, (sum, l) => sum + l.lineTotal);

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerListProvider).customers;
    final warehouses = ref.watch(warehouseListProvider).warehouses;
    final products = ref.watch(productListProvider).products;
    final saleState = ref.watch(saleListProvider);

    ref.listen(saleListProvider, (previous, next) {
      if (next.lastTotal != null && previous?.lastTotal != next.lastTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sale created! Total: ${next.lastTotal!.toStringAsFixed(2)}')),
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
      appBar: AppBar(title: const Text('New Sale')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: customerId,
              decoration: const InputDecoration(labelText: 'Customer'),
              items: customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => customerId = v),
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
                    subtitle: Text('${l.quantity} × ${l.unitPrice.toStringAsFixed(2)}'),
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
            saleState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: (customerId == null || warehouseId == null || lines.isEmpty)
                  ? null
                  : () => ref.read(saleListProvider.notifier).submit(
                customerId: customerId!,
                warehouseId: warehouseId!,
                lines: lines,
              ),
              child: const Text('Confirm Sale'),
            ),
          ],
        ),
      ),
    );
  }
}