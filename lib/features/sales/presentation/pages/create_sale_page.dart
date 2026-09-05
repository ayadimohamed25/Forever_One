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
    final theme = Theme.of(context);

    ref.listen(saleListProvider, (previous, next) {
      if (next.lastTotal != null && previous?.lastTotal != next.lastTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vente crÃ©Ã©e Â· Total ${next.lastTotal!.toStringAsFixed(2)} DT'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
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

    final canSubmit = customerId != null && warehouseId != null && lines.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle vente')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            initialValue: customerId,
                            decoration: InputDecoration(
                              labelText: 'Client',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            items: customers
                                .map((c) => DropdownMenuItem(
                                value: c.id, child: Text(c.name)))
                                .toList(),
                            onChanged: (v) => setState(() => customerId = v),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: warehouseId,
                            decoration: InputDecoration(
                              labelText: 'DÃ©pÃ´t',
                              prefixIcon: const Icon(Icons.warehouse_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            items: warehouses
                                .map((w) => DropdownMenuItem(
                                value: w.id, child: Text(w.name)))
                                .toList(),
                            onChanged: (v) => setState(() => warehouseId = v),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Ajouter un produit',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 10),

                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              initialValue: lineProductId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Produit',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              items: products
                                  .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name,
                                    overflow: TextOverflow.ellipsis),
                              ))
                                  .toList(),
                              onChanged: (v) => setState(() => lineProductId = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 64,
                            child: TextField(
                              controller: qtyController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'QtÃ©',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton.filled(
                            onPressed: _addLine,
                            icon: const Icon(Icons.add),
                            tooltip: 'Ajouter la ligne',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      lines.isEmpty
                          ? 'Aucune ligne'
                          : '${lines.length} ligne${lines.length > 1 ? "s" : ""}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (lines.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.shopping_basket_outlined,
                              size: 44, color: theme.colorScheme.outlineVariant),
                          const SizedBox(height: 10),
                          Text('Ajoutez au moins un produit',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13)),
                        ],
                      ),
                    )
                  else
                    ...lines.asMap().entries.map((entry) {
                      final i = entry.key;
                      final l = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.only(left: 14, right: 6),
                          title: Text(l.productName,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${l.quantity} Ã— ${l.unitPrice.toStringAsFixed(2)} DT',
                              style: const TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${l.lineTotal.toStringAsFixed(2)} DT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  )),
                              IconButton(
                                icon: Icon(Icons.close,
                                    size: 18,
                                    color: theme.colorScheme.onSurfaceVariant),
                                onPressed: () => setState(() => lines.removeAt(i)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          // Sticky total + submit
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    Text('${total.toStringAsFixed(2)} DT',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: saleState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton.icon(
                    onPressed: !canSubmit
                        ? null
                        : () => ref.read(saleListProvider.notifier).submit(
                      customerId: customerId!,
                      warehouseId: warehouseId!,
                      lines: lines,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmer la vente',
                        style: TextStyle(fontSize: 15)),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
