import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/product_provider.dart';
import '../providers/stock_movement_provider.dart';
import '../providers/warehouse_provider.dart';

typedef _MovementType = ({String label, IconData icon, Color color});

class StockMovementPage extends ConsumerStatefulWidget {
  const StockMovementPage({super.key});

  @override
  ConsumerState<StockMovementPage> createState() => _StockMovementPageState();
}

class _StockMovementPageState extends ConsumerState<StockMovementPage> {
  String? productId;
  String? warehouseId;
  String type = 'in';
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

  /// Each movement type carries its own meaning colour.
  Map<String, _MovementType> _types(AppLocalizations l10n) => {
    'in': (
    label: l10n.stockIn,
    icon: Icons.south_west,
    color: AppColors.success
    ),
    'out': (
    label: l10n.stockOut,
    icon: Icons.north_east,
    color: AppColors.danger
    ),
    'transfer': (
    label: l10n.transfer,
    icon: Icons.swap_horiz,
    color: AppColors.accent
    ),
    'correction': (
    label: l10n.correction,
    icon: Icons.tune,
    color: AppColors.warning
    ),
  };

  bool get _canSubmit =>
      productId != null &&
          warehouseId != null &&
          (int.tryParse(quantityController.text.trim()) ?? 0) > 0;

  void _submit() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    ref.read(stockMovementProvider.notifier).record(
      productId: productId!,
      warehouseId: warehouseId!,
      type: type,
      quantity: int.parse(quantityController.text.trim()),
      note: noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
    );
  }

  /// Selected: 1.5px border and soft background in the type's own colour.
  Widget _typeCard(String key, _MovementType t) {
    final selected = type == key;

    return Material(
      color: selected ? AppColors.soft(t.color) : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? t.color : AppColors.track,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => type = key),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected ? AppColors.surface : AppColors.soft(t.color),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(t.icon, size: 18, color: t.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.label,
                  maxLines: 2,
                  style: AppTheme.font(
                    size: 14,
                    weight: FontWeight.w600,
                    color: selected ? t.color : AppColors.textPrimary,
                  ),
                ),
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
    final products = ref
        .watch(productListProvider)
        .products
        .where((p) => p.isActive)
        .toList();
    final warehouses = ref.watch(warehouseListProvider).warehouses;
    final state = ref.watch(stockMovementProvider);
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
        // Refresh so the stock shown in the product list is current.
        ref.read(productListProvider.notifier).load();
        setState(() {});
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      drawer: const AppDrawer(currentRoute: '/stock-movement'),
      appBar: AppPageHeader(
        title: l10n.stockMovement,
        icon: Icons.swap_vert_outlined,
        color: AppColors.stock,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              l10n.movementType,
              style: AppTheme.font(size: 16, weight: FontWeight.w600),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: [
              for (final e in types.entries) _typeCard(e.key, e.value),
            ],
          ),

          const SizedBox(height: 24),
          AppFormSection(
            title: l10n.details,
            children: [
              AppDropdown<String>(
                key: ValueKey('products-${products.length}'),
                label: l10n.product,
                icon: Icons.inventory_2_outlined,
                value: products.any((p) => p.id == productId) ? productId : null,
                items: [
                  for (final p in products)
                    DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(
                        '${p.name} · ${p.currentStock} ${p.unit}',
                        maxLines: 1,
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => productId = v),
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
                controller: quantityController,
                label: l10n.quantity,
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              AppTextField(
                controller: noteController,
                label: l10n.noteOptional,
                icon: Icons.notes,
              ),
            ],
          ),

          const SizedBox(height: 24),
          state.isLoading
              ? const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator()),
          )
              : FilledButton(
            onPressed: _canSubmit ? _submit : null,
            child: Text(l10n.recordMovement),
          ),

          if (state.lastCurrentStock != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 22, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.currentStockAfter(state.lastCurrentStock!),
                      style: AppTheme.font(size: 14, weight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}