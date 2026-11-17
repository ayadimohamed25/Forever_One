import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import 'app_motion.dart';
import 'app_page_header.dart';
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

  /// Full-screen phone invoice: the total is the hero, with a paid / left
  /// bar under it (actions live in the page's bottom bar instead).
  final bool phone;

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
    this.phone = false,
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
      // Phones already show the number as the screen title.
      if (!phone && (reference ?? '').isNotEmpty)
        Text(reference!,
            style: AppTheme.font(
                size: 13,
                weight: FontWeight.w500,
                color: AppColors.textSecondary)),
      Padding(
        padding: EdgeInsets.only(right: phone ? 0 : 32, top: 2),
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
      if (phone) ...[
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(formatDT(total),
                style: AppTheme.heading(
                    size: 34,
                    weight: FontWeight.w800,
                    height: 1.1,
                    tabularFigures: true)),
          ),
        ),
        const SizedBox(height: 12),
        AppMeter(
          value: total <= 0 ? 1 : (paid / total).clamp(0, 1).toDouble(),
          color: AppColors.success,
          height: 8,
        ),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: Text('${l10n.paid} ${formatDT(paid)}',
                style: AppTheme.font(
                    size: 13,
                    weight: FontWeight.w600,
                    tabularFigures: true,
                    color: AppColors.successText)),
          ),
          if (balance > 0.009)
            Text('${l10n.colBalance} ${formatDT(balance)}',
                style: AppTheme.font(
                    size: 13,
                    weight: FontWeight.w600,
                    tabularFigures: true,
                    color: AppColors.warningText)),
        ]),
      ],
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
      if (actions.isNotEmpty)
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

/// Phones: an invoice on its own screen (mobile board 3): the content in a
/// card, and the actions in a bar fixed at the bottom, in thumb reach.
/// [secondary] (Edit) sits on the left, [primary] (Record payment) fills
/// the rest.
class AppInvoicePage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? primary;
  final Widget? secondary;

  const AppInvoicePage({
    super.key,
    required this.title,
    required this.body,
    this.primary,
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final hasBar = primary != null || secondary != null;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: title,
        icon: Icons.receipt_long_outlined,
        color: AppColors.primary,
        showMenuButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: body,
          ),
        ],
      ),
      bottomNavigationBar: !hasBar
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 50,
                  child: Row(children: [
                    ?secondary,
                    if (secondary != null && primary != null)
                      const SizedBox(width: 10),
                    if (primary != null) Expanded(child: primary!),
                  ]),
                ),
              ),
            ),
    );
  }
}
