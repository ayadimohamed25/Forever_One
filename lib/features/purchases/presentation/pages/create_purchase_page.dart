import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stock/presentation/providers/product_provider.dart';
import '../../../stock/presentation/providers/warehouse_provider.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';
import '../../domain/entities/purchase_line_entity.dart';
import '../providers/purchase_provider.dart';

class CreatePurchasePage extends ConsumerStatefulWidget {
  /// When set, the page edits that purchase instead of creating a new one.
  final String? existingPurchaseId;

  const CreatePurchasePage({super.key, this.existingPurchaseId});

  @override
  ConsumerState<CreatePurchasePage> createState() => _CreatePurchasePageState();
}

class _CreatePurchasePageState extends ConsumerState<CreatePurchasePage> {
  bool get isEditing => widget.existingPurchaseId != null;
  String? supplierId;
  String? warehouseId;
  String status = 'received';
  final referenceController = TextEditingController();
  final notesController = TextEditingController();
  final List<PurchaseLineEntity> lines = [];

  String? lineProductId;
  final qtyController = TextEditingController(text: '1');
  final costController = TextEditingController();

@override
void initState() {
super.initState();
Future.microtask(() async {
ref.read(supplierListProvider.notifier).load();
ref.read(warehouseListProvider.notifier).load();
ref.read(productListProvider.notifier).load();

if (widget.existingPurchaseId != null) {
final result = await ref
    .read(purchaseRepositoryProvider)
    .getPurchaseDetail(widget.existingPurchaseId!);
result.fold((_) {}, (detail) {
setState(() {
referenceController.text = detail.purchase.reference ?? '';
status = detail.purchase.status;
lines.addAll(detail.lines);
});
});
}
});
}

  @override
  void dispose() {
    referenceController.dispose();
    notesController.dispose();
    qtyController.dispose();
    costController.dispose();
    super.dispose();
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
        vatRate: product.vatRate,
      ));
      lineProductId = null;
      qtyController.text = '1';
      costController.text = '';
    });
  }

  double get subtotalHt => lines.fold(0, (sum, l) => sum + l.lineTotal);
  double get totalVat => lines.fold(0, (sum, l) => sum + l.vatAmount);
  double get totalTtc => subtotalHt + totalVat;

  Widget _totalRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: bold ? 15 : 12.5,
                fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
                color: bold ? AppColors.textPrimary : AppColors.textSecondary,
              )),
          Text('${value.toStringAsFixed(3)} DT',
              style: TextStyle(
                fontSize: bold ? 20 : 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? AppColors.purchases : AppColors.textPrimary,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierListProvider).suppliers;
    final warehouses = ref.watch(warehouseListProvider).warehouses;
    final products = ref.watch(productListProvider).products;
    final purchaseState = ref.watch(purchaseListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(purchaseListProvider, (previous, next) {
      if (next.lastTotal != null && previous?.lastTotal != next.lastTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text(l10n.purchaseRecorded(next.lastTotal!.toStringAsFixed(3))),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.error!), backgroundColor: AppColors.danger),
        );
      }
    });

    final canSubmit =
        supplierId != null && warehouseId != null && lines.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(isEditing ? l10n.editPurchase : l10n.newPurchase),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: supplierId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.supplier,
                          prefixIcon:
                          const Icon(Icons.local_shipping_outlined),
                        ),
                        items: suppliers
                            .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name,
                                overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) => setState(() => supplierId = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: warehouseId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.warehouse,
                          prefixIcon: const Icon(Icons.warehouse_outlined),
                        ),
                        items: warehouses
                            .map((w) => DropdownMenuItem(
                            value: w.id, child: Text(w.name)))
                            .toList(),
                        onChanged: (v) => setState(() => warehouseId = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: referenceController,
                        decoration: InputDecoration(
                          labelText: '${l10n.reference} (${l10n.optional})',
                          prefixIcon: const Icon(Icons.tag),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'received',
                            label: Text(l10n.received,
                                style: const TextStyle(fontSize: 12)),
                            icon: const Icon(Icons.check_circle_outline,
                                size: 15),
                          ),
                          ButtonSegment(
                            value: 'draft',
                            label: Text(l10n.pendingDelivery,
                                style: const TextStyle(fontSize: 12)),
                            icon: const Icon(Icons.schedule, size: 15),
                          ),
                        ],
                        selected: {status},
                        showSelectedIcon: false,
                        onSelectionChanged: (s) =>
                            setState(() => status = s.first),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.purchases.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.purchases.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.addProductLine,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.purchases)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: lineProductId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.product,
                          isDense: true,
                          fillColor: Colors.white,
                        ),
                        items: products
                            .where((p) => p.isActive)
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
                              decoration: InputDecoration(
                                labelText: l10n.quantity,
                                isDense: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: costController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.unitCost,
                                isDense: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton.filled(
                            onPressed: _addLine,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  lines.isEmpty ? l10n.noLines : l10n.linesCount(lines.length),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),

                if (lines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_outlined,
                            size: 42, color: AppColors.border),
                        const SizedBox(height: 10),
                        Text(l10n.addAtLeastOneProduct,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                else
                  ...lines.asMap().entries.map((entry) {
                    final i = entry.key;
                    final l = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.productName,
                                    style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(
                                  '${l.quantity} × ${l.unitCost.toStringAsFixed(3)} · ${l10n.lineVat} ${l.vatRate.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${l.lineTotalTtc.toStringAsFixed(3)} DT',
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.purchases)),
                              Text('${l.lineTotal.toStringAsFixed(3)} HT',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: AppColors.textSecondary),
                            onPressed: () => setState(() => lines.removeAt(i)),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: '${l10n.notes} (${l10n.optional})',
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                _totalRow(l10n.subtotalHt, subtotalHt),
                _totalRow(l10n.totalVat, totalVat),
                const Divider(height: 14),
                _totalRow(l10n.totalTtc, totalTtc, bold: true),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: purchaseState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purchases),
onPressed: !canSubmit
? null
    : () async {
if (isEditing) {
final error = await ref
    .read(purchaseListProvider.notifier)
    .edit(
id: widget.existingPurchaseId!,
supplierId: supplierId!,
warehouseId: warehouseId!,
reference: referenceController
    .text.trim().isEmpty
? null
    : referenceController.text.trim(),
notes: notesController
    .text.trim().isEmpty
? null
    : notesController.text.trim(),
lines: lines,
);
if (!context.mounted) return;
if (error == 'PURCHASE_HAS_PAYMENTS') {
ScaffoldMessenger.of(context)
    .showSnackBar(SnackBar(
content: Text(l10n.purchaseHasPayments),
backgroundColor: AppColors.danger,
));
} else {
Navigator.of(context).pop(true);
}
} else {
ref
    .read(purchaseListProvider.notifier)
    .submit(
supplierId: supplierId!,
warehouseId: warehouseId!,
reference: referenceController
    .text.trim().isEmpty
? null
    : referenceController.text.trim(),
notes: notesController
    .text.trim().isEmpty
? null
    : notesController.text.trim(),
status: status,
lines: lines,
);
}
},
                    icon: const Icon(Icons.check),
                    label: Text(l10n.confirmPurchase),
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