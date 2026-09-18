import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../providers/product_provider.dart';
import '../providers/stock_movement_provider.dart';
import '../providers/warehouse_provider.dart';

class StockMovementPage extends ConsumerStatefulWidget {
  const StockMovementPage({super.key});

  @override
  ConsumerState<StockMovementPage> createState() => _StockMovementPageState();
}

class _StockMovementPageState extends ConsumerState<StockMovementPage> {
  String? selectedProductId;
  String? selectedWarehouseId;
  String selectedType = 'in';
  final quantityController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productListProvider.notifier).load();
      ref.read(warehouseListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Map<String, ({String label, IconData icon, Color color})> _types(
      AppLocalizations l10n) {
    return {
      'in': (
      label: l10n.stockIn,
      icon: Icons.arrow_downward,
      color: AppColors.success
      ),
      'out': (
      label: l10n.stockOut,
      icon: Icons.arrow_upward,
      color: AppColors.danger
      ),
      'transfer': (
      label: l10n.transfer,
      icon: Icons.swap_horiz,
      color: AppColors.stock
      ),
      'correction': (
      label: l10n.correction,
      icon: Icons.tune,
      color: AppColors.warning
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider).products;
    final warehouses = ref.watch(warehouseListProvider).warehouses;
    final movementState = ref.watch(stockMovementProvider);
    final l10n = AppLocalizations.of(context)!;
    final types = _types(l10n);

    ref.listen(stockMovementProvider, (previous, next) {
      if (next.lastCurrentStock != null &&
          previous?.lastCurrentStock != next.lastCurrentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.movementRecorded(next.lastCurrentStock!)),
            backgroundColor: AppColors.success,
          ),
        );
        quantityController.clear();
        noteController.clear();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.error!), backgroundColor: AppColors.danger),
        );
      }
    });

    final canSubmit = selectedProductId != null &&
        selectedWarehouseId != null &&
        (int.tryParse(quantityController.text) ?? 0) > 0;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/stock-movement'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.stockMovement),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.movementType,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: types.entries.map((e) {
              final selected = selectedType == e.key;
              return InkWell(
                onTap: () => setState(() => selectedType = e.key),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: selected
                        ? AppColors.tintGradient(e.value.color)
                        : null,
                    color: selected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? e.value.color : AppColors.border,
                      width: selected ? 1.6 : 1,
                    ),
                    boxShadow: selected ? null : AppColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: selected
                              ? e.value.color
                              : e.value.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(e.value.icon,
                            size: 16,
                            color: selected ? Colors.white : e.value.color),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        e.value.label,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? e.value.color
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedProductId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.product,
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                  ),
                  items: products
                      .where((p) => p.isActive)
                      .map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(
                        '${p.name} · ${p.currentStock} ${p.unit}',
                        overflow: TextOverflow.ellipsis),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedProductId = v),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedWarehouseId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.warehouse,
                    prefixIcon: const Icon(Icons.warehouse_outlined),
                  ),
                  items: warehouses
                      .map((w) =>
                      DropdownMenuItem(value: w.id, child: Text(w.name)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedWarehouseId = v),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.quantity,
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: l10n.noteOptional,
                    prefixIcon: const Icon(Icons.notes),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 52,
            child: movementState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: types[selectedType]!.color),
              onPressed: !canSubmit
                  ? null
                  : () {
                final qty =
                    int.tryParse(quantityController.text) ?? 0;
                ref.read(stockMovementProvider.notifier).record(
                  productId: selectedProductId!,
                  warehouseId: selectedWarehouseId!,
                  type: selectedType,
                  quantity: qty,
                  note: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                );
              },
              icon: const Icon(Icons.check),
              label: Text(l10n.recordMovement,
                  style: const TextStyle(fontSize: 15)),
            ),
          ),

          if (movementState.lastCurrentStock != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.tintGradient(AppColors.success),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.currentStockAfter(movementState.lastCurrentStock!),
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}