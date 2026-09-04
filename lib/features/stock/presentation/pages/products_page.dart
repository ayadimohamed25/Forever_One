import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(productListProvider.notifier).load());
  }

  void _openAddDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final costController = TextEditingController();
    final thresholdController = TextEditingController(text: '0');
    final unitController = TextEditingController(text: 'unit');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: costController,
                decoration: const InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: thresholdController,
                decoration: const InputDecoration(labelText: 'Min threshold'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              ref.read(productListProvider.notifier).add(
                name: nameController.text.trim(),
                price: double.tryParse(priceController.text) ?? 0,
                cost: double.tryParse(costController.text) ?? 0,
                minThreshold: int.tryParse(thresholdController.text) ?? 0,
                unit: unitController.text.trim().isEmpty
                    ? 'unit'
                    : unitController.text.trim(),
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
    final state = ref.watch(productListProvider);

    ref.listen(productListProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.products.isEmpty
          ? const Center(child: Text('No products yet — tap + to add one'))
          : ListView.builder(
        itemCount: state.products.length,
        itemBuilder: (context, index) {
          final product = state.products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text(
              '${product.price.toStringAsFixed(2)} · stock threshold ${product.minThreshold} ${product.unit}',
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}