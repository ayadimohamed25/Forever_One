import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/product_provider.dart';
import 'category_form_page.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../core/errors/error_text.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(categoryListProvider.notifier).load());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    AppSnack.show(context, message, error: isError);
  }

  Future<void> _openForm({CategoryEntity? existing}) async {
    final result = await Navigator.of(context, rootNavigator: true)
        .push<CategoryFormResult>(
          MaterialPageRoute(
            builder: (_) => CategoryFormPage(existing: existing),
          ),
        );
    if (result == null) return;

    if (existing == null) {
      await ref
          .read(categoryListProvider.notifier)
          .add(
            name: result.name,
            description: result.description,
            colorHex: result.colorHex,
          );
    } else {
      await ref
          .read(categoryListProvider.notifier)
          .update(
            id: existing.id,
            name: result.name,
            description: result.description,
            colorHex: result.colorHex,
          );
    }
  }

  Future<void> _delete(CategoryEntity c, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(c.name)),
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

    final error = await ref.read(categoryListProvider.notifier).remove(c.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.categoryDeleted);
    } else if (error == 'CATEGORY_IN_USE') {
      _showSnack(l10n.categoryInUse, isError: true);
    } else {
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  // Category (colour dot + name, description under) | Products | ⋮.
  List<AppTableColumn<CategoryEntity>> _columns(AppLocalizations l10n) => [
    AppTableColumn(
      label: l10n.category,
      sortValue: (c) => c.name.toLowerCase(),
      cell: (c) => Row(
        children: [
          AppColorDot(c.color, size: 10),
          const SizedBox(width: 10),
          Expanded(
            child: AppCellText(
              c.name,
              strong: true,
              maxLines: 2,
              sub: (c.description ?? '').trim().isEmpty ? null : c.description,
            ),
          ),
        ],
      ),
    ),
    AppTableColumn(
      label: l10n.colProducts,
      numeric: true,
      measure: (c) => '${c.productCount}',
      sortValue: (c) => c.productCount,
      cell: (c) => AppCellText('${c.productCount}', numeric: true),
    ),
  ];

  Widget _rowMenu(CategoryEntity c, AppLocalizations l10n) => AppRowMenu(
    actions: [
      AppMenuAction(
        label: l10n.edit,
        icon: Icons.edit_outlined,
        onTap: () => _openForm(existing: c),
      ),
      AppMenuAction(
        label: l10n.delete,
        icon: Icons.delete_outline,
        destructive: true,
        onTap: () => _delete(c, l10n),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(categoryListProvider, (previous, next) {
      if (next.error != null) {
        _showSnack(errorText(next.error, l10n), isError: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: searchVisible
          ? AppSearchHeader(
              controller: searchController,
              hint: l10n.searchCategories,
              onChanged: (v) =>
                  ref.read(categoryListProvider.notifier).search(v),
              onClose: () {
                setState(() => searchVisible = false);
                searchController.clear();
                ref.read(categoryListProvider.notifier).clearSearch();
              },
            )
          : AppPageHeader(
              title: l10n.categories,
              subtitle: state.categories.isEmpty
                  ? null
                  : '${state.categories.length} ${l10n.categories.toLowerCase()}',
              icon: Icons.category_outlined,
              color: AppColors.accent,
              actions: [
              ],
            ),
      body: state.isLoading
          ? AppSkeletonList(semanticLabel: l10n.loading)
          : state.error != null && state.categories.isEmpty
          ? AppErrorState(
              title: l10n.loadFailedTitle,
              message: l10n.serverUnreachable,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(categoryListProvider.notifier).load(),
            )
          : state.categories.isEmpty
          ? AppEmptyState(
              icon: state.hasSearched
                  ? Icons.search_off
                  : Icons.category_outlined,
              title: state.hasSearched ? l10n.noResults : l10n.noCategories,
              subtitle: state.hasSearched ? l10n.tryDifferentSearch : '',
              actionLabel: state.hasSearched ? null : l10n.category,
              onAction: () => _openForm(),
            )
          : RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () => ref.read(categoryListProvider.notifier).load(),
              child: AppDataTable<CategoryEntity>(
                columns: _columns(l10n),
                rows: state.categories,
                initialSortColumn: 0,
                onRowTap: (c) => _openForm(existing: c),
                rowMenu: (c) => _rowMenu(c, l10n),
                searchText: (c) => '${c.name} ${c.description ?? ''}',
                searchHint: l10n.searchCategories,
                onAdd: () => _openForm(),
                addLabel: l10n.category,
              ),
            ),
      floatingActionButton: AppAddFab(
        onPressed: () => _openForm(),
        label: l10n.category,
      ),
    );
  }
}
