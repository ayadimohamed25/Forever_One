import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../stock/presentation/providers/product_provider.dart';
import '../../../stock/presentation/providers/warehouse_provider.dart';
import '../../domain/entities/sale_line_entity.dart';
import '../providers/sale_provider.dart';
import '../../../../shared/widgets/app_page_header.dart';

class CreateSalePage extends ConsumerStatefulWidget {
  /// When set, the page edits that sale instead of creating a new one.
  final String? existingSaleId;

  const CreateSalePage({super.key, this.existingSaleId});

  @override
  ConsumerState<CreateSalePage> createState() => _CreateSalePageState();

}

class _CreateSalePageState extends ConsumerState<CreateSalePage> {
  bool isLoadingExisting = false;
  bool get isEditing => widget.existingSaleId != null;
  String? customerId;
  String? warehouseId;
  final referenceController = TextEditingController();
  final notesController = TextEditingController();
  final List<SaleLineEntity> lines = [];

  String? lineProductId;
  final qtyController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(customerListProvider.notifier).load();
      ref.read(warehouseListProvider.notifier).load();
      ref.read(productListProvider.notifier).load();

      if (widget.existingSaleId != null) {
        setState(() => isLoadingExisting = true);
        final result = await ref
            .read(saleRepositoryProvider)
            .getSaleDetail(widget.existingSaleId!);
        result.fold((_) {}, (detail) {
          setState(() {
            referenceController.text = detail.sale.reference ?? '';
            lines.addAll(detail.lines);
            isLoadingExisting = false;
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
    super.dispose();
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
        vatRate: product.vatRate,
      ));
      lineProductId = null;
      qtyController.text = '1';
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
                color:
                bold ? AppColors.textPrimary : AppColors.textSecondary,
              )),
          Text('${value.toStringAsFixed(3)} DT',
              style: TextStyle(
                fontSize: bold ? 20 : 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? AppColors.primary : AppColors.textPrimary,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerListProvider).customers;
    final warehouses = ref.watch(warehouseListProvider).warehouses;
    final products = ref.watch(productListProvider).products;
    final saleState = ref.watch(saleListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(saleListProvider, (previous, next) {
      if (next.lastTotal != null && previous?.lastTotal != next.lastTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saleCreated(next.lastTotal!.toStringAsFixed(3))),
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
        customerId != null && warehouseId != null && lines.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppPageHeader(
        title: isEditing ? l10n.editSale : l10n.newSale,
        subtitle: lines.isEmpty
            ? null
            : '${l10n.linesCount(lines.length)} · ${totalTtc.toStringAsFixed(2)} DT',
        icon: Icons.point_of_sale_rounded,
        color: AppColors.sales,
        showMenuButton: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Invoice details
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
                        initialValue: customerId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.customer,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        items: customers
                            .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name,
                                overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) => setState(() => customerId = v),
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
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Add line
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.addProductLine,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
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
                                child: Text(
                                    '${p.name} · ${p.price.toStringAsFixed(2)} DT',
                                    overflow: TextOverflow.ellipsis),
                              ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => lineProductId = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 70,
                            child: TextField(
                              controller: qtyController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.qty,
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
                        const Icon(Icons.shopping_basket_outlined,
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
                                  '${l.quantity} × ${l.unitPrice.toStringAsFixed(3)} · ${l10n.lineVat} ${l.vatRate.toStringAsFixed(0)}%',
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
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                              Text(
                                  '${l.lineTotal.toStringAsFixed(3)} HT',
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

          // Totals + submit
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
                  child: saleState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton.icon(
                    onPressed: !canSubmit
                        ? null
                        : () async {
                      if (isEditing) {
                        final error = await ref
                            .read(saleListProvider.notifier)
                            .edit(
                          id: widget.existingSaleId!,
                          customerId: customerId!,
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
                        if (error == 'SALE_HAS_PAYMENTS') {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                            content: Text(l10n.saleHasPayments),
                            backgroundColor: AppColors.danger,
                          ));
                        } else {
                          Navigator.of(context).pop(true);
                        }
                      } else {
                        ref.read(saleListProvider.notifier).submit(
                          customerId: customerId!,
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
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: Text(l10n.confirmSale),
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