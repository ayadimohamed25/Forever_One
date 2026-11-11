import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_lines_table.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../stock/presentation/providers/product_provider.dart';
import '../../../stock/presentation/providers/warehouse_provider.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';
import '../../domain/entities/purchase_line_entity.dart';
import '../providers/purchase_provider.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../core/errors/error_text.dart';

class CreatePurchasePage extends ConsumerStatefulWidget {
  /// When set, the page edits that purchase instead of creating a new one.
  final String? existingPurchaseId;

  const CreatePurchasePage({super.key, this.existingPurchaseId});

  @override
  ConsumerState<CreatePurchasePage> createState() =>
      _CreatePurchasePageState();
}

class _CreatePurchasePageState extends ConsumerState<CreatePurchasePage> {
  String? supplierId;
  String? warehouseId;
  String? lineProductId;
  String status = 'received';

  /// Bumped after each added line so the product picker resets to empty.
  int lineFormVersion = 0;

  final referenceController = TextEditingController();
  final notesController = TextEditingController();
  final qtyController = TextEditingController(text: '1');
  final costController = TextEditingController();
  final List<PurchaseLineEntity> lines = [];

  bool get isEditing => widget.existingPurchaseId != null;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(supplierListProvider.notifier).load();
      ref.read(warehouseListProvider.notifier).load();
      ref.read(productListProvider.notifier).load();

      if (isEditing) {
        final result = await ref
            .read(purchaseRepositoryProvider)
            .getPurchaseDetail(widget.existingPurchaseId!);
        if (!mounted) return;
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

  double get subtotalHt => lines.fold(0, (sum, l) => sum + l.lineTotal);
  double get totalVat => lines.fold(0, (sum, l) => sum + l.vatAmount);
  double get totalTtc => subtotalHt + totalVat;

  int get _qty => int.tryParse(qtyController.text.trim()) ?? 0;

  /// Accepts "8.2" and "8,2" — French keyboards use a comma.
  double? get _cost =>
      double.tryParse(costController.text.trim().replaceAll(',', '.'));

  bool get _canAddLine => lineProductId != null && _qty > 0;

  bool get _canSubmit =>
      supplierId != null && warehouseId != null && lines.isNotEmpty;

  String? _orNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  void _showSnack(String message, {bool isError = false}) {
    AppSnack.show(context, message, error: isError);
  }

  void _selectProduct(String? id) {
    final product = ref
        .read(productListProvider)
        .products
        .where((p) => p.id == id)
        .firstOrNull;
    setState(() {
      lineProductId = id;
      // Pre-fill with the product's usual cost; the user can still change it.
      if (product != null) costController.text = product.cost.toStringAsFixed(2);
    });
  }

  void _addLine() {
    if (!_canAddLine) return;
    final product = ref
        .read(productListProvider)
        .products
        .where((p) => p.id == lineProductId)
        .firstOrNull;
    if (product == null) return;

    setState(() {
      lines.add(PurchaseLineEntity(
        productId: product.id,
        productName: product.name,
        quantity: _qty,
        unitCost: _cost ?? product.cost,
        vatRate: product.vatRate,
      ));
      lineProductId = null;
      lineFormVersion++;
      qtyController.text = '1';
      costController.clear();
    });
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_canSubmit) return;

    if (isEditing) {
      final error = await ref.read(purchaseListProvider.notifier).edit(
        id: widget.existingPurchaseId!,
        supplierId: supplierId!,
        warehouseId: warehouseId!,
        reference: _orNull(referenceController),
        notes: _orNull(notesController),
        lines: lines,
      );
      if (!mounted) return;
      if (error == null) {
        Navigator.of(context).pop(true);
      } else if (error == 'PURCHASE_HAS_PAYMENTS') {
        _showSnack(l10n.purchaseHasPayments, isError: true);
      } else {
        _showSnack(errorText(error, l10n), isError: true);
      }
      return;
    }

    await ref.read(purchaseListProvider.notifier).submit(
      supplierId: supplierId!,
      warehouseId: warehouseId!,
      reference: _orNull(referenceController),
      notes: _orNull(notesController),
      status: status,
      lines: lines,
    );
  }

  Widget _totalRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTheme.label)),
          Text(
            formatDT(value),
            style: AppTheme.font(
                size: 14, weight: FontWeight.w500, tabularFigures: true),
          ),
        ],
      ),
    );
  }

  Widget _totalsBar(AppLocalizations l10n, bool isLoading) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _totalRow(l10n.subtotalHt, subtotalHt),
              _totalRow(l10n.totalVat, totalVat),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.totalTtc,
                      style: AppTheme.font(size: 14, weight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    formatDT(totalTtc),
                    style: AppTheme.font(
                      size: 18,
                      weight: FontWeight.w600,
                      tabularFigures: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              isLoading
                  ? const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              )
                  : AppBlockButton(child: FilledButton(
                onPressed: _canSubmit ? () => _submit(l10n) : null,
                child: Text(l10n.confirmPurchase),
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final suppliers = ref.watch(supplierListProvider).suppliers;
    final warehouses = ref.watch(warehouseListProvider).warehouses;
    final products = ref
        .watch(productListProvider)
        .products
        .where((p) => p.isActive)
        .toList();
    final purchaseState = ref.watch(purchaseListProvider);

    ref.listen(purchaseListProvider, (previous, next) {
      if (!isEditing &&
          next.lastTotal != null &&
          previous?.lastTotal != next.lastTotal) {
        _showSnack(l10n.purchaseRecorded(formatAmount(next.lastTotal!)));
        Navigator.of(context).pop();
      }
      if (next.error != null) _showSnack(errorText(next.error, l10n), isError: true);
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: isEditing ? l10n.editPurchase : l10n.newPurchase,
        subtitle: lines.isEmpty
            ? null
            : '${l10n.linesCount(lines.length)} · ${formatDT(totalTtc)}',
        icon: Icons.shopping_cart_outlined,
        color: AppColors.purchases,
        showMenuButton: false,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          AppFormSection(
            title: l10n.invoiceDetails,
            children: [
              AppDropdown<String>(
                key: ValueKey('suppliers-${suppliers.length}'),
                label: l10n.supplier,
                icon: Icons.local_shipping_outlined,
                value:
                suppliers.any((s) => s.id == supplierId) ? supplierId : null,
                items: [
                  for (final s in suppliers)
                    DropdownMenuItem<String>(
                      value: s.id,
                      child: Text(s.name, maxLines: 1),
                    ),
                ],
                onChanged: (v) => setState(() => supplierId = v),
              ),
              AppDropdown<String>(
                key: ValueKey('warehouses-${warehouses.length}'),
                label: l10n.warehouse,
                icon: Icons.warehouse_outlined,
                value: warehouses.any((w) => w.id == warehouseId)
                    ? warehouseId
                    : null,
                items: [
                  for (final w in warehouses)
                    DropdownMenuItem<String>(
                      value: w.id,
                      child: Text(w.name, maxLines: 1),
                    ),
                ],
                onChanged: (v) => setState(() => warehouseId = v),
              ),
              AppTextField(
                controller: referenceController,
                label: '${l10n.reference} (${l10n.optional})',
                icon: Icons.tag,
              ),
              // Delivery status is chosen when creating; editing keeps it.
              if (isEditing)
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppBadge(
                    label: status == 'received'
                        ? l10n.received
                        : l10n.pendingDelivery,
                    tone: status == 'received'
                        ? BadgeTone.success
                        : BadgeTone.warning,
                  ),
                )
              else
                AppSegmentedControl<String>(
                  options: [
                    (
                    value: 'received',
                    label: l10n.received,
                    icon: Icons.check_circle_outline
                    ),
                    (
                    value: 'draft',
                    label: l10n.pendingDelivery,
                    icon: Icons.schedule
                    ),
                  ],
                  selected: status,
                  onChanged: (v) => setState(() => status = v),
                ),
            ],
          ),

          AppFormSection(
            title: l10n.addProductLine,
            children: [
              AppDropdown<String>(
                key: ValueKey('line-product-$lineFormVersion-${products.length}'),
                label: l10n.product,
                icon: Icons.inventory_2_outlined,
                value: lineProductId,
                items: [
                  for (final p in products)
                    DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(p.name, maxLines: 1),
                    ),
                ],
                onChanged: _selectProduct,
              ),
              AppTextField(
                controller: qtyController,
                label: l10n.quantity,
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              AppTextField(
                controller: costController,
                label: l10n.unitCost,
                icon: Icons.sell_outlined,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                suffix: 'DT',
              ),
              AppBlockButton(height: 48, child: OutlinedButton.icon(
                onPressed: _canAddLine ? _addLine : null,
                icon: const Icon(Icons.add),
                label: Text(l10n.product),
              )),
            ],
          ),

          const SizedBox(height: 24),

          AppLinesTable(
            title: lines.isEmpty ? l10n.noLines : l10n.linesCount(lines.length),
            emptyText: l10n.addAtLeastOneProduct,
            priceLabel: l10n.cost,
            rows: [
              for (final l in lines)
                AppLineRow(
                  product: l.productName,
                  quantity: l.quantity,
                  unitPrice: l.unitCost,
                  total: l.lineTotal,
                ),
            ],
            onRemove: (i) => setState(() => lines.removeAt(i)),
          ),
          AppFormSection(
            title: l10n.notes,
            children: [
              AppTextField(
                controller: notesController,
                label: '${l10n.notes} (${l10n.optional})',
                maxLines: 3,
              ),
            ],
          ),
        ],
      ),
        ),
      ),
      bottomNavigationBar: _totalsBar(l10n, purchaseState.isLoading),
    );
  }
}