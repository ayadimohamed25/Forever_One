import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';
import '../widgets/product_form_dialog.dart';

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

  Future<void> _edit(ProductEntity p) async {
    final input = await showProductFormDialog(context, ref, existing: p);
    if (input == null) return;
    await ref.read(productListProvider.notifier).update(p.id, input);
    if (mounted) ref.read(productDetailProvider.notifier).load(p.id);
  }

  ({String label, BadgeTone tone}) _stockStatus(
      ProductEntity p, AppLocalizations l10n) {
    if (!p.isActive) return (label: l10n.inactive, tone: BadgeTone.neutral);
    if (p.currentStock <= 0) {
      return (label: l10n.rupture, tone: BadgeTone.danger);
    }
    if (p.isLowStock) return (label: l10n.soon, tone: BadgeTone.warning);
    return (label: l10n.ok, tone: BadgeTone.success);
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTheme.font(
                size: 16,
                weight: FontWeight.w700,
                color: color,
                tabularFigures: true,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTheme.font(size: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 36, color: AppColors.track);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailProvider);
    final l10n = AppLocalizations.of(context)!;
    final p = state.product;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: l10n.productDetails,
        subtitle: p?.name,
        icon: Icons.inventory_2_outlined,
        color: AppColors.stock,
        showMenuButton: false,
        actions: [
          if (p != null)
            AppHeaderAction(
              icon: Icons.edit_outlined,
              tooltip: l10n.edit,
              onTap: () => _edit(p),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : p == null
          ? AppEmptyState(
        icon: Icons.error_outline,
        title: state.error ?? l10n.noProducts,
        subtitle: '',
      )
          : RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => ref
            .read(productDetailProvider.notifier)
            .load(widget.productId),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ── Identity ──
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLeadingTile.value(
                    '${p.currentStock}',
                    tone: _stockStatus(p, l10n).tone,
                    size: 52,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 2,
                          style: AppTheme.font(
                              size: 18, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${p.currentStock} ${p.unit}',
                          style: AppTheme.label,
                        ),
                        const SizedBox(height: 10),
                        AppBadge(
                          label: _stockStatus(p, l10n).label,
                          tone: _stockStatus(p, l10n).tone,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Prices ──
            AppCard(
              child: Row(
                children: [
                  _stat(l10n.priceHt, formatDT(p.price),
                      AppColors.textPrimary),
                  _statDivider(),
                  _stat(l10n.priceTtc, formatDT(p.priceTtc),
                      AppColors.textPrimary),
                  _statDivider(),
                  _stat(
                    l10n.marginAmount,
                    formatDT(p.price - p.cost),
                    p.price - p.cost >= 0
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── General ──
            AppFormSection(
              title: l10n.generalInfo,
              spacing: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              children: [
                if (p.sku != null && p.sku!.trim().isNotEmpty)
                  AppInfoRow(
                    icon: Icons.tag,
                    label: l10n.sku,
                    value: p.sku!,
                  ),
                if (p.barcode != null &&
                    p.barcode!.trim().isNotEmpty)
                  AppInfoRow(
                    icon: Icons.qr_code_2,
                    label: l10n.barcode,
                    value: p.barcode!,
                  ),
                AppInfoRow(
                  icon: Icons.category_outlined,
                  label: l10n.category,
                  value: p.categoryName ?? l10n.noCategory,
                ),
                if (p.supplierName != null)
                  AppInfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: l10n.defaultSupplier,
                    value: p.supplierName!,
                  ),
                if (p.description != null &&
                    p.description!.trim().isNotEmpty)
                  AppInfoRow(
                    icon: Icons.notes_outlined,
                    label: l10n.description,
                    value: p.description!,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Pricing ──
            AppFormSection(
              title: l10n.pricingAndVat,
              spacing: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              children: [
                AppInfoRow(
                  icon: Icons.sell_outlined,
                  label: l10n.priceHt,
                  value: formatDT(p.price),
                ),
                AppInfoRow(
                  icon: Icons.shopping_bag_outlined,
                  label: l10n.cost,
                  value: formatDT(p.cost),
                ),
                AppInfoRow(
                  icon: Icons.percent,
                  label: l10n.vatRate,
                  value: '${p.vatRate.toStringAsFixed(0)} %',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Stock settings ──
            AppFormSection(
              title: l10n.stockSettings,
              spacing: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              children: [
                AppInfoRow(
                  icon: Icons.south,
                  label: l10n.minThreshold,
                  value: '${p.minThreshold}',
                ),
                if (p.maxThreshold != null)
                  AppInfoRow(
                    icon: Icons.north,
                    label: l10n.maxThreshold,
                    value: '${p.maxThreshold}',
                  ),
                if (p.shelfLocation != null &&
                    p.shelfLocation!.trim().isNotEmpty)
                  AppInfoRow(
                    icon: Icons.place_outlined,
                    label: l10n.shelfLocation,
                    value: p.shelfLocation!,
                  ),
                AppInfoRow(
                  icon: Icons.straighten,
                  label: l10n.saleUnit,
                  value: p.unit,
                ),
                if (p.purchaseUnit != null &&
                    p.purchaseUnit!.trim().isNotEmpty)
                  AppInfoRow(
                    icon: Icons.all_inbox_outlined,
                    label: l10n.purchaseUnit,
                    value:
                    '${p.purchaseUnit} · ${p.unitsPerPurchase}',
                  ),
              ],
            ),

            // ── Stock history: warehouse, date, quantity ──
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                l10n.stockHistory,
                style:
                AppTheme.font(size: 16, weight: FontWeight.w600),
              ),
            ),
            if (state.history.isEmpty)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(l10n.noStockHistory,
                        style: AppTheme.label),
                  ),
                ),
              )
            else
              for (final h in state.history)
                AppCard(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      AppLeadingTile.icon(
                        h.isIncoming
                            ? Icons.south_west_outlined
                            : Icons.north_east_outlined,
                        tone: h.isIncoming
                            ? BadgeTone.success
                            : BadgeTone.warning,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.warehouseName ?? '—',
                              maxLines: 2,
                              style: AppTheme.font(
                                  size: 14,
                                  weight: FontWeight.w500),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              formatDate(h.createdAt),
                              style: AppTheme.font(
                                size: 12,
                                color: AppColors.textSecondary,
                                tabularFigures: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${h.isIncoming ? '+' : '−'}${h.quantity}',
                        style: AppTheme.font(
                          size: 15,
                          weight: FontWeight.w700,
                          color: h.isIncoming
                              ? AppColors.success
                              : AppColors.warning,
                          tabularFigures: true,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}