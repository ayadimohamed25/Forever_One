import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/product_provider.dart';

const _palette = [
  '#6C4BF4',
  '#10B981',
  '#3B82F6',
  '#F59E0B',
  '#EF4444',
  '#8B5CF6',
  '#0EA5E9',
  '#EC4899',
];

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(categoryListProvider.notifier).load());
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
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descriptionController =
    TextEditingController(text: existing?.description ?? '');
    var colorHex = existing?.colorHex ?? _palette.first;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? l10n.newCategory : l10n.editCategory),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: existing == null,
                  decoration: InputDecoration(labelText: l10n.name),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: l10n.description),
                ),
                const SizedBox(height: 16),
                Text(l10n.color,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _palette.map((hex) {
                    final color = Color(
                        0xFF000000 | int.parse(hex.substring(1), radix: 16));
                    final selected = colorHex == hex;
                    return GestureDetector(
                      onTap: () => setState(() => colorHex = hex),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.textPrimary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                            size: 17, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;

    final name = nameController.text.trim();
    final description = descriptionController.text.trim().isEmpty
        ? null
        : descriptionController.text.trim();

    if (existing == null) {
      await ref
          .read(categoryListProvider.notifier)
          .add(name: name, description: description, colorHex: colorHex);
    } else {
      await ref.read(categoryListProvider.notifier).update(
        id: existing.id,
        name: name,
        description: description,
        colorHex: colorHex,
      );
    }
  }

  Future<void> _delete(CategoryEntity category, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(category.name)),
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
    await ref.read(categoryListProvider.notifier).remove(category.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.categoryDeleted);
    } else if (error == 'CATEGORY_IN_USE') {
      _showSnack(l10n.categoryInUse, isError: true);
    } else {
      _showSnack(error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.categories),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.categories.isEmpty
          ? AppEmptyState(
        icon: Icons.category_outlined,
        title: l10n.noCategories,
        subtitle: l10n.tapPlusToAdd,
        color: AppColors.primary,
      )
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(categoryListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: state.categories.length,
          itemBuilder: (context, index) {
            final c = state.categories[index];
            return AppCard(
              onTap: () => _openForm(existing: c),
              padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: c.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                          color: c.color.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.label_outline,
                        size: 20, color: c.color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text(
                          c.description ??
                              l10n.productCount(c.productCount),
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppStatusChip(
                      label: '${c.productCount}', color: c.color),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 19, color: AppColors.textSecondary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openForm(existing: c);
                      } else if (value == 'delete') {
                        _delete(c, l10n);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const SizedBox(width: 10),
                          Text(l10n.edit),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          const Icon(Icons.delete_outline,
                              size: 18, color: AppColors.danger),
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(l10n.category),
      ),
    );
  }
}