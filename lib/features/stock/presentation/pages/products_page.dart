import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
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
    final input =
    await showProductFormDialog(context, ref, existing: product);
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
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

  Future<void> _openDetail(ProductEntity product) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProductDetailPage(productId: product.id),
    ));
    if (mounted) ref.read(productListProvider.notifier).load();
  }

  Future<void> _openCategories() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const CategoriesPage(),
    ));
    if (mounted) {
      ref.read(categoryListProvider.notifier).load();
      ref.read(productListProvider.notifier).load();
    }
  }

  /// Stock tile colours: empty → danger, at/below threshold → warning,
  /// otherwise → success.
  ({Color fg, Color bg}) _stockColors(ProductEntity p) {
    if (p.currentStock <= 0) {
      return (fg: AppColors.danger, bg: AppColors.dangerSoft);
    }
    if (p.isLowStock) {
      return (fg: AppColors.warning, bg: AppColors.warningSoft);
    }
    return (fg: AppColors.success, bg: AppColors.successSoft);
  }

  Widget _pill(String text, Color foreground, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: AppTheme.font(
            size: 12, weight: FontWeight.w600, color: foreground),
      ),
    );
  }

  /// Selected: dark ink with white text. Others: white with a cream border.
  Widget _categoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? AppColors.black : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
            color: selected ? AppColors.black : AppColors.track,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            widthFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                label,
                style: AppTheme.font(
                  size: 13,
                  weight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _productCard(ProductEntity p, AppLocalizations l10n) {
    final stock = _stockColors(p);

    // Second line: reference and supplier; falls back to the category.
    final details = [p.sku, p.supplierName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toList();
    final secondLine = details.isNotEmpty
        ? details.join(' · ')
        : (p.categoryName ?? l10n.noCategory);

    Widget? status;
    if (!p.isActive) {
      status = _pill(l10n.inactive, AppColors.textSecondary, AppColors.fill);
    } else if (p.currentStock <= 0) {
      status = _pill(l10n.rupture, AppColors.danger, AppColors.dangerSoft);
    } else if (p.isLowStock) {
      status = _pill(l10n.soon, AppColors.warning, AppColors.warningSoft);
    }

    return Opacity(
      opacity: p.isActive ? 1 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openDetail(p),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: stock.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '${p.currentStock}',
                          style: AppTheme.font(
                            size: 15,
                            weight: FontWeight.w700,
                            color: stock.fg,
                            tabularFigures: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: AppTheme.rowTitle, maxLines: 2),
                        const SizedBox(height: 4),
                        Text(secondLine, style: AppTheme.label, maxLines: 2),
                        if (status != null) ...[
                          const SizedBox(height: 10),
                          status,
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${p.price.toStringAsFixed(2)} DT',
                          style: AppTheme.money),
                      const SizedBox(height: 3),
                      Text(
                        '${l10n.lineVat} ${p.vatRate.toStringAsFixed(0)}%',
                        style: AppTheme.label,
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 20, color: AppColors.iconMuted),
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
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined,
                                size: 18, color: AppColors.icon),
                            const SizedBox(width: 12),
                            Text(l10n.edit, style: AppTheme.font(size: 15)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline,
                                size: 18, color: AppColors.danger),
                            const SizedBox(width: 12),
                            Text(
                              l10n.delete,
                              style: AppTheme.font(
                                  size: 15, color: AppColors.danger),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);
    final categories = ref.watch(categoryListProvider).categories;
    final l10n = AppLocalizations.of(context)!;

    ref.listen(productListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    final lowStockCount = state.products.where((p) => p.isLowStock).length;
    final subtitle = state.products.isEmpty
        ? null
        : lowStockCount > 0
        ? '${state.products.length} · $lowStockCount ${l10n.lowStockAlerts.toLowerCase()}'
        : '${state.products.length} ${l10n.products.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
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
        icon: Icons.inventory_2_outlined,
        color: AppColors.stock,
        actions: [
          AppHeaderAction(
            icon: Icons.search,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
          AppHeaderAction(
            icon: Icons.category_outlined,
            tooltip: l10n.categories,
            onTap: _openCategories,
          ),
        ],
      ),
      body: Column(
        children: [
          if (categories.isNotEmpty && !searchVisible)
            SizedBox(
              height: 54,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                children: [
                  _categoryChip(
                    label: l10n.allCategories,
                    selected: state.categoryFilter == null,
                    onTap: () => ref
                        .read(productListProvider.notifier)
                        .filterByCategory(null),
                  ),
                  ...categories.map((c) => _categoryChip(
                    label: c.name,
                    selected: state.categoryFilter == c.id,
                    onTap: () => ref
                        .read(productListProvider.notifier)
                        .filterByCategory(
                        state.categoryFilter == c.id ? null : c.id),
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
              title: state.hasSearched
                  ? l10n.noResults
                  : l10n.noProducts,
              subtitle: state.hasSearched
                  ? l10n.tryDifferentSearch
                  : l10n.tapPlusToAdd,
            )
                : RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () =>
                  ref.read(productListProvider.notifier).load(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                itemCount: state.products.length,
                itemBuilder: (context, index) =>
                    _productCard(state.products[index], l10n),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: AppColors.black,
        icon: const Icon(Icons.add),
        label: Text(l10n.product),
      ),
    );
  }
}