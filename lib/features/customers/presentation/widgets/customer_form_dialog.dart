import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';

Future<CustomerInput?> showCustomerFormDialog(
    BuildContext context, {
      CustomerEntity? existing,
    }) {
  final l10n = AppLocalizations.of(context)!;
  final isEdit = existing != null;

  final nameController = TextEditingController(text: existing?.name ?? '');
  final phoneController = TextEditingController(text: existing?.phone ?? '');
  final emailController = TextEditingController(text: existing?.email ?? '');
  final addressController = TextEditingController(text: existing?.address ?? '');
  final taxIdController = TextEditingController(text: existing?.taxId ?? '');
  final notesController = TextEditingController(text: existing?.notes ?? '');
  final creditController = TextEditingController(
      text: existing != null ? existing.creditLimit.toStringAsFixed(0) : '0');
  final paymentTermsController = TextEditingController(
      text: (existing?.paymentTermsDays ?? 0).toString());

  var customerType = existing?.customerType ?? CustomerType.company;

  return showDialog<CustomerInput>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEdit ? l10n.editCustomer : l10n.newCustomer),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<CustomerType>(
                  segments: [
                    ButtonSegment(
                      value: CustomerType.company,
                      label: Text(l10n.company,
                          style: const TextStyle(fontSize: 12)),
                      icon: const Icon(Icons.business, size: 16),
                    ),
                    ButtonSegment(
                      value: CustomerType.individual,
                      label: Text(l10n.individual,
                          style: const TextStyle(fontSize: 12)),
                      icon: const Icon(Icons.person, size: 16),
                    ),
                  ],
                  selected: {customerType},
                  onSelectionChanged: (s) =>
                      setState(() => customerType = s.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: !isEdit,
                  decoration: InputDecoration(
                    labelText: l10n.name,
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: creditController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.creditLimit,
                          suffixText: 'DT',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: paymentTermsController,
                        keyboardType: TextInputType.number,
                        decoration:
                        InputDecoration(labelText: l10n.paymentTerms),
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

              Navigator.of(context).pop(CustomerInput(
                name: nameController.text.trim(),
                phone: orNull(phoneController),
                email: orNull(emailController),
                address: orNull(addressController),
                taxId: orNull(taxIdController),
                customerType: customerType,
                paymentTermsDays: int.tryParse(paymentTermsController.text) ?? 0,
                notes: orNull(notesController),
                creditLimit: double.tryParse(creditController.text) ?? 0,
              ));
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    ),
  );
}