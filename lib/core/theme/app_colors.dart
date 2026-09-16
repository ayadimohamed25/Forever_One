import 'package:flutter/material.dart';

/// Central colour palette. Every screen pulls from here so the app keeps
/// one visual identity instead of ad-hoc colours per widget.
class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF6C4BF4);
  static const primaryDark = Color(0xFF4A2FD4);
  static const primaryLight = Color(0xFF9B87F7);

  // Domain accents — each business area has its own identity
  static const sales = Color(0xFF10B981); // green: money coming in
  static const purchases = Color(0xFFF59E0B); // amber: money going out
  static const stock = Color(0xFF3B82F6); // blue: inventory
  static const finance = Color(0xFF8B5CF6); // violet: cash & payments
  static const ai = Color(0xFF6C4BF4); // brand purple
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF97316);
  static const success = Color(0xFF10B981);
  static const info = Color(0xFF0EA5E9);

  // Neutrals
  static const surface = Color(0xFFFCFBFF);
  static const surfaceAlt = Color(0xFFF4F2FB);
  static const border = Color(0xFFE8E4F3);
  static const textPrimary = Color(0xFF1A1533);
  static const textSecondary = Color(0xFF6B6785);

  // Gradients
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5CFC), Color(0xFF5B34E8)],
  );

  static LinearGradient tintGradient(Color color) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      color.withValues(alpha: 0.16),
      color.withValues(alpha: 0.05),
    ],
  );

  static List<BoxShadow> softShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1A1533).withValues(alpha: 0.05),
      blurRadius: 14,
      offset: const Offset(0, 3),
    ),
  ];
}