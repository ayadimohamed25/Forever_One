import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';

/// Full-page customer form. Pops with a [CustomerInput] on save, or null
/// when the user backs out.
class CustomerFormPage extends StatefulWidget {
  final CustomerEntity? existing;

  const CustomerFormPage({super.key, this.existing});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController taxIdController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  late final TextEditingController creditLimitController;
  late final TextEditingController termsController;
  late final TextEditingController notesController;
  late CustomerType type;

  bool get isEdit => widget.existing != null;
  bool get canSave => nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    nameController = TextEditingController(text: e?.name ?? '')
      ..addListener(() => setState(() {}));
    taxIdController = TextEditingController(text: e?.taxId ?? '');
    phoneController = TextEditingController(text: e?.phone ?? '');
    emailController = TextEditingController(text: e?.email ?? '');
    addressController = TextEditingController(text: e?.address ?? '');
    creditLimitController = TextEditingController(
        text: e != null ? e.creditLimit.toStringAsFixed(2) : '');
    termsController =
        TextEditingController(text: '${e?.paymentTermsDays ?? 0}');
    notesController = TextEditingController(text: e?.notes ?? '');
    type = e?.customerType ?? CustomerType.company;
  }

  @override
  void dispose() {
    for (final c in [
      nameController,
      taxIdController,
      phoneController,
      emailController,
      addressController,
      creditLimitController,
      termsController,
      notesController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _orNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  /// Accepts "5000.5" and "5000,5" — French keyboards use a comma.
  double _decimal(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  void _save() {
    if (!canSave) return;
    Navigator.of(context).pop(CustomerInput(
      name: nameController.text.trim(),
      phone: _orNull(phoneController),
      email: _orNull(emailController),
      address: _orNull(addressController),
      taxId: _orNull(taxIdController),
      customerType: type,
      paymentTermsDays: int.tryParse(termsController.text.trim()) ?? 0,
      notes: _orNull(notesController),
      creditLimit: _decimal(creditLimitController),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: isEdit ? l10n.editCustomer : l10n.newCustomer,
        subtitle: isEdit ? widget.existing!.name : null,
        icon: Icons.person_outline,
        color: AppColors.finance,
        showMenuButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          AppFormSection(
            title: l10n.customerType,
            children: [
              // Selected option in dark ink with white text.
              AppSegmentedControl<CustomerType>(
                options: [
                  (
                  value: CustomerType.company,
                  label: l10n.company,
                  icon: Icons.business_outlined
                  ),
                  (
                  value: CustomerType.individual,
                  label: l10n.individual,
                  icon: Icons.person_outline
                  ),
                ],
                selected: type,
                onChanged: (t) => setState(() => type = t),
              ),
            ],
          ),

          const SizedBox(height: 24),
          AppFormSection(
            title: l10n.generalInfo,
            children: [
              AppTextField(
                controller: nameController,
                label: l10n.name,
                icon: Icons.badge_outlined,
                autofocus: !isEdit,
              ),
              AppTextField(
                controller: taxIdController,
                label: l10n.taxId,
                icon: Icons.numbers,
              ),
            ],
          ),

          const SizedBox(height: 24),
          AppFormSection(
            title: l10n.contact,
            children: [
              AppTextField(
                controller: phoneController,
                label: l10n.phone,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              AppTextField(
                controller: emailController,
                label: l10n.email,
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              AppTextField(
                controller: addressController,
                label: l10n.address,
                icon: Icons.place_outlined,
                maxLines: 2,
              ),
            ],
          ),

          const SizedBox(height: 24),
          AppFormSection(
            title: l10n.commercialInfo,
            children: [
              AppTextField(
                controller: creditLimitController,
                label: l10n.creditLimit,
                icon: Icons.credit_card_outlined,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                suffix: 'DT',
              ),
              AppTextField(
                controller: termsController,
                label: l10n.paymentTerms,
                icon: Icons.schedule_outlined,
                keyboardType: TextInputType.number,
                suffix: l10n.days,
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