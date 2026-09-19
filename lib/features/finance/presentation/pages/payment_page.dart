import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/payment_provider.dart';
import '../../../../shared/widgets/app_page_header.dart';
class PaymentPage extends ConsumerStatefulWidget {
  final String? saleId;
  final String? purchaseId;
  final String title;

  const PaymentPage(
      {super.key, this.saleId, this.purchaseId, required this.title});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final amountController = TextEditingController();
  String method = 'cash';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.saleId != null) {
        ref.read(paymentProvider.notifier).loadSaleBalance(widget.saleId!);
      } else if (widget.purchaseId != null) {
        ref.read(paymentProvider.notifier).loadPurchaseBalance(widget.purchaseId!);
      }
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Map<String, ({String label, IconData icon})> _methods(AppLocalizations l10n) {
    return {
      'cash': (label: l10n.cash, icon: Icons.payments_outlined),
      'bank_transfer': (
      label: l10n.bankTransfer,
      icon: Icons.account_balance_outlined
      ),
      'check': (label: l10n.check, icon: Icons.receipt_long_outlined),
    };
  }

  Widget _amountRow(String label, double value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: bold ? 14.5 : 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
                color: bold ? AppColors.textPrimary : AppColors.textSecondary,
              )),
          Text('${value.toStringAsFixed(3)} DT',
              style: TextStyle(
                fontSize: bold ? 20 : 14,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: color ?? AppColors.textPrimary,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);
    final l10n = AppLocalizations.of(context)!;
    final methods = _methods(l10n);

    ref.listen(paymentProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.error!), backgroundColor: AppColors.danger),
        );
      }
    });

    final balance = state.balance;
    final isPaid = balance != null && balance.balance <= 0.009;
    final progress = balance != null && balance.total > 0
        ? (balance.paid / balance.total).clamp(0.0, 1.0)
        : 0.0;
    final accent = isPaid ? AppColors.success : AppColors.danger;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppPageHeader(
        title: l10n.payment,
        subtitle: widget.title,
        icon: Icons.payments_rounded,
        color: AppColors.finance,
        showMenuButton: false,
      ),
      body: state.isLoading || balance == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Balance card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: AppColors.tintGradient(accent),
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: accent.withValues(alpha: 0.25)),
                  ),
                  child: Icon(
                    isPaid
                        ? Icons.check_circle_outline
                        : Icons.pending_outlined,
                    size: 32,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 14),
                Text(isPaid ? l10n.paidInFull : l10n.balanceDue,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: accent)),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation(
                        isPaid ? AppColors.success : AppColors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    l10n.percentSettled(
                        (progress * 100).toStringAsFixed(0)),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
                const Divider(height: 26),
                _amountRow(l10n.total, balance.total),
                _amountRow(l10n.alreadyPaid, balance.paid,
                    color: AppColors.success),
                const Divider(height: 18),
                _amountRow(l10n.remainingDue, balance.balance,
                    bold: true, color: accent),
              ],
            ),
          ),

          const SizedBox(height: 22),

          if (!isPaid) ...[
            Text(l10n.recordPayment,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.amount,
                prefixIcon: const Icon(Icons.payments_outlined),
                suffixText: 'DT',
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() {
                  amountController.text =
                      balance.balance.toStringAsFixed(3);
                }),
                icon: const Icon(Icons.done_all, size: 16),
                label: Text(l10n.payFullAmount,
                    style: const TextStyle(fontSize: 12.5)),
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.paymentMethod,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Row(
              children: methods.entries.map((e) {
                final selected = method == e.key;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => method = e.key),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border,
                            width: selected ? 1.6 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(e.value.icon,
                                size: 20,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textSecondary),
                            const SizedBox(height: 6),
                            Text(e.value.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () {
                  final amount =
                      double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) return;
                  ref.read(paymentProvider.notifier).pay(
                    saleId: widget.saleId,
                    purchaseId: widget.purchaseId,
                    amount: amount,
                    method: method,
                  );
                  amountController.clear();
                },
                icon: const Icon(Icons.check),
                label: Text(l10n.recordThePayment,
                    style: const TextStyle(fontSize: 15)),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}