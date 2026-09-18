import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../providers/product_provider.dart';

/// Tunisian VAT rates.
const _vatRates = [0.0, 7.0, 13.0, 19.0];

Future<ProductInput?> showProductFormDialog(
    BuildContext context,
    WidgetRef ref, {
      ProductEntity? existing,
    }) {
  final l10n = AppLocalizations.of(context)!;
  final isEdit = existing != null;

  // Make sure the dropdown sources are loaded.
  ref.read(categoryListProvider.notifier).load();
  ref.read(supplierListProvider.notifier).load();

  final skuController = TextEditingController(text: existing?.sku ?? '');
  final nameController = TextEditingController(text: existing?.name ?? '');
  final descriptionController =
  TextEditingController(text: existing?.description ?? '');
  final barcodeController = TextEditingController(text: existing?.barcode ?? '');
  final priceController = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(3) : '');
  final costController = TextEditingController(
      text: existing != null ? existing.cost.toStringAsFixed(3) : '');
  final minController =
  TextEditingController(text: (existing?.minThreshold ?? 0).toString());
  final maxController =
  TextEditingController(text: existing?.maxThreshold?.toString() ?? '');
  final shelfController =
  TextEditingController(text: existing?.shelfLocation ?? '');
  final unitController = TextEditingController(text: existing?.unit ?? 'unit');
  final purchaseUnitController =
  TextEditingController(text: existing?.purchaseUnit ?? '');
  final unitsPerPurchaseController =
  TextEditingController(text: (existing?.unitsPerPurchase ?? 1).toString());
  final notesController = TextEditingController(text: existing?.notes ?? '');

  var categoryId = existing?.categoryId;
  var supplierId = existing?.defaultSupplierId;
  var vatRate = existing?.vatRate ?? 19.0;
  var isActive = existing?.isActive ?? true;

  Widget sectionTitle(String text, IconData icon, Color color) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.2)),
      ],
    ),
  );

  return showDialog<ProductInput>(
    context: context,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final categories = ref.watch(categoryListProvider).categories;
        final suppliers = ref.watch(supplierListProvider).suppliers;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(isEdit ? l10n.editProduct : l10n.newProduct),
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle(
                        l10n.generalInfo, Icons.info_outline, AppColors.primary),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: skuController,
                            decoration: InputDecoration(labelText: l10n.sku),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: barcodeController,
                            decoration: InputDecoration(labelText: l10n.barcode),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      autofocus: !isEdit,
                      decoration: InputDecoration(labelText: l10n.name),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: l10n.description),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: categoryId,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.category),
                      items: [
                        DropdownMenuItem<String?>(
                            value: null, child: Text(l10n.noCategory)),
                        ...categories.map((c) => DropdownMenuItem<String?>(
                          value: c.id,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: c.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                  child: Text(c.name,
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        )),
                      ],
                      onChanged: (v) => setState(() => categoryId = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: supplierId,
                      isExpanded: true,
                      decoration:
                      InputDecoration(labelText: l10n.defaultSupplier),
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null, child: Text('—')),
                        ...suppliers.map((s) => DropdownMenuItem<String?>(
                          value: s.id,
                          child:
                          Text(s.name, overflow: TextOverflow.ellipsis),
                        )),
                      ],
                      onChanged: (v) => setState(() => supplierId = v),
                    ),

                    const Divider(height: 28),
                    sectionTitle(l10n.pricingAndVat, Icons.payments_outlined,
                        AppColors.sales),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: l10n.priceHt, suffixText: 'DT'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: costController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: l10n.cost, suffixText: 'DT'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<double>(
                      initialValue: vatRate,
                      decoration: InputDecoration(labelText: l10n.vatRate),
                      items: _vatRates
                          .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text('${r.toStringAsFixed(0)} %')))
                          .toList(),
                      onChanged: (v) => setState(() => vatRate = v ?? 19),
                    ),

                    const Divider(height: 28),
                    sectionTitle(l10n.stockSettings,
                        Icons.inventory_2_outlined, AppColors.stock),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minController,
                            keyboardType: TextInputType.number,
                            decoration:
                            InputDecoration(labelText: l10n.minThreshold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: maxController,
                            keyboardType: TextInputType.number,
                            decoration:
                            InputDecoration(labelText: l10n.maxThreshold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: shelfController,
                      decoration:
                      InputDecoration(labelText: l10n.shelfLocation),
                    ),

                    const Divider(height: 28),
                    sectionTitle(l10n.unitsAndPackaging,
                        Icons.all_inbox_outlined, AppColors.purchases),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: unitController,
                            decoration:
                            InputDecoration(labelText: l10n.saleUnit),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: purchaseUnitController,
                            decoration:
                            InputDecoration(labelText: l10n.purchaseUnit),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: unitsPerPurchaseController,
                      keyboardType: TextInputType.number,
                      decoration:
                      InputDecoration(labelText: l10n.unitsPerPurchase),
                    ),

                    const Divider(height: 28),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: l10n.notes),
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      title: Text(l10n.productActive,
                          style: const TextStyle(fontSize: 13.5)),
                      onChanged: (v) => setState(() => isActive = v),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;

                  String? orNull(TextEditingController c) =>
                      c.text.trim().isEmpty ? null : c.text.trim();

                  Navigator.of(context).pop(ProductInput(
                    sku: orNull(skuController),
                    name: nameController.text.trim(),
                    description: orNull(descriptionController),
                    categoryId: categoryId,
                    defaultSupplierId: supplierId,
                    barcode: orNull(barcodeController),
                    price: double.tryParse(priceController.text) ?? 0,
                    cost: double.tryParse(costController.text) ?? 0,
                    vatRate: vatRate,
                    minThreshold: int.tryParse(minController.text) ?? 0,
                    maxThreshold: int.tryParse(maxController.text),
                    shelfLocation: orNull(shelfController),
                    isActive: isActive,
                    notes: orNull(notesController),
                    unit: unitController.text.trim().isEmpty
                        ? 'unit'
                        : unitController.text.trim(),
                    purchaseUnit: orNull(purchaseUnitController),
                    unitsPerPurchase:
                    int.tryParse(unitsPerPurchaseController.text) ?? 1,
                  ));
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    ),
  );
}