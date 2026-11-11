import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/repositories/supplier_repository.dart';

/// Opens the supplier form as a full page (like every other form) and
/// returns what the user saved, or null if they backed out.
Future<SupplierInput?> openSupplierForm(
  BuildContext context, {
  SupplierEntity? existing,
}) {
  return Navigator.of(context, rootNavigator: true).push<SupplierInput>(
    MaterialPageRoute(builder: (_) => SupplierFormPage(existing: existing)),
  );
}

class SupplierFormPage extends StatefulWidget {
  final SupplierEntity? existing;
  const SupplierFormPage({super.key, this.existing});

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController contactController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  late final TextEditingController taxIdController;
  late final TextEditingController bankController;
  late final TextEditingController notesController;
  late final TextEditingController leadTimeController;
  late final TextEditingController paymentTermsController;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    nameController = TextEditingController(text: e?.name ?? '');
    contactController = TextEditingController(text: e?.contactPerson ?? '');
    phoneController = TextEditingController(text: e?.phone ?? '');
    emailController = TextEditingController(text: e?.email ?? '');
    addressController = TextEditingController(text: e?.address ?? '');
    taxIdController = TextEditingController(text: e?.taxId ?? '');
    bankController = TextEditingController(text: e?.bankAccount ?? '');
    notesController = TextEditingController(text: e?.notes ?? '');
    leadTimeController =
        TextEditingController(text: (e?.leadTimeDays ?? 0).toString());
    paymentTermsController =
        TextEditingController(text: (e?.paymentTermsDays ?? 0).toString());
    nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [
      nameController, contactController, phoneController, emailController,
      addressController, taxIdController, bankController, notesController,
      leadTimeController, paymentTermsController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get canSave => nameController.text.trim().isNotEmpty;

  void _save() {
    if (!canSave) return;
    String? orNull(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    Navigator.of(context).pop(SupplierInput(
      name: nameController.text.trim(),
      phone: orNull(phoneController),
      email: orNull(emailController),
      address: orNull(addressController),
      taxId: orNull(taxIdController),
      contactPerson: orNull(contactController),
      paymentTermsDays: int.tryParse(paymentTermsController.text) ?? 0,
      bankAccount: orNull(bankController),
      notes: orNull(notesController),
      leadTimeDays: int.tryParse(leadTimeController.text) ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: isEdit ? l10n.editSupplier : l10n.newSupplier,
        subtitle: isEdit ? widget.existing!.name : null,
        icon: Icons.local_shipping_outlined,
        color: AppColors.primary,
        showMenuButton: false,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              AppFormSection(
                title: l10n.generalInfo,
                children: [
                  AppTextField(
                    controller: nameController,
                    label: l10n.name,
                    required: true,
                    autofocus: !isEdit,
                  ),
                  AppTextField(
                    controller: contactController,
                    label: l10n.contactPerson,
                  ),
                  AppTextField(
                    controller: taxIdController,
                    label: l10n.taxId,
                  ),
                ],
              ),
              AppFormSection(
                title: l10n.contact,
                children: [
                  _pair(
                    AppTextField(
                      controller: phoneController,
                      label: l10n.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    AppTextField(
                      controller: emailController,
                      label: l10n.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  AppTextField(
                    controller: addressController,
                    label: l10n.address,
                    maxLines: 2,
                  ),
                ],
              ),
              AppFormSection(
                title: l10n.commercialInfo,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: leadTimeController,
                          label: l10n.leadTimeDays,
                          keyboardType: TextInputType.number,
                          suffix: l10n.days,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: paymentTermsController,
                          label: l10n.paymentTerms,
                          keyboardType: TextInputType.number,
                          suffix: l10n.days,
                        ),
                      ),
                    ],
                  ),
                  AppTextField(
                    controller: bankController,
                    label: l10n.bankAccount,
                  ),
                ],
              ),
              AppFormSection(
                title: l10n.notes,
                children: [
                  AppTextField(
                    controller: notesController,
                    label: l10n.notes,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('* ${l10n.requiredField}',
                  style: AppTheme.font(size: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomActionBar(
        child: FilledButton(
          onPressed: canSave ? _save : null,
          child: Text(l10n.save),
        ),
      ),
    );
  }

  /// Two short fields side by side when there is room, stacked on narrow
  /// phones.
  Widget _pair(Widget a, Widget b) => LayoutBuilder(
        builder: (context, box) => box.maxWidth >= 420
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: a),
                  const SizedBox(width: 12),
                  Expanded(child: b),
                ],
              )
            : Column(children: [a, const SizedBox(height: 14), b]),
      );
}
