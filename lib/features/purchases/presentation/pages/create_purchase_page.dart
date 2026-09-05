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
    final theme = Theme.of(context);

    ref.listen(purchaseListProvider, (previous, next) {
      if (next.lastTotal != null && previous?.lastTotal != next.lastTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Achat enregistré · Total ${next.lastTotal!.toStringAsFixed(2)} DT'),
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

    final canSubmit =
        supplierId != null && warehouseId != null && lines.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel achat')),
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
                            initialValue: supplierId,
                            decoration: InputDecoration(
                              labelText: 'Fournisseur',
                              prefixIcon:
                              const Icon(Icons.local_shipping_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            items: suppliers
                                .map((s) => DropdownMenuItem(
                                value: s.id, child: Text(s.name)))
                                .toList(),
                            onChanged: (v) => setState(() => supplierId = v),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: warehouseId,
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
                        style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: qtyController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantité',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: costController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Coût unitaire',
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
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (lines.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.inventory_outlined,
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
                          side:
                          BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.only(left: 14, right: 6),
                          title: Text(l.productName,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${l.quantity} × ${l.unitCost.toStringAsFixed(2)} DT',
                              style: const TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${l.lineTotal.toStringAsFixed(2)} DT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.tertiary,
                                  )),
                              IconButton(
                                icon: Icon(Icons.close,
                                    size: 18,
                                    color: theme.colorScheme.onSurfaceVariant),
                                onPressed: () =>
                                    setState(() => lines.removeAt(i)),
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
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    Text('${total.toStringAsFixed(2)} DT',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: purchaseState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton.icon(
                    onPressed: !canSubmit
                        ? null
                        : () => ref
                        .read(purchaseListProvider.notifier)
                        .submit(
                      supplierId: supplierId!,
                      warehouseId: warehouseId!,
                      lines: lines,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text("Confirmer l'achat",
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