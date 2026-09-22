import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
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
        _showSnack(error, isError: true);
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

  Widget _lineCard(int index, PurchaseLineEntity l, AppLocalizations l10n) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLeadingTile.icon(Icons.inventory_2_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.productName, style: AppTheme.rowTitle, maxLines: 2),
                const SizedBox(height: 4),
                Text(
                  '${l.quantity} × ${formatDT(l.unitCost)} · '
                      '${l10n.lineVat} ${l.vatRate.toStringAsFixed(0)}%',
                  style: AppTheme.label,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatDT(l.lineTotalTtc), style: AppTheme.money),
              const SizedBox(height: 3),
              Text(
                '${formatDT(l.lineTotal)} ${l10n.exclVatShort}',
                style: AppTheme.font(
                  size: 12,
                  color: AppColors.textSecondary,
                  tabularFigures: true,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
            onPressed: () => setState(() => lines.removeAt(index)),
          ),
        ],
      ),
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
        border: Border(top: BorderSide(color: AppColors.track)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
                      style: AppTheme.font(size: 15, weight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    formatDT(totalTtc),
                    style: AppTheme.font(
                      size: 22,
                      weight: FontWeight.w700,
                      letterSpacing: -0.5,
                      tabularFigures: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              isLoading
                  ? const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              )
                  : FilledButton(
                onPressed: _canSubmit ? () => _submit(l10n) : null,
                child: Text(l10n.confirmPurchase),
              ),
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
        _showSnack(l10n.purchaseRecorded(next.lastTotal!.toStringAsFixed(2)));
        Navigator.of(context).pop();
      }
      if (next.error != null) _showSnack(next.error!, isError: true);
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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

          const SizedBox(height: 24),

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
              OutlinedButton.icon(
                onPressed: _canAddLine ? _addLine : null,
                icon: const Icon(Icons.add),
                label: Text(l10n.product),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              lines.isEmpty ? l10n.noLines : l10n.linesCount(lines.length),
              style: AppTheme.font(size: 16, weight: FontWeight.w600),
            ),
          ),
          if (lines.isEmpty)
            AppCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Icon(Icons.inventory_outlined,
                        size: 36, color: AppColors.textMuted),
                    const SizedBox(height: 10),
                    Text(
                      l10n.addAtLeastOneProduct,
                      textAlign: TextAlign.center,
                      style: AppTheme.label,
                    ),
                  ],
                ),
              ),
            )
          else
            for (var i = 0; i < lines.length; i++)
              _lineCard(i, lines[i], l10n),

          const SizedBox(height: 12),
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
      bottomNavigationBar: _totalsBar(l10n, purchaseState.isLoading),
    );
  }
}