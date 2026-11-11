import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import 'app_page_header.dart';

/// One line of a sale or purchase as the lines table shows it.
class AppLineRow {
  final String product;
  final int quantity;
  final double unitPrice;
  final double total;

  const AppLineRow({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

/// The lines already added to a sale or purchase, as a small table:
/// Product | Qty | Price | Total | delete. One white bordered container,
/// one-line rows, the product name ellipsized.
class AppLinesTable extends StatelessWidget {
  final String title;
  final List<AppLineRow> rows;
  final void Function(int index) onRemove;
  final String emptyText;

  /// Header for the unit price column ("Price" for sales, "Cost" for
  /// purchases).
  final String priceLabel;

  const AppLinesTable({
    super.key,
    required this.title,
    required this.rows,
    required this.onRemove,
    required this.emptyText,
    required this.priceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final head = AppTheme.font(
        size: 12, weight: FontWeight.w500, color: AppColors.textSecondary);
    final num = AppTheme.font(size: 14, tabularFigures: true);

    Widget cells({
      required Widget product,
      required Widget qty,
      required Widget price,
      required Widget total,
      required Widget action,
    }) =>
        Row(
          children: [
            Expanded(child: product),
            const SizedBox(width: 8),
            SizedBox(width: 40, child: Align(alignment: Alignment.centerRight, child: qty)),
            const SizedBox(width: 8),
            SizedBox(width: 84, child: Align(alignment: Alignment.centerRight, child: price)),
            const SizedBox(width: 8),
            SizedBox(width: 92, child: Align(alignment: Alignment.centerRight, child: total)),
            SizedBox(width: 44, child: action),
          ],
        );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.gap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(title, style: AppTheme.sectionTitle),
          ),
          if (rows.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border))),
              alignment: Alignment.center,
              child: Text(emptyText,
                  textAlign: TextAlign.center, style: AppTheme.label),
            )
          else ...[
            Container(
              height: 36,
              padding: const EdgeInsets.only(left: 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: cells(
                product: Text(l10n.product, style: head),
                qty: Text(l10n.qtyShort, style: head),
                price: Text(priceLabel, style: head),
                total: Text(l10n.total, style: head),
                action: const SizedBox.shrink(),
              ),
            ),
            for (var i = 0; i < rows.length; i++)
              Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  border: i == rows.length - 1
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.border)),
                ),
                child: cells(
                  product: Text(rows[i].product,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.font(size: 14, weight: FontWeight.w500)),
                  qty: Text('${rows[i].quantity}', style: num),
                  price: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(formatAmount(rows[i].unitPrice), style: num)),
                  total: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(formatAmount(rows[i].total),
                          style: num.copyWith(fontWeight: FontWeight.w600))),
                  action: AppIconButton(
                    icon: Icons.delete_outline,
                    tooltip: l10n.removeLine,
                    color: AppColors.iconMuted,
                    onTap: () => onRemove(i),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
