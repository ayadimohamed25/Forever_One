import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/repositories/supplier_repository.dart';

Future<SupplierInput?> showSupplierFormDialog(
    BuildContext context, {
      SupplierEntity? existing,
    }) {
  final l10n = AppLocalizations.of(context)!;
  final isEdit = existing != null;

  final nameController = TextEditingController(text: existing?.name ?? '');
  final contactController =
  TextEditingController(text: existing?.contactPerson ?? '');
  final phoneController = TextEditingController(text: existing?.phone ?? '');
  final emailController = TextEditingController(text: existing?.email ?? '');
  final addressController = TextEditingController(text: existing?.address ?? '');
  final taxIdController = TextEditingController(text: existing?.taxId ?? '');
  final bankController = TextEditingController(text: existing?.bankAccount ?? '');
  final notesController = TextEditingController(text: existing?.notes ?? '');
  final leadTimeController =
  TextEditingController(text: (existing?.leadTimeDays ?? 0).toString());
  final paymentTermsController =
  TextEditingController(text: (existing?.paymentTermsDays ?? 0).toString());

  return showDialog<SupplierInput>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? l10n.editSupplier : l10n.newSupplier),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: !isEdit,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  prefixIcon: const Icon(Icons.storefront_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: l10n.contactPerson,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.address,
                  prefixIcon: const Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: taxIdController,
                decoration: InputDecoration(
                  labelText: l10n.taxId,
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bankController,
                decoration: InputDecoration(
                  labelText: l10n.bankAccount,
                  prefixIcon: const Icon(Icons.account_balance_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: leadTimeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.leadTimeDays),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: paymentTermsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.paymentTerms),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  prefixIcon: const Icon(Icons.notes),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty) return;

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
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}