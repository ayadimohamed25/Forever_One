import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/product_provider.dart';
import '../widgets/product_form_dialog.dart';
import '../../../../shared/widgets/app_page_header.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
            () => ref.read(productDetailProvider.notifier).load(widget.productId));
  }

  Widget _statTile(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _panel({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailProvider);
    final l10n = AppLocalizations.of(context)!;
    final p = state.product;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppPageHeader(
        title: l10n.productDetails,
        subtitle: p?.name,
        icon: Icons.inventory_2_rounded,
        color: AppColors.stock,
        showMenuButton: false,
        actions: [
          if (p != null)
            AppHeaderAction(
              icon: Icons.edit_rounded,
              tooltip: l10n.edit,
              color: AppColors.primary,
              onTap: () async {
                final input =
                await showProductFormDialog(context, ref, existing: p);
                if (input == null) return;
                await ref.read(productListProvider.notifier).update(p.id, input);
                if (mounted) {
                  ref.read(productDetailProvider.notifier).load(p.id);
                }
              },
            ),
        ],
      ),
      body: state.isLoading || p == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(productDetailProvider.notifier).load(p.id),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              children: [
                AppValueBadge(
                  value: '${p.currentStock}',
                  color:
                  p.isLowStock ? AppColors.danger : AppColors.sales,
                  size: 60,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (p.categoryName != null)
                            AppStatusChip(
                                label: p.categoryName!,
                                color: AppColors.primary),
                          AppStatusChip(
                            label: p.isActive
                                ? l10n.active
                                : l10n.inactive,
                            color: p.isActive
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                          if (p.isLowStock)
                            AppStatusChip(
                                label: p.currentStock <= 0
                                    ? l10n.rupture
                                    : l10n.soon,
                                color: AppColors.danger),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (p.description != null) ...[
              const SizedBox(height: 14),
              Text(p.description!,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],

            const SizedBox(height: 20),

            // Key figures
            _panel(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  _statTile(l10n.priceHt,
                      p.price.toStringAsFixed(2), AppColors.primary),
                  _statTile(l10n.priceTtc,
                      p.priceTtc.toStringAsFixed(2), AppColors.finance),
                  _statTile(
                    l10n.marginAmount,
                    '${p.marginPercent.toStringAsFixed(0)}%',
                    p.margin > 0 ? AppColors.success : AppColors.danger,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle(l10n.generalInfo, Icons.info_outline,
                AppColors.primary),
            _panel(
              child: Column(
                children: [
                  if (p.sku != null)
                    _infoRow(Icons.tag, l10n.sku, p.sku!),
                  if (p.barcode != null)
                    _infoRow(Icons.qr_code_2, l10n.barcode, p.barcode!),
                  _infoRow(Icons.category_outlined, l10n.category,
                      p.categoryName ?? l10n.noCategory),
                  if (p.supplierName != null)
                    _infoRow(Icons.local_shipping_outlined,
                        l10n.defaultSupplier, p.supplierName!),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle(l10n.pricingAndVat, Icons.payments_outlined,
                AppColors.sales),
            _panel(
              child: Column(
                children: [
                  _infoRow(Icons.sell_outlined, l10n.priceHt,
                      '${p.price.toStringAsFixed(3)} DT'),
                  _infoRow(Icons.shopping_bag_outlined, l10n.cost,
                      '${p.cost.toStringAsFixed(3)} DT'),
                  _infoRow(Icons.percent, l10n.vatRate,
                      '${p.vatRate.toStringAsFixed(0)} %'),
                  _infoRow(Icons.trending_up, l10n.marginAmount,
                      '${p.margin.toStringAsFixed(3)} DT'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle(l10n.stockSettings, Icons.inventory_2_outlined,
                AppColors.stock),
            _panel(
              child: Column(
                children: [
                  _infoRow(Icons.warning_amber_rounded, l10n.minThreshold,
                      '${p.minThreshold} ${p.unit}'),
                  if (p.maxThreshold != null)
                    _infoRow(Icons.vertical_align_top, l10n.maxThreshold,
                        '${p.maxThreshold} ${p.unit}'),
                  if (p.shelfLocation != null)
                    _infoRow(Icons.place_outlined, l10n.shelfLocation,
                        p.shelfLocation!),
                  _infoRow(Icons.straighten, l10n.saleUnit, p.unit),
                  if (p.purchaseUnit != null)
                    _infoRow(Icons.all_inbox_outlined, l10n.purchaseUnit,
                        '${p.purchaseUnit} (${p.unitsPerPurchase} ${p.unit})'),
                  if (p.notes != null)
                    _infoRow(Icons.notes, l10n.notes, p.notes!),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle(
                l10n.stockHistory, Icons.history, AppColors.info),
            if (state.history.isEmpty)
              _panel(
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Center(
                  child: Text(l10n.noStockHistory,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary)),
                ),
              )
            else
              ...state.history.map((h) {
                final color = h.isIncoming
                    ? AppColors.success
                    : AppColors.danger;
                final d = h.createdAt;
                final dateLabel =
                    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

                return AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                            h.isIncoming
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            size: 15,
                            color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.warehouseName ?? '—',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              h.note != null
                                  ? '$dateLabel · ${h.note}'
                                  : dateLabel,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                          '${h.isIncoming ? '+' : '−'}${h.quantity}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: color)),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}