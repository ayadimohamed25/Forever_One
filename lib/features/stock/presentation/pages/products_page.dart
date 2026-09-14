import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';
import '../widgets/product_form_dialog.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(productListProvider.notifier).load());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.error : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _create(AppLocalizations l10n) async {
    final result = await showProductFormDialog(context);
    if (result == null) return;
    await ref.read(productListProvider.notifier).add(
      name: result.name,
      barcode: result.barcode,
      price: result.price,
      cost: result.cost,
      minThreshold: result.minThreshold,
      unit: result.unit,
    );
  }

  Future<void> _edit(ProductEntity product, AppLocalizations l10n) async {
    final result = await showProductFormDialog(context, existing: product);
    if (result == null) return;
    await ref.read(productListProvider.notifier).update(
      id: product.id,
      name: result.name,
      barcode: result.barcode,
      price: result.price,
      cost: result.cost,
      minThreshold: result.minThreshold,
      unit: result.unit,
    );
    if (mounted) _showSnack(l10n.productUpdated);
  }

  Future<void> _delete(ProductEntity product, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteConfirmTitle(product.name)),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final error = await ref.read(productListProvider.notifier).remove(product.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.productDeleted);
    } else if (error == 'PRODUCT_IN_USE') {
      _showSnack(l10n.productInUse, isError: true);
    } else {
      _showSnack(error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: searchVisible
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchProducts,
            border: InputBorder.none,
            hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
          ),
          onChanged: (value) =>
              ref.read(productListProvider.notifier).search(value),
        )
            : Text(l10n.products),
        actions: [
          IconButton(
            icon: Icon(searchVisible ? Icons.close : Icons.search),
            tooltip: l10n.search,
            onPressed: () {
              setState(() => searchVisible = !searchVisible);
              if (!searchVisible) {
                searchController.clear();
                ref.read(productListProvider.notifier).clearSearch();
              }
            },
          ),
          if (!searchVisible)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refresh,
              onPressed: () => ref.read(productListProvider.notifier).load(),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                state.hasSearched
                    ? Icons.search_off
                    : Icons.inventory_2_outlined,
                size: 64,
                color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(state.hasSearched ? l10n.noResults : l10n.noProducts,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(
                state.hasSearched
                    ? l10n.tryDifferentSearch
                    : l10n.tapPlusToAdd,
                style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () => ref.read(productListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          itemCount: state.products.length,
          itemBuilder: (context, index) {
            final product = state.products[index];
            final stockColor = product.isLowStock
                ? theme.colorScheme.error
                : Colors.green.shade700;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: InkWell(
                onTap: () => _edit(product, l10n),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
                  child: Row(
                    children: [
                      // Stock badge
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: stockColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${product.currentStock}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: stockColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                    product.isLowStock
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle_outline,
                                    size: 13,
                                    color: stockColor),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${product.currentStock} ${product.unit} ${l10n.inStock} · ${l10n.threshold} ${product.minThreshold}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme
                                          .colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(2)} DT',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.margin} ${product.marginPercent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: product.margin > 0
                                  ? Colors.green.shade700
                                  : theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _edit(product, l10n);
                          } else if (value == 'delete') {
                            _delete(product, l10n);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 18),
                                const SizedBox(width: 10),
                                Text(l10n.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 18,
                                    color: theme.colorScheme.error),
                                const SizedBox(width: 10),
                                Text(l10n.delete,
                                    style: TextStyle(
                                        color: theme.colorScheme.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.product),
      ),
    );
  }
}