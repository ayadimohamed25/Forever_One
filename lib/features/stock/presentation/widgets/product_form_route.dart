import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../pages/product_form_page.dart';

/// Opens the product form as a full page and returns what the user saved,
/// or null if they backed out.
/// Pushed on the root navigator, so the form covers the shell (no sidebar)
/// and has its own back button.
Future<ProductInput?> openProductForm(
    BuildContext context,
    WidgetRef ref, {
      ProductEntity? existing,
    }) {
  return Navigator.of(context, rootNavigator: true).push<ProductInput>(
    MaterialPageRoute(builder: (_) => ProductFormPage(existing: existing)),
  );
}