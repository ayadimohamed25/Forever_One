import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';
import '../widgets/product_form_route.dart';
import 'categories_page.dart';
import 'product_detail_page.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/errors/error_text.dart';

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
    AppSnack.show(context, message, error: isError);
  }

  Future<void> _create() async {
    final input = await openProductForm(context, ref);
    if (input == null) return;
    await ref.read(productListProvider.notifier).add(input);
  }

  Future<void> _edit(ProductEntity product, AppLocalizations l10n) async {
    final input =
    await openProductForm(context, ref, existing: product);
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
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  Future<void> _openDetail(ProductEntity product) async {
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => ProductDetailPage(productId: product.id),
    ));
    if (mounted) ref.read(productListProvider.notifier).load();
  }

  Future<void> _openCategories() async {
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => const CategoriesPage(),
    ));
    if (mounted) {
      ref.read(categoryListProvider.notifier).load();
      ref.read(productListProvider.notifier).load();
    }
  }

  /// Filter chip: white with a grey border; selected = light blue, blue text.
  Widget _categoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppPressable(
        onTap: onTap,
        selected: selected,
        semanticLabel: label,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        color: selected ? AppColors.primarySoft : AppColors.surface,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.fieldBorder),
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Text(
            label,
            style: AppTheme.font(
              size: 13,
              weight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textLabel,
            ),
          ),
        ),
      ),
    );
  }

  double _priceTtc(ProductEntity p) => p.price * (1 + p.vatRate / 100);

  /// Stock figure: red when out, amber when at or below the minimum.
  Color _stockColor(ProductEntity p) => p.currentStock <= 0
      ? AppColors.dangerText
      : p.isLowStock
          ? AppColors.warningText
          : AppColors.textPrimary;

  List<AppTableColumn<ProductEntity>> _columns(AppLocalizations l10n) => [
        AppTableColumn(
          label: l10n.product,
          flex: 4,
          sortValue: (p) => p.name.toLowerCase(),
          cell: (p) => Opacity(
            opacity: p.isActive ? 1 : 0.55,
            child: AppCellText(p.name,
                strong: true, sub: p.categoryName ?? l10n.noCategory),
          ),
        ),
        AppTableColumn(
          label: l10n.colSku,
          flex: 2,
          showFrom: 600,
          sortValue: (p) => p.sku ?? '',
          cell: (p) => AppCellText(p.sku ?? '—', color: AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.supplier,
          flex: 3,
          showFrom: 760,
          sortValue: (p) => (p.supplierName ?? '').toLowerCase(),
          cell: (p) => AppCellText(p.supplierName ?? '—'),
        ),
        AppTableColumn(
          label: l10n.stock,
          width: 64,
          numeric: true,
          sortValue: (p) => p.currentStock,
          cell: (p) => Text(
            '${p.currentStock}',
            style: AppTheme.font(
              size: 14,
              weight: p.isLowStock || p.currentStock <= 0
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: _stockColor(p),
              tabularFigures: true,
            ),
          ),
        ),
        AppTableColumn(
          label: l10n.colVat,
          width: 56,
          numeric: true,
          showFrom: 600,
          sortValue: (p) => p.vatRate,
          cell: (p) => AppCellText('${p.vatRate.toStringAsFixed(0)}%', numeric: true),
        ),
        AppTableColumn(
          label: l10n.colMargin,
          width: 72,
          numeric: true,
          showFrom: 900,
          sortValue: (p) => p.price > 0 ? (p.price - p.cost) / p.price : 0,
          cell: (p) => AppCellText(
              p.price > 0
                  ? '${((p.price - p.cost) / p.price * 100).toStringAsFixed(0)}%'
                  : '—',
              numeric: true),
        ),
        AppTableColumn(
          label: l10n.colPriceInclVat,
          width: 112,
          numeric: true,
          sortValue: (p) => _priceTtc(p),
          cell: (p) => AppCellText(formatDT(_priceTtc(p)), numeric: true),
        ),
      ];

  Widget _rowMenu(ProductEntity p, AppLocalizations l10n) => AppRowMenu(actions: [
        AppMenuAction(
            label: l10n.edit,
            icon: Icons.edit_outlined,
            onTap: () => _edit(p, l10n)),
        AppMenuAction(
            label: l10n.delete,
            icon: Icons.delete_outline,
            destructive: true,
            onTap: () => _delete(p, l10n)),
      ]);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);
    final categories = ref.watch(categoryListProvider).categories;
    final l10n = AppLocalizations.of(context)!;

    ref.listen(productListProvider, (previous, next) {
      if (next.error != null) _showSnack(errorText(next.error, l10n), isError: true);
    });

    final lowStockCount = state.products.where((p) => p.isLowStock).length;
    final subtitle = state.products.isEmpty
        ? null
        : lowStockCount > 0
        ? '${state.products.length} · $lowStockCount ${l10n.lowStockAlerts.toLowerCase()}'
        : '${state.products.length} ${l10n.products.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
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
          AppHeaderAddButton(onPressed: _create, label: l10n.product),
        ],
      ),
      body: Column(
        children: [
          if (categories.isNotEmpty && !searchVisible)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                ? AppSkeletonList(semanticLabel: l10n.loading)
                : state.error != null && state.products.isEmpty
                ? AppErrorState(
                    title: l10n.loadFailedTitle,
                    message: l10n.serverUnreachable,
                    retryLabel: l10n.retry,
                    onRetry: () =>
                        ref.read(productListProvider.notifier).load(),
                  )
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
                  : '',
              actionLabel: state.hasSearched ? null : l10n.product,
              onAction: _create,
            )
                : RefreshIndicator(
              onRefresh: () =>
                  ref.read(productListProvider.notifier).load(),
              child: AppDataTable<ProductEntity>(
                columns: _columns(l10n),
                rows: state.products,
                initialSortColumn: 0,
                onRowTap: _openDetail,
                rowMenu: (p) => _rowMenu(p, l10n),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AppAddFab(onPressed: _create, label: l10n.product),
    );
  }
}