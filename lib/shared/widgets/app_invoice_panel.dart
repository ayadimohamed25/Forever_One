import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import 'app_motion.dart';
import 'app_side_panel.dart';

/// One line of an invoice shown in a panel.
class AppInvoiceLine {
  final String name;
  final int quantity;
  final double amount; // excl. VAT
  const AppInvoiceLine(this.name, this.quantity, this.amount);
}

/// The content of a sale or purchase side panel: who, status and dates,
/// totals, lines and actions. Sales and purchases share it so both panels
/// read the same way.
class AppInvoicePanel extends StatelessWidget {
  final String party;
  final String? reference;
  final Widget status;
  final String dates;
  final double subtotal;
  final double vat;
  final double total;
  final double paid;
  final List<AppInvoiceLine> lines;
  final List<Widget> actions;

  const AppInvoicePanel({
    super.key,
    required this.party,
    required this.reference,
    required this.status,
    required this.dates,
    required this.subtotal,
    required this.vat,
    required this.total,
    required this.paid,
    required this.lines,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final balance = total - paid;

    Widget amountRow(String label, String value,
            {bool strong = false, Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: AppTheme.font(
                      size: 14,
                      weight: strong ? FontWeight.w600 : FontWeight.w400,
                      color: strong
                          ? AppColors.textPrimary
                          : AppColors.textSecondary)),
            ),
            Text(value,
                style: strong
                    ? AppTheme.heading(
                        size: 16,
                        tabularFigures: true,
                        color: color ?? AppColors.textPrimary)
                    : AppTheme.font(
                        size: 14,
                        tabularFigures: true,
                        color: color ?? AppColors.textPrimary)),
          ]),
        );

    final sections = <Widget>[
      if ((reference ?? '').isNotEmpty)
        Text(reference!,
            style: AppTheme.font(
                size: 13,
                weight: FontWeight.w500,
                color: AppColors.textSecondary)),
      Padding(
        padding: const EdgeInsets.only(right: 32, top: 2),
        child: Text(party, maxLines: 2, style: AppTheme.heading(size: 18)),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [status, Text(dates, style: AppTheme.label)],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Column(children: [
          amountRow(l10n.subtotalHt, formatDT(subtotal)),
          amountRow(l10n.totalVat, formatDT(vat)),
          amountRow(l10n.colTotalInclVat, formatDT(total)),
          amountRow(l10n.paid, formatDT(paid)),
          const Divider(height: 16),
          amountRow(l10n.colBalance, formatDT(balance > 0 ? balance : 0),
              strong: true,
              color: balance > 0.009 ? AppColors.warningText : null),
        ]),
      ),
      AppPanelSection(
        title: l10n.lines,
        child: Column(children: [
          for (final line in lines)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(children: [
                Expanded(
                  child: Text('${line.name} × ${line.quantity}',
                      maxLines: 2, style: AppTheme.body),
                ),
                const SizedBox(width: 12),
                Text(formatDT(line.amount),
                    style: AppTheme.font(size: 14, tabularFigures: true)),
              ]),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Wrap(spacing: 8, runSpacing: 8, children: actions),
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
