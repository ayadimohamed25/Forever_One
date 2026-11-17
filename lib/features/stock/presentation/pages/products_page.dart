import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_side_panel.dart';
import '../widgets/product_detail_body.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';
import '../widgets/product_form_route.dart';
import 'categories_page.dart';
import 'product_detail_page.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_motion.dart';
import '../../../../core/errors/error_text.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  /// The product open in the side panel (wide screens only).
  String? selectedId;

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
    final input = await openProductForm(context, ref, existing: product);
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

    final error = await ref
        .read(productListProvider.notifier)
        .remove(product.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.productDeleted);
    } else if (error == 'PRODUCT_IN_USE') {
      _showSnack(l10n.productInUse, isError: true);
    } else {
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  /// Wide: open the side panel. Phone: open the detail page.
  Future<void> _openDetail(ProductEntity product) async {
    if (AppBreakpoints.isWide(context)) {
      setState(() => selectedId = product.id);
      return;
    }
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(productId: product.id),
      ),
    );
    if (mounted) ref.read(productListProvider.notifier).load();
  }

  Future<void> _openCategories() async {
    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => const CategoriesPage()));
    if (mounted) {
      ref.read(categoryListProvider.notifier).load();
      ref.read(productListProvider.notifier).load();
    }
  }

  /// Category chip: the same rounded pill as the status chips below it
  /// (white with a grey border; selected = light indigo, indigo text).
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
        borderRadius: BorderRadius.circular(999),
        color: selected ? AppColors.primarySoft : AppColors.surface,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.primaryBorder : AppColors.fieldBorder,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTheme.font(
              size: 13,
              weight: FontWeight.w500,
              color: selected ? AppColors.primaryText : AppColors.textLabel,
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

  Color? _categoryColor(ProductEntity p) => productCategoryColor(p);

  String _stockText(ProductEntity p, AppLocalizations l10n) =>
      p.currentStock <= 0
          ? l10n.statusOutOfStock
          : l10n.stockLeft('${p.currentStock}');

  String _margin(ProductEntity p) => p.price > 0
      ? '${((p.price - p.cost) / p.price * 100).toStringAsFixed(0)}%'
      : '—';

  // Order: name, information, amounts (there is no status column here; the
  // stock figure carries its own colour).
  List<AppTableColumn<ProductEntity>> _columns(AppLocalizations l10n) => [
    AppTableColumn(
      label: l10n.product,
      sortValue: (p) => p.name.toLowerCase(),
      cell: (p) {
        final dot = _categoryColor(p);
        return Opacity(
          opacity: p.isActive ? 1 : 0.55,
          // Phones hide the price column (no titles there to tell 7 from
          // 12.60): the price joins the category under the name.
          child: Builder(
            builder: (context) => AppCellText(
              p.name,
              strong: true,
              maxLines: 2,
              sub: AppTableWidth.of(context) >= 600
                  ? p.categoryName ?? l10n.noCategory
                  : '${p.categoryName ?? l10n.noCategory} · ${formatDT(_priceTtc(p))}',
              subLeading: dot == null ? null : AppColorDot(dot),
            ),
          ),
        );
      },
    ),
    AppTableColumn(
      label: l10n.colSku,
      showFrom: 600,
      maxWidth: 110,
      measure: (p) => p.sku ?? '—',
      sortValue: (p) => p.sku ?? '',
      cell: (p) => AppCellText(p.sku ?? '—', color: AppColors.textSecondary),
    ),
    AppTableColumn(
      label: l10n.supplier,
      showFrom: 760,
      maxWidth: 200,
      measure: (p) => p.supplierName ?? '—',
      sortValue: (p) => (p.supplierName ?? '').toLowerCase(),
      cell: (p) => AppCellText(p.supplierName ?? '—'),
    ),
    AppTableColumn(
      label: l10n.stock,
      numeric: true,
      measure: (p) => '${p.currentStock}',
      phoneMeasure: (p) => _stockText(p, l10n),
      sortValue: (p) => p.currentStock,
      cell: (p) => Builder(builder: (context) {
        final phone = AppTableWidth.of(context) < 600;
        final text = Text(
          phone ? _stockText(p, l10n) : '${p.currentStock}',
          maxLines: 1,
          style: AppTheme.font(
            size: 14,
            weight: p.isLowStock || p.currentStock <= 0
                ? FontWeight.w600
                : FontWeight.w400,
            color: _stockColor(p),
            tabularFigures: true,
          ),
        );
        if (!phone) return text;
        // Phones: "7 left" over a small level bar (full at 3× the minimum).
        final full = (p.minThreshold * 3).clamp(1, double.infinity);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            text,
            const SizedBox(height: 6),
            SizedBox(
              width: 56,
              child: AppMeter(
                value: (p.currentStock / full).clamp(0.04, 1).toDouble(),
                color: p.currentStock <= 0
                    ? AppColors.danger
                    : p.isLowStock
                        ? AppColors.warning
                        : AppColors.success,
                height: 5,
              ),
            ),
          ],
        );
      }),
    ),
    AppTableColumn(
      label: l10n.colVat,
      numeric: true,
      showFrom: 600,
      measure: (p) => '${p.vatRate.toStringAsFixed(0)}%',
      sortValue: (p) => p.vatRate,
      cell: (p) =>
          AppCellText('${p.vatRate.toStringAsFixed(0)}%', numeric: true),
    ),
    AppTableColumn(
      label: l10n.colMargin,
      numeric: true,
      showFrom: 900,
      measure: _margin,
      sortValue: (p) => p.price > 0 ? (p.price - p.cost) / p.price : 0,
      cell: (p) => AppCellText(_margin(p), numeric: true),
    ),
    AppTableColumn(
      label: l10n.colPriceInclVat,
      shortLabel: l10n.price,
      numeric: true,
      showFrom: 600,
      measure: (p) => formatDT(_priceTtc(p)),
      sortValue: (p) => _priceTtc(p),
      cell: (p) => AppCellText(formatDT(_priceTtc(p)), numeric: true),
    ),
  ];

  Widget _rowMenu(ProductEntity p, AppLocalizations l10n) => AppRowMenu(
    actions: [
      AppMenuAction(
        label: l10n.edit,
        icon: Icons.edit_outlined,
        onTap: () => _edit(p, l10n),
      ),
      AppMenuAction(
        label: l10n.delete,
        icon: Icons.delete_outline,
        destructive: true,
        onTap: () => _delete(p, l10n),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);
    final categories = ref.watch(categoryListProvider).categories;
    final l10n = AppLocalizations.of(context)!;

    ref.listen(productListProvider, (previous, next) {
      if (next.error != null) {
        _showSnack(errorText(next.error, l10n), isError: true);
      }
    });

    // Just the count: the strip and tabs split low stock and out of stock,
    // so a combined "4 low stock alerts" here contradicted them.
    final subtitle = state.products.isEmpty
        ? null
        : l10n.productCount(state.products.length);

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
                  icon: Icons.category_outlined,
                  tooltip: l10n.categories,
                  onTap: _openCategories,
                ),
              ],
            ),
      body: Column(
        children: [
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
                    title: state.hasSearched ? l10n.noResults : l10n.noProducts,
                    subtitle: state.hasSearched ? l10n.tryDifferentSearch : '',
                    actionLabel: state.hasSearched ? null : l10n.product,
                    onAction: _create,
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(productListProvider.notifier).load(),
                    child: AppDataTable<ProductEntity>(
                      // Category chips scroll with the list, under the
                      // search field (phones) and above the figures.
                      header: [
                        if (categories.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              height: 38,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _categoryChip(
                                    label: l10n.allCategories,
                                    selected: state.categoryFilter == null,
                                    onTap: () => ref
                                        .read(productListProvider.notifier)
                                        .filterByCategory(null),
                                  ),
                                  ...categories.map(
                                    (c) => _categoryChip(
                                      label: c.name,
                                      selected: state.categoryFilter == c.id,
                                      onTap: () => ref
                                          .read(productListProvider.notifier)
                                          .filterByCategory(
                                            state.categoryFilter == c.id
                                                ? null
                                                : c.id,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                      columns: _columns(l10n),
                      rows: state.products,
                      initialSortColumn: 0,
                      onRowTap: _openDetail,
                      rowMenu: (p) => _rowMenu(p, l10n),
                      searchText: (p) =>
                          '${p.name} ${p.sku ?? ''} ${p.barcode ?? ''} ${p.supplierName ?? ''}',
                      searchHint: l10n.searchProducts,
                      tabs: AppTableFilter(
                        label: l10n.stock,
                        options: [
                          AppFilterOption(l10n.filterAll),
                          AppFilterOption(
                            l10n.statusLowStock,
                            (p) => p.currentStock > 0 && p.isLowStock,
                          ),
                          AppFilterOption(
                            l10n.statusOutOfStock,
                            (p) => p.currentStock <= 0,
                          ),
                          AppFilterOption(l10n.inactive, (p) => !p.isActive),
                        ],
                      ),
                      summary: [
                        AppTableStat(
                          label: l10n.products,
                          value: '${state.products.length}',
                          tab: 0,
                        ),
                        AppTableStat(
                          label: l10n.stockValue,
                          value: formatDT(state.products.fold<double>(
                              0,
                              (t, p) =>
                                  t +
                                  (p.currentStock > 0
                                      ? p.currentStock * p.cost
                                      : 0))),
                        ),
                        AppTableStat(
                          label: l10n.statusLowStock,
                          value:
                              '${state.products.where((p) => p.currentStock > 0 && p.isLowStock).length}',
                          color: AppColors.warningText,
                          tab: 1,
                        ),
                        AppTableStat(
                          label: l10n.statusOutOfStock,
                          value:
                              '${state.products.where((p) => p.currentStock <= 0).length}',
                          color: AppColors.dangerText,
                          tab: 2,
                        ),
                      ],
                      isSelected: (p) => p.id == selectedId,
                      onSelectionHidden: () =>
                          setState(() => selectedId = null),
                      detailPanel: selectedId == null
                          ? null
                          : AppSidePanel(
                              closeLabel: l10n.close,
                              onClose: () =>
                                  setState(() => selectedId = null),
                              child: ProductDetailBody(
                                productId: selectedId!,
                                compact: true,
                                onChanged: () => ref
                                    .read(productListProvider.notifier)
                                    .load(),
                              ),
                            ),
                      onAdd: _create,
                      addLabel: l10n.product,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: AppAddFab(onPressed: _create, label: l10n.product),
    );
  }
}
