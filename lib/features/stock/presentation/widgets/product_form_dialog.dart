import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../pages/product_form_page.dart';

/// Opens the product form as a full page and returns what the user saved,
/// or null if they backed out.
///
/// Kept under its original name and signature so the products list and the
/// product detail page call it unchanged. [ref] is no longer needed here but
/// stays for that compatibility.
Future<ProductInput?> showProductFormDialog(
    BuildContext context,
    WidgetRef ref, {
      ProductEntity? existing,
    }) {
  return Navigator.of(context).push<ProductInput>(
    MaterialPageRoute(builder: (_) => ProductFormPage(existing: existing)),
  );
}