import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_provider.dart';

class WarehousesPage extends ConsumerStatefulWidget {
  const WarehousesPage({super.key});

  @override
  ConsumerState<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends ConsumerState<WarehousesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(warehouseListProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Warehouses')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.warehouses.isEmpty
          ? const Center(child: Text('No warehouses yet'))
          : ListView.builder(
        itemCount: state.warehouses.length,
        itemBuilder: (context, index) {
          final w = state.warehouses[index];
          return ListTile(
            leading: const Icon(Icons.warehouse),
            title: Text(w.name),
            subtitle: w.location != null ? Text(w.location!) : null,
          );
        },
      ),
    );
  }
}