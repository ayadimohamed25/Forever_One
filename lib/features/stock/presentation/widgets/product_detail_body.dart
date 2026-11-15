import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../shared/widgets/app_motion.dart';
import '../../../../shared/widgets/app_side_panel.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';
import 'product_form_route.dart';

/// The category colour of a product, or null without a valid one.
Color? productCategoryColor(ProductEntity p) {
  final hex = p.categoryColorHex?.replaceAll('#', '');
  if (hex == null || hex.length != 6) return null;
  final v = int.tryParse(hex, radix: 16);
  return v == null ? null : Color(0xFF000000 | v);
}

/// Everything about one product, shared by the side panel (wide list) and
/// the full detail page (phones). [compact] = panel.
class ProductDetailBody extends ConsumerStatefulWidget {
  final String productId;
  final bool compact;
  final VoidCallback? onChanged;

  const ProductDetailBody({
    super.key,
    required this.productId,
    this.compact = false,
    this.onChanged,
  });

  @override
  ConsumerState<ProductDetailBody> createState() => _ProductDetailBodyState();
}

class _ProductDetailBodyState extends ConsumerState<ProductDetailBody> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void didUpdateWidget(ProductDetailBody old) {
    super.didUpdateWidget(old);
    if (old.productId != widget.productId) Future.microtask(_load);
  }

  Future<void> _load() =>
      ref.read(productDetailProvider.notifier).load(widget.productId);

  Future<void> _edit(ProductEntity p) async {
    final input = await openProductForm(context, ref, existing: p);
    if (input == null) return;
    await ref.read(productListProvider.notifier).update(p.id, input);
    if (!mounted) return;
    widget.onChanged?.call();
    _load();
  }

  ({String label, BadgeTone tone}) _stockStatus(
      ProductEntity p, AppLocalizations l10n) {
    if (!p.isActive) return (label: l10n.inactive, tone: BadgeTone.neutral);
    if (p.currentStock <= 0) {
      return (label: l10n.statusOutOfStock, tone: BadgeTone.danger);
    }
    if (p.isLowStock) {
      return (label: l10n.statusLowStock, tone: BadgeTone.warning);
    }
    return (label: l10n.ok, tone: BadgeTone.success);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(productDetailProvider);
    final p = state.product;

    if (state.isLoading || (p == null && state.error == null)) {
      return const AppPanelSkeleton();
    }
    if (p == null || p.id != widget.productId) {
      return AppPanelError(
        message: errorText(state.error, l10n),
        retryLabel: l10n.retry,
        onRetry: _load,
      );
    }

    final status = _stockStatus(p, l10n);
    final cat = productCategoryColor(p) ?? AppColors.primary;
    // The bar's full width is the max threshold, else four times the minimum.
    final capacity = (p.maxThreshold ?? (p.minThreshold * 4)).clamp(1, 1 << 30);
    final stockColor = p.currentStock <= 0
        ? AppColors.danger
        : p.isLowStock
            ? AppColors.warning
            : AppColors.success;
    final history =
        widget.compact ? state.history.take(5).toList() : state.history;

    final sections = <Widget>[
      Row(children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cat.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Text(AppAvatar.initialsOf(p.name),
              style: AppTheme.font(
                  size: 15, weight: FontWeight.w700, color: cat)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: widget.compact ? 32 : 0),
                child:
                    Text(p.name, maxLines: 2, style: AppTheme.heading(size: 18)),
              ),
              Text(
                  [
                    if ((p.sku ?? '').trim().isNotEmpty) p.sku!,
                    p.categoryName ?? l10n.noCategory,
                  ].join(' · '),
                  style: AppTheme.label),
            ],
          ),
        ),
      ]),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppBadge(label: status.label, tone: status.tone),
          OutlinedButton.icon(
            onPressed: () => _edit(p),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l10n.edit),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(
          child: AppStatTile(
            label: l10n.stock,
            value: '${p.currentStock} ${p.unit}',
            color: AppColors.textOn(stockColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: AppStatTile(label: l10n.priceTtc, value: formatDT(p.priceTtc))),
      ]),
      AppPanelSection(
        title: '${l10n.minThreshold}: ${p.minThreshold}',
        child: AppMeter(
            value: p.currentStock / capacity, color: stockColor, height: 8),
      ),
      AppPanelSection(
        title: l10n.pricingAndVat,
        child: Column(children: [
          AppInfoRow(
              icon: Icons.sell_outlined,
              label: l10n.priceHt,
              value: formatDT(p.price)),
          AppInfoRow(
              icon: Icons.shopping_bag_outlined,
              label: l10n.cost,
              value: formatDT(p.cost)),
          AppInfoRow(
              icon: Icons.trending_up,
              label: l10n.marginAmount,
              value: '${formatDT(p.margin)} · ${p.marginPercent.toStringAsFixed(0)}%'),
          AppInfoRow(
              icon: Icons.percent,
              label: l10n.vatRate,
              value: '${p.vatRate.toStringAsFixed(0)} %'),
        ]),
      ),
      if (!widget.compact)
        AppPanelSection(
          title: l10n.generalInfo,
          child: Column(children: [
            if (p.barcode != null && p.barcode!.trim().isNotEmpty)
              AppInfoRow(
                  icon: Icons.qr_code, label: l10n.barcode, value: p.barcode!),
            if (p.supplierName != null)
              AppInfoRow(
                  icon: Icons.local_shipping_outlined,
                  label: l10n.defaultSupplier,
                  value: p.supplierName!),
            if (p.shelfLocation != null && p.shelfLocation!.trim().isNotEmpty)
              AppInfoRow(
                  icon: Icons.place_outlined,
                  label: l10n.shelfLocation,
                  value: p.shelfLocation!),
            if (p.description != null && p.description!.trim().isNotEmpty)
              AppInfoRow(
                  icon: Icons.notes_outlined,
                  label: l10n.description,
                  value: p.description!),
          ]),
        ),
      AppPanelSection(
        title: l10n.stockHistory,
        child: history.isEmpty
            ? Text(l10n.noStockHistory, style: AppTheme.label)
            : Column(children: [
                for (final h in history)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.warehouseName ?? '—', style: AppTheme.body),
                            Text(formatDate(h.createdAt),
                                style: AppTheme.label),
                          ],
                        ),
                      ),
                      Text('${h.isIncoming ? '+' : '−'}${h.quantity}',
                          style: AppTheme.font(
                            size: 14,
                            weight: FontWeight.w700,
                            tabularFigures: true,
                            color: AppColors.textOn(h.isIncoming
                                ? AppColors.success
                                : AppColors.warning),
                          )),
                    ]),
                  ),
              ]),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++)
          AppEntrance(index: i, stagger: AppMotion.stagger, child: sections[i]),
      ],
    );
  }
}

