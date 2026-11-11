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
import '../../../../shared/widgets/app_widgets.dart';

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

  Widget _section(String title, List<Widget> fields) =>
      AppFormSection(title: title, children: fields);

  /// Two short fields side by side (stacked on very narrow phones).
  Widget _pair(Widget left, Widget right) => LayoutBuilder(
        builder: (context, box) => box.maxWidth >= 360
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 12),
                  Expanded(child: right),
                ],
              )
            : Column(children: [left, const SizedBox(height: 14), right]),
      );

  Widget _field(
      TextEditingController controller,
      String label, {
        IconData? icon,
        TextInputType? keyboard,
        int maxLines = 1,
        String? suffix,
        bool required = false,
      }) {
    return AppLabeledField(label: label, required: required, child: TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: AppTheme.font(size: 14),
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        suffixText: suffix,
        suffixStyle: AppTheme.font(size: 14, color: AppColors.textSecondary),
      ),
    ));
  }

  Widget _dropdown<T>({
    required Key key,
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return AppLabeledField(label: label, child: DropdownButtonFormField<T>(
      key: key,
      initialValue: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      style: AppTheme.font(size: 14),
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.control),
      icon: const Icon(Icons.expand_more, color: AppColors.iconMuted),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
      ),
    ));
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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          _section(l10n.generalInfo, [
            _field(nameController, l10n.name, required: true),
            _pair(
              _field(skuController, l10n.sku),
              _field(barcodeController, l10n.barcode),
            ),
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
          _section(l10n.pricingAndVat, [
            _pair(
              _field(priceController, l10n.priceHt,
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
            ),
            _field(costController, l10n.cost,
                keyboard:
                const TextInputType.numberWithOptions(decimal: true),
                suffix: 'DT'),
          ]),
          _section(l10n.stockSettings, [
            _pair(
              _field(minController, l10n.minThreshold,
                  keyboard: TextInputType.number),
              _field(maxController, l10n.maxThreshold,
                  keyboard: TextInputType.number),
            ),
            _field(shelfController, l10n.shelfLocation),
          ]),
          _section(l10n.unitsAndPackaging, [
            _pair(
              _field(unitController, l10n.saleUnit),
              _field(purchaseUnitController, l10n.purchaseUnit),
            ),
            _field(unitsPerPurchaseController, l10n.unitsPerPurchase,
                keyboard: TextInputType.number),
          ]),
          _section(l10n.notes, [
            _field(notesController, l10n.notes, maxLines: 3),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isActive,
              title: Text(l10n.productActive,
                  style: AppTheme.font(size: 14)),
              onChanged: (v) => setState(() => isActive = v),
            ),
          ]),
          const SizedBox(height: 4),
          Text('* ${l10n.requiredField}',
              style: AppTheme.font(size: 12, color: AppColors.textSecondary)),
        ],
      ),
      ),
      ),
      bottomNavigationBar: AppBottomActionBar(
        child: FilledButton(
          onPressed: canSave ? _save : null,
          child: Text(l10n.save),
        ),
      ),
    );
  }
}