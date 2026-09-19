import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';
import '../widgets/product_form_dialog.dart';
import 'categories_page.dart';
import 'product_detail_page.dart';

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
    Future.microtask(() {
      ref.read(productListProvider.notifier).load();
      ref.read(categoryListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  Future<void> _create() async {
    final input = await showProductFormDialog(context, ref);
    if (input == null) return;
    await ref.read(productListProvider.notifier).add(input);
  }

  Future<void> _edit(ProductEntity product, AppLocalizations l10n) async {
    final input = await showProductFormDialog(context, ref, existing: product);
    if (input == null) return;
    await ref.read(productListProvider.notifier).update(product.id, input);
    if (mounted) _showSnack(l10n.productUpdated);
  }

  Future<void> _delete(ProductEntity product, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(product.name)),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final error =
    await ref.read(productListProvider.notifier).remove(product.id);
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
    final categories = ref.watch(categoryListProvider).categories;
    final l10n = AppLocalizations.of(context)!;

    ref.listen(productListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    // A live subtitle tells the user what they're looking at.
    final lowStockCount = state.products.where((p) => p.isLowStock).length;
    final subtitle = state.products.isEmpty
        ? null
        : lowStockCount > 0
        ? '${state.products.length} · $lowStockCount ${l10n.lowStockAlerts.toLowerCase()}'
        : '${state.products.length} ${l10n.products.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/products'),
      appBar: searchVisible
          ? AppSearchHeader(
        controller: searchController,
        hint: l10n.searchProducts,
        onChanged: (v) =>
            ref.read(productListProvider.notifier).search(v),
        onClose: () {
          setState(() => searchVisible = false);
          searchController.clear();
          ref.read(productListProvider.notifier).clearSearch();
        },
      )
          : AppPageHeader(
        title: l10n.products,
        subtitle: subtitle,
        icon: Icons.inventory_2_rounded,
        color: AppColors.stock,
        actions: [
          AppHeaderAction(
            icon: Icons.search_rounded,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
          AppHeaderAction(
            icon: Icons.category_rounded,
            tooltip: l10n.categories,
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const CategoriesPage(),
              ));
              if (mounted) {
                ref.read(categoryListProvider.notifier).load();
                ref.read(productListProvider.notifier).load();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (categories.isNotEmpty && !searchVisible)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(l10n.allCategories,
                          style: const TextStyle(fontSize: 12)),
                      selected: state.categoryFilter == null,
                      onSelected: (_) => ref
                          .read(productListProvider.notifier)
                          .filterByCategory(null),
                    ),
                  ),
                  ...categories.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: c.color, shape: BoxShape.circle),
                      ),
                      label: Text(c.name,
                          style: const TextStyle(fontSize: 12)),
                      selected: state.categoryFilter == c.id,
                      onSelected: (_) => ref
                          .read(productListProvider.notifier)
                          .filterByCategory(
                          state.categoryFilter == c.id ? null : c.id),
                    ),
                  )),
                ],
              ),
            ),

          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.products.isEmpty
                ? AppEmptyState(
              icon: state.hasSearched
                  ? Icons.search_off
                  : Icons.inventory_2_outlined,
              title:
              state.hasSearched ? l10n.noResults : l10n.noProducts,
              subtitle: state.hasSearched
                  ? l10n.tryDifferentSearch
                  : l10n.tapPlusToAdd,
              color: AppColors.stock,
            )
                : RefreshIndicator(
              onRefresh: () =>
                  ref.read(productListProvider.notifier).load(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final p = state.products[index];
                  final stockColor = p.isLowStock
                      ? AppColors.danger
                      : AppColors.sales;

                  return Opacity(
                    opacity: p.isActive ? 1 : 0.55,
                    child: AppCard(
                      onTap: () async {
                        await Navigator.of(context)
                            .push(MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailPage(productId: p.id),
                        ));
                        if (mounted) {
                          ref
                              .read(productListProvider.notifier)
                              .load();
                        }
                      },
                      padding:
                      const EdgeInsets.fromLTRB(14, 14, 4, 14),
                      accentColor:
                      p.isLowStock ? AppColors.danger : null,
                      child: Row(
                        children: [
                          AppValueBadge(
                              value: '${p.currentStock}',
                              color: stockColor),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(p.name,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.w700,
                                              letterSpacing: -0.2,
                                              color: AppColors
                                                  .textPrimary),
                                          overflow:
                                          TextOverflow.ellipsis),
                                    ),
                                    if (!p.isActive) ...[
                                      const SizedBox(width: 6),
                                      AppStatusChip(
                                          label: l10n.inactive,
                                          color: AppColors
                                              .textSecondary),
                                    ] else if (p.isLowStock) ...[
                                      const SizedBox(width: 6),
                                      AppStatusChip(
                                          label: p.currentStock <= 0
                                              ? l10n.rupture
                                              : l10n.soon,
                                          color: AppColors.danger),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 5),
                                AppMetaRow(items: [
                                  if (p.sku != null)
                                    (icon: Icons.tag, text: p.sku!),
                                  (
                                  icon: Icons.inventory_2_outlined,
                                  text: '${p.currentStock} ${p.unit}'
                                  ),
                                  if (p.categoryName != null)
                                    (
                                    icon: Icons.category_outlined,
                                    text: p.categoryName!
                                    ),
                                ]),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppTrailingStat(
                            value: '${p.price.toStringAsFixed(2)} DT',
                            label:
                            'TVA ${p.vatRate.toStringAsFixed(0)}%',
                            valueColor: AppColors.primary,
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                size: 19,
                                color: AppColors.textSecondary),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(14)),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _edit(p, l10n);
                              } else if (value == 'delete') {
                                _delete(p, l10n);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(children: [
                                  const Icon(Icons.edit_outlined,
                                      size: 18),
                                  const SizedBox(width: 10),
                                  Text(l10n.edit),
                                ]),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  const Icon(Icons.delete_outline,
                                      size: 18,
                                      color: AppColors.danger),
                                  const SizedBox(width: 10),
                                  Text(l10n.delete,
                                      style: const TextStyle(
                                          color: AppColors.danger)),
                                ]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: Text(l10n.product),
      ),
    );
  }
}