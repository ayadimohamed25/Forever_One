import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payment_provider.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final String? saleId;
  final String? purchaseId;
  final String title;

  const PaymentPage({super.key, this.saleId, this.purchaseId, required this.title});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final amountController = TextEditingController();
  String method = 'cash';

  static const methods = <String, ({String label, IconData icon})>{
    'cash': (label: 'Espèces', icon: Icons.payments_outlined),
    'bank_transfer': (label: 'Virement', icon: Icons.account_balance_outlined),
    'check': (label: 'Chèque', icon: Icons.receipt_long_outlined),
  };

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

  Widget _amountRow(String label, double value, ThemeData theme,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: bold ? 15 : 13.5,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: bold ? null : theme.colorScheme.onSurfaceVariant,
              )),
          Text('${value.toStringAsFixed(2)} DT',
              style: TextStyle(
                fontSize: bold ? 19 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: color,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);
    final theme = Theme.of(context);

    ref.listen(paymentProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final balance = state.balance;
    final isPaid = balance != null && balance.balance <= 0;
    final progress = balance != null && balance.total > 0
        ? (balance.paid / balance.total).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: state.isLoading || balance == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance summary card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isPaid
                            ? Colors.green.withValues(alpha: 0.12)
                            : theme.colorScheme.errorContainer
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                        size: 32,
                        color: isPaid
                            ? Colors.green.shade700
                            : theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isPaid ? 'Entièrement payé' : 'Solde à régler',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isPaid
                            ? Colors.green.shade700
                            : theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 18),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          isPaid ? Colors.green.shade600 : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(progress * 100).toStringAsFixed(0)} % réglé',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                    const Divider(height: 26),
                    _amountRow('Total', balance.total, theme),
                    _amountRow('Déjà payé', balance.paid, theme,
                        color: Colors.green.shade700),
                    const Divider(height: 20),
                    _amountRow('Reste dû', balance.balance, theme,
                        bold: true,
                        color: isPaid
                            ? Colors.green.shade700
                            : theme.colorScheme.error),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (!isPaid) ...[
              const Text('Enregistrer un paiement',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  prefixIcon: const Icon(Icons.euro_symbol),
                  suffixText: 'DT',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    amountController.text = balance.balance.toStringAsFixed(2);
                  }),
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('Régler la totalité',
                      style: TextStyle(fontSize: 12.5)),
                ),
              ),

              const SizedBox(height: 10),
              Text('Mode de paiement',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: methods.entries.map((e) {
                  final selected = method == e.key;
                  return ChoiceChip(
                    avatar: Icon(e.value.icon,
                        size: 16,
                        color: selected
                            ? theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onSurfaceVariant),
                    label: Text(e.value.label,
                        style: const TextStyle(fontSize: 12.5)),
                    selected: selected,
                    onSelected: (_) => setState(() => method = e.key),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
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
                  label: const Text('Enregistrer le paiement',
                      style: TextStyle(fontSize: 15)),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}