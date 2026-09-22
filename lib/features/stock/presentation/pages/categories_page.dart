import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/product_provider.dart';
import 'category_form_page.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  Future<void> _openForm({CategoryEntity? existing}) async {
    final result = await Navigator.of(context).push<CategoryFormResult>(
      MaterialPageRoute(builder: (_) => CategoryFormPage(existing: existing)),
    );
    if (result == null) return;

    if (existing == null) {
      await ref.read(categoryListProvider.notifier).add(
        name: result.name,
        description: result.description,
        colorHex: result.colorHex,
      );
    } else {
      await ref.read(categoryListProvider.notifier).update(
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
      _showSnack(error, isError: true);
    }
  }

  Widget _card(CategoryEntity c, AppLocalizations l10n) {
    final color = c.color;

    return AppCard(
      onTap: () => _openForm(existing: c),
      padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The category's own colour: soft background, same colour icon.
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.label_outline, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: AppTheme.rowTitle, maxLines: 2),
                if (c.description != null &&
                    c.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(c.description!, style: AppTheme.label, maxLines: 2),
                ],
                const SizedBox(height: 10),
                AppBadge(
                  label: l10n.productCount(c.productCount),
                  tone: BadgeTone.neutral,
                ),
              ],
            ),
          ),
          AppRowMenu(actions: [
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
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(categoryListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
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
        showMenuButton: false,
        actions: [
          AppHeaderAction(
            icon: Icons.search,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.categories.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.category_outlined,
        title:
        state.hasSearched ? l10n.noResults : l10n.noCategories,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToAdd,
      )
          : RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () =>
            ref.read(categoryListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: state.categories.length,
          itemBuilder: (context, index) =>
              _card(state.categories[index], l10n),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.black,
        icon: const Icon(Icons.add),
        label: Text(l10n.category),
      ),
    );
  }
}