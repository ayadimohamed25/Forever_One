import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/product_entity.dart';

class ProductFormResult {
  final String name;
  final String? barcode;
  final double price;
  final double cost;
  final int minThreshold;
  final String unit;

  const ProductFormResult({
    required this.name,
    this.barcode,
    required this.price,
    required this.cost,
    required this.minThreshold,
    required this.unit,
  });
}

/// Shows the create/edit product form.
/// Pass [existing] to edit; leave null to create.
Future<ProductFormResult?> showProductFormDialog(
    BuildContext context, {
      ProductEntity? existing,
    }) {
  final l10n = AppLocalizations.of(context)!;
  final isEdit = existing != null;

  final nameController = TextEditingController(text: existing?.name ?? '');
  final barcodeController = TextEditingController(text: existing?.barcode ?? '');
  final priceController =
  TextEditingController(text: existing != null ? existing.price.toStringAsFixed(2) : '');
  final costController =
  TextEditingController(text: existing != null ? existing.cost.toStringAsFixed(2) : '');
  final thresholdController =
  TextEditingController(text: (existing?.minThreshold ?? 0).toString());
  final unitController = TextEditingController(text: existing?.unit ?? 'unit');

  return showDialog<ProductFormResult>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? l10n.editProduct : l10n.newProduct),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: !isEdit,
              decoration: InputDecoration(
                labelText: l10n.name,
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: barcodeController,
              decoration: InputDecoration(
                labelText: l10n.barcode,
                prefixIcon: const Icon(Icons.qr_code_2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: l10n.price),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: costController,
                    decoration: InputDecoration(labelText: l10n.cost),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: thresholdController,
                    decoration: InputDecoration(labelText: l10n.minThreshold),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    decoration: InputDecoration(labelText: l10n.unit),
                  ),
                ),
              ],
            ),
          ],
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
            Navigator.of(context).pop(ProductFormResult(
              name: nameController.text.trim(),
              barcode: barcodeController.text.trim().isEmpty
                  ? null
                  : barcodeController.text.trim(),
              price: double.tryParse(priceController.text) ?? 0,
              cost: double.tryParse(costController.text) ?? 0,
              minThreshold: int.tryParse(thresholdController.text) ?? 0,
              unit: unitController.text.trim().isEmpty
                  ? 'unit'
                  : unitController.text.trim(),
            ));
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}