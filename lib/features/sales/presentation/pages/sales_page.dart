import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sale_provider.dart';
import 'create_sale_page.dart';
import '../../../finance/presentation/pages/payment_page.dart';
class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(saleListProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saleListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.sales.isEmpty
          ? const Center(child: Text('No sales yet — tap + to create one'))
          : ListView.builder(
        itemCount: state.sales.length,
        itemBuilder: (context, index) {
          final s = state.sales[index];
          return ListTile(
            title: Text(s.customerName),
            subtitle: Text('Status: ${s.status}'),
            trailing: Text(s.total.toStringAsFixed(2)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PaymentPage(saleId: s.id, title: 'Payment — ${s.customerName}'),
              ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateSalePage()),
          );
          ref.read(saleListProvider.notifier).load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}