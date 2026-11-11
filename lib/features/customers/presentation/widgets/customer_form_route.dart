import 'package:flutter/material.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../pages/customer_form_page.dart';

/// Opens the customer form as a full page and returns what the user saved,
/// or null if they backed out.
///
/// Kept under its original name and signature so the Customers list and the
/// customer detail page call it unchanged.
Future<CustomerInput?> showCustomerFormDialog(
    BuildContext context, {
      CustomerEntity? existing,
    }) {
  return Navigator.of(context).push<CustomerInput>(
    MaterialPageRoute(builder: (_) => CustomerFormPage(existing: existing)),
  );
}