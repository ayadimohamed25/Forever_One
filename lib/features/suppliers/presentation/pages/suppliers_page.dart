import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/supplier_provider.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(supplierListProvider.notifier).load());
  }

  void _openAddDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final leadTimeController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                controller: leadTimeController,
                decoration: const InputDecoration(labelText: 'Lead time (days)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              ref.read(supplierListProvider.notifier).add(
                name: nameController.text.trim(),
                phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                leadTimeDays: int.tryParse(leadTimeController.text) ?? 0,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierListProvider);

    ref.listen(supplierListProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.suppliers.isEmpty
          ? const Center(child: Text('No suppliers yet — tap + to add one'))
          : ListView.builder(
        itemCount: state.suppliers.length,
        itemBuilder: (context, index) {
          final s = state.suppliers[index];
          return ListTile(
            title: Text(s.name),
            subtitle: Text('${s.phone ?? ""}  ·  lead time: ${s.leadTimeDays} days'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _openAddDialog, child: const Icon(Icons.add)),
    );
  }
}