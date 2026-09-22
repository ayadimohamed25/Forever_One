import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/category_entity.dart';

/// What the form gives back to the categories page.
typedef CategoryFormResult = ({String name, String? description, String? colorHex});

/// The only colours a category can take — all from the app palette.
const categoryPalette = [
  '#C8553D', // terracotta
  '#3F7D4E', // green
  '#A16207', // amber
  '#B42318', // red
  '#2A1F1A', // dark
  '#8F8078', // gray
];

Color colorFromHex(String hex) {
  final value = int.tryParse(hex.replaceAll('#', ''), radix: 16);
  return value != null ? Color(0xFF000000 | value) : AppColors.textSecondary;
}

/// Full-page category form. Pops with a [CategoryFormResult] on save.
class CategoryFormPage extends StatefulWidget {
  final CategoryEntity? existing;

  const CategoryFormPage({super.key, this.existing});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late String colorHex;

  bool get isEdit => widget.existing != null;
  bool get canSave => nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    nameController = TextEditingController(text: e?.name ?? '')
      ..addListener(() => setState(() {}));
    descriptionController = TextEditingController(text: e?.description ?? '');

    // Keep the saved colour when it is one of ours, otherwise start on the accent.
    final saved = e?.colorHex?.toUpperCase();
    colorHex = categoryPalette.contains(saved) ? saved! : categoryPalette.first;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!canSave) return;
    Navigator.of(context).pop((
    name: nameController.text.trim(),
    description: descriptionController.text.trim().isEmpty
        ? null
        : descriptionController.text.trim(),
    colorHex: colorHex,
    ));
  }

  Widget _swatch(String hex) {
    final color = colorFromHex(hex);
    final selected = colorHex == hex;

    return GestureDetector(
      onTap: () => setState(() => colorHex = hex),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: selected
              ? Border.all(color: AppColors.textPrimary, width: 2.5)
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, size: 20, color: Colors.white)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = colorFromHex(colorHex);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: isEdit ? l10n.editCategory : l10n.newCategory,
        subtitle: isEdit ? widget.existing!.name : null,
        icon: Icons.category_outlined,
        color: AppColors.accent,
        showMenuButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          AppFormSection(
            title: l10n.generalInfo,
            children: [
              AppTextField(
                controller: nameController,
                label: l10n.name,
                icon: Icons.label_outline,
                autofocus: !isEdit,
              ),
              AppTextField(
                controller: descriptionController,
                label: l10n.description,
                maxLines: 2,
              ),
            ],
          ),

          const SizedBox(height: 24),
          AppFormSection(
            title: l10n.color,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [for (final hex in categoryPalette) _swatch(hex)],
              ),
              const SizedBox(height: 4),
              // Preview of how the category will appear in the list.
              Row(
                children: [
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
                    child: Text(
                      nameController.text.trim().isEmpty
                          ? l10n.category
                          : nameController.text.trim(),
                      maxLines: 2,
                      style: AppTheme.rowTitle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: AppBottomActionBar(
        child: FilledButton(
          onPressed: canSave ? _save : null,
          child: Text(l10n.save),
        ),
      ),
    );
  }
}