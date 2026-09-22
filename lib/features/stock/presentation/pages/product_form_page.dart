import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../providers/product_provider.dart';

/// Tunisian VAT rates.
const _vatRates = [0.0, 7.0, 13.0, 19.0];

/// Full-page product form. Pops with a [ProductInput] on save, or null when
/// the user backs out. One field per row so no label is ever truncated.
class ProductFormPage extends ConsumerStatefulWidget {
  final ProductEntity? existing;

  const ProductFormPage({super.key, this.existing});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  late final TextEditingController skuController;
  late final TextEditingController barcodeController;
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;
  late final TextEditingController costController;
  late final TextEditingController minController;
  late final TextEditingController maxController;
  late final TextEditingController shelfController;
  late final TextEditingController unitController;
  late final TextEditingController purchaseUnitController;
  late final TextEditingController unitsPerPurchaseController;
  late final TextEditingController notesController;

  String? categoryId;
  String? supplierId;
  double vatRate = 19;
  bool isActive = true;

  bool get isEdit => widget.existing != null;
  bool get canSave => nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    skuController = TextEditingController(text: e?.sku ?? '');
    barcodeController = TextEditingController(text: e?.barcode ?? '');
    nameController = TextEditingController(text: e?.name ?? '')
      ..addListener(() => setState(() {}));
    descriptionController =
        TextEditingController(text: e?.description ?? '');
    priceController = TextEditingController(
        text: e != null ? e.price.toStringAsFixed(3) : '');
    costController = TextEditingController(
        text: e != null ? e.cost.toStringAsFixed(3) : '');
    minController =
        TextEditingController(text: (e?.minThreshold ?? 0).toString());
    maxController =
        TextEditingController(text: e?.maxThreshold?.toString() ?? '');
    shelfController = TextEditingController(text: e?.shelfLocation ?? '');
    unitController = TextEditingController(text: e?.unit ?? 'unit');
    purchaseUnitController =
        TextEditingController(text: e?.purchaseUnit ?? '');
    unitsPerPurchaseController =
        TextEditingController(text: (e?.unitsPerPurchase ?? 1).toString());
    notesController = TextEditingController(text: e?.notes ?? '');

    categoryId = e?.categoryId;
    supplierId = e?.defaultSupplierId;
    vatRate = e?.vatRate ?? 19;
    isActive = e?.isActive ?? true;

    Future.microtask(() {
      ref.read(categoryListProvider.notifier).load();
      ref.read(supplierListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    for (final c in [
      skuController,
      barcodeController,
      nameController,
      descriptionController,
      priceController,
      costController,
      minController,
      maxController,
      shelfController,
      unitController,
      purchaseUnitController,
      unitsPerPurchaseController,
      notesController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _orNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  /// Accepts both "12.5" and "12,5" — French keyboards use a comma.
  double? _decimal(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  void _save() {
    if (!canSave) return;

    Navigator.of(context).pop(ProductInput(
      sku: _orNull(skuController),
      name: nameController.text.trim(),
      description: _orNull(descriptionController),
      categoryId: categoryId,
      defaultSupplierId: supplierId,
      barcode: _orNull(barcodeController),
      price: _decimal(priceController) ?? 0,
      cost: _decimal(costController) ?? 0,
      vatRate: vatRate,
      minThreshold: int.tryParse(minController.text.trim()) ?? 0,
      maxThreshold: int.tryParse(maxController.text.trim()),
      shelfLocation: _orNull(shelfController),
      isActive: isActive,
      notes: _orNull(notesController),
      unit: unitController.text.trim().isEmpty
          ? 'unit'
          : unitController.text.trim(),
      purchaseUnit: _orNull(purchaseUnitController),
      unitsPerPurchase:
      int.tryParse(unitsPerPurchaseController.text.trim()) ?? 1,
    ));
  }

  // ── Building blocks ──

  Widget _section(String title, List<Widget> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: AppTheme.font(size: 16, weight: FontWeight.w600),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              for (var i = 0; i < fields.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                fields[i],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        IconData? icon,
        TextInputType? keyboard,
        int maxLines = 1,
        String? suffix,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: AppTheme.font(size: 15),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixText: suffix,
        suffixStyle: AppTheme.font(size: 14, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _dropdown<T>({
    required Key key,
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      key: key,
      initialValue: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      style: AppTheme.font(size: 15),
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      icon: const Icon(Icons.expand_more, color: AppColors.iconMuted),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoryListProvider).categories;
    final suppliers = ref.watch(supplierListProvider).suppliers;

    // The dropdowns only accept a value that is in their item list. Until the
    // lists load, show "none"; the key forces a rebuild once they arrive.
    final safeCategory =
    categories.any((c) => c.id == categoryId) ? categoryId : null;
    final safeSupplier =
    suppliers.any((s) => s.id == supplierId) ? supplierId : null;
    final vatOptions = {..._vatRates, vatRate}.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: isEdit ? l10n.editProduct : l10n.newProduct,
        subtitle: isEdit ? widget.existing!.name : null,
        icon: Icons.inventory_2_outlined,
        color: AppColors.stock,
        showMenuButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _section(l10n.generalInfo, [
            _field(nameController, l10n.name,
                icon: Icons.label_outline),
            _field(skuController, l10n.sku, icon: Icons.tag),
            _field(barcodeController, l10n.barcode,
                icon: Icons.qr_code_2),
            _field(descriptionController, l10n.description, maxLines: 3),
            _dropdown<String?>(
              key: ValueKey('category-${categories.length}'),
              label: l10n.category,
              icon: Icons.category_outlined,
              value: safeCategory,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.noCategory),
                ),
                ...categories.map((c) => DropdownMenuItem<String?>(
                  value: c.id,
                  child: Text(c.name, maxLines: 1),
                )),
              ],
              onChanged: (v) => setState(() => categoryId = v),
            ),
            _dropdown<String?>(
              key: ValueKey('supplier-${suppliers.length}'),
              label: l10n.defaultSupplier,
              icon: Icons.local_shipping_outlined,
              value: safeSupplier,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('—'),
                ),
                ...suppliers.map((s) => DropdownMenuItem<String?>(
                  value: s.id,
                  child: Text(s.name, maxLines: 1),
                )),
              ],
              onChanged: (v) => setState(() => supplierId = v),
            ),
          ]),

          const SizedBox(height: 24),
          _section(l10n.pricingAndVat, [
            _field(priceController, l10n.priceHt,
                icon: Icons.sell_outlined,
                keyboard:
                const TextInputType.numberWithOptions(decimal: true),
                suffix: 'DT'),
            _field(costController, l10n.cost,
                icon: Icons.shopping_bag_outlined,
                keyboard:
                const TextInputType.numberWithOptions(decimal: true),
                suffix: 'DT'),
            _dropdown<double>(
              key: const ValueKey('vat'),
              label: l10n.vatRate,
              icon: Icons.percent,
              value: vatRate,
              items: vatOptions
                  .map((r) => DropdownMenuItem<double>(
                value: r,
                child: Text('${r.toStringAsFixed(0)} %'),
              ))
                  .toList(),
              onChanged: (v) => setState(() => vatRate = v ?? 19),
            ),
          ]),

          const SizedBox(height: 24),
          _section(l10n.stockSettings, [
            _field(minController, l10n.minThreshold,
                icon: Icons.south, keyboard: TextInputType.number),
            _field(maxController, l10n.maxThreshold,
                icon: Icons.north, keyboard: TextInputType.number),
            _field(shelfController, l10n.shelfLocation,
                icon: Icons.place_outlined),
          ]),

          const SizedBox(height: 24),
          _section(l10n.unitsAndPackaging, [
            _field(unitController, l10n.saleUnit,
                icon: Icons.straighten),
            _field(purchaseUnitController, l10n.purchaseUnit,
                icon: Icons.all_inbox_outlined),
            _field(unitsPerPurchaseController, l10n.unitsPerPurchase,
                icon: Icons.numbers, keyboard: TextInputType.number),
          ]),

          const SizedBox(height: 24),
          _section(l10n.notes, [
            _field(notesController, l10n.notes, maxLines: 3),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isActive,
              title: Text(l10n.productActive,
                  style: AppTheme.font(size: 15)),
              onChanged: (v) => setState(() => isActive = v),
            ),
          ]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.canvas,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: FilledButton(
            onPressed: canSave ? _save : null,
            child: Text(l10n.save),
          ),
        ),
      ),
    );
  }
}