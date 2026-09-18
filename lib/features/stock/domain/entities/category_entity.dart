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

  /// Falls back to a neutral colour when the category has none set.
  Color get color {
    final hex = colorHex?.replaceAll('#', '');
    if (hex == null || hex.length != 6) return const Color(0xFF6B6785);
    final value = int.tryParse(hex, radix: 16);
    return value != null ? Color(0xFF000000 | value) : const Color(0xFF6B6785);
  }
}