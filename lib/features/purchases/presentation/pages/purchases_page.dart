import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/purchase_provider.dart';
import 'create_purchase_page.dart';
import '../../../finance/presentation/pages/payment_page.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(purchaseListProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Purchases')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.purchases.isEmpty
          ? const Center(child: Text('No purchases yet — tap + to record one'))
          : ListView.builder(
        itemCount: state.purchases.length,
        itemBuilder: (context, index) {
          final p = state.purchases[index];
          return ListTile(
            title: Text(p.supplierName),
            subtitle: Text('Status: ${p.status}'),
            trailing: Text(p.total.toStringAsFixed(2)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PaymentPage(purchaseId: p.id, title: 'Payment — ${p.supplierName}'),
              ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreatePurchasePage()),
          );
          ref.read(purchaseListProvider.notifier).load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}