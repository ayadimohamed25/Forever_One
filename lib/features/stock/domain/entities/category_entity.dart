import 'package:flutter/material.dart';

class CategoryEntity {
  final String id;
  final String name;
  final String? description;
  final String? colorHex;
  final int productCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.colorHex,
    this.productCount = 0,
  });

  /// Warm neutral grey (the palette's secondary text colour).
  static const _fallback = Color(0xFF6B6258);

  /// Falls back to a neutral colour when the category has none set.
  Color get color {
    final hex = colorHex?.replaceAll('#', '');
    if (hex == null || hex.length != 6) return _fallback;
    final value = int.tryParse(hex, radix: 16);
    return value != null ? Color(0xFF000000 | value) : _fallback;
  }
}