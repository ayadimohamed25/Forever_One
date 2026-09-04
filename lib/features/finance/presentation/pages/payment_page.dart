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
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);

    ref.listen(paymentProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: state.isLoading || state.balance == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: ${state.balance!.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            Text('Paid: ${state.balance!.paid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            Text(
              'Balance: ${state.balance!.balance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: state.balance!.balance > 0 ? Colors.red : Colors.green,
              ),
            ),
            const Divider(height: 32),
            if (state.balance!.balance > 0) ...[
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount to pay'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Method'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank transfer')),
                  DropdownMenuItem(value: 'check', child: Text('Check')),
                ],
                onChanged: (v) => setState(() => method = v!),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
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
                child: const Text('Record Payment'),
              ),
            ] else
              const Text('Fully paid ✅', style: TextStyle(color: Colors.green, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}