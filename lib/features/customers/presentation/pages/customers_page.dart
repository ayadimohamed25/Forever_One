import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/customer_provider.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(customerListProvider.notifier).load());
  }

  void _openAddDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final creditController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                controller: creditController,
                decoration: const InputDecoration(labelText: 'Credit limit'),
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
              ref.read(customerListProvider.notifier).add(
                name: nameController.text.trim(),
                phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                creditLimit: double.tryParse(creditController.text) ?? 0,
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
    final state = ref.watch(customerListProvider);

    ref.listen(customerListProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.customers.isEmpty
          ? const Center(child: Text('No customers yet — tap + to add one'))
          : ListView.builder(
        itemCount: state.customers.length,
        itemBuilder: (context, index) {
          final c = state.customers[index];
          return ListTile(
            title: Text(c.name),
            subtitle: Text('${c.phone ?? ""}  ·  credit limit: ${c.creditLimit.toStringAsFixed(2)}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _openAddDialog, child: const Icon(Icons.add)),
    );
  }
}