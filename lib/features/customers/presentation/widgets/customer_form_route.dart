import 'package:flutter/material.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../pages/customer_form_page.dart';

/// Opens the customer form as a full page and returns what the user saved,
/// or null if they backed out.
/// Pushed on the root navigator, so the form covers the shell (no sidebar)
/// and has its own back button.
Future<CustomerInput?> openCustomerForm(
    BuildContext context, {
      CustomerEntity? existing,
    }) {
  return Navigator.of(context, rootNavigator: true).push<CustomerInput>(
    MaterialPageRoute(builder: (_) => CustomerFormPage(existing: existing)),
  );
}