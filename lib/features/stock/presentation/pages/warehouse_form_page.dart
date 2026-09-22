import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/repositories/warehouse_repository.dart';

/// Full-page warehouse form. Pops with a [WarehouseInput] on save.
class WarehouseFormPage extends StatefulWidget {
  final WarehouseEntity? existing;

  const WarehouseFormPage({super.key, this.existing});

  @override
  State<WarehouseFormPage> createState() => _WarehouseFormPageState();
}

class _WarehouseFormPageState extends State<WarehouseFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController codeController;
  late final TextEditingController locationController;
  late final TextEditingController addressController;
  late final TextEditingController managerController;
  late final TextEditingController phoneController;
  late final TextEditingController notesController;
  bool isActive = true;

  bool get isEdit => widget.existing != null;
  bool get canSave => nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    nameController = TextEditingController(text: e?.name ?? '')
      ..addListener(() => setState(() {}));
    codeController = TextEditingController(text: e?.code ?? '');
    locationController = TextEditingController(text: e?.location ?? '');
    addressController = TextEditingController(text: e?.address ?? '');
    managerController = TextEditingController(text: e?.managerName ?? '');
    phoneController = TextEditingController(text: e?.phone ?? '');
    notesController = TextEditingController(text: e?.notes ?? '');
    isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final c in [
      nameController,
      codeController,
      locationController,
      addressController,
      managerController,
      phoneController,
      notesController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _orNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  void _save() {
    if (!canSave) return;
    Navigator.of(context).pop(WarehouseInput(
      code: _orNull(codeController),
      name: nameController.text.trim(),
      location: _orNull(locationController),
      address: _orNull(addressController),
      managerName: _orNull(managerController),
      phone: _orNull(phoneController),
      isActive: isActive,
      notes: _orNull(notesController),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: isEdit ? l10n.editWarehouse : l10n.newWarehouse,
        subtitle: isEdit ? widget.existing!.name : null,
        icon: Icons.warehouse_outlined,
        color: AppColors.stock,
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
                controller: codeController,
                label: l10n.code,
                icon: Icons.tag,
              ),
              AppTextField(
                controller: locationController,
                label: l10n.location,
                icon: Icons.place_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppFormSection(
            title: l10n.contact,
            children: [
              AppTextField(
                controller: addressController,
                label: l10n.address,
                icon: Icons.map_outlined,
                maxLines: 2,
              ),
              AppTextField(
                controller: managerController,
                label: l10n.manager,
                icon: Icons.person_outline,
              ),
              AppTextField(
                controller: phoneController,
                label: l10n.phone,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppFormSection(
            title: l10n.notes,
            children: [
              AppTextField(
                controller: notesController,
                label: l10n.notes,
                maxLines: 3,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: isActive,
                title: Text(l10n.warehouseActive,
                    style: AppTheme.font(size: 15)),
                onChanged: (v) => setState(() => isActive = v),
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