import 'package:flutter/material.dart';

/// Warm neutral palette: cream canvas, white cards, warm dark ink,
/// a terracotta accent, and semantic colours used only for status.
///
/// The domain names (sales, stock, purchases…) are kept so existing screens
/// keep compiling. They resolve to the neutral scale — colour is never used to
/// categorise, only to signal state.
class AppColors {
  AppColors._();

  // ── Canvas & surfaces ──
  static const canvas = Color(0xFFF3EEE7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF3EEE7);
  static const fill = Color(0xFFF0E9E0);
  static const border = Color(0xFFEAE3DA);

  /// Empty progress tracks, empty chart days, unselected borders.
  static const track = Color(0xFFEAE3DA);

  // ── Text ──
  static const textPrimary = Color(0xFF1C1814);
  static const textSecondary = Color(0xFF8C8378);
  static const textMuted = Color(0xFFB8AFA3);

  // ── Icons ──
  static const icon = Color(0xFF3D3731);
  static const iconMuted = Color(0xFF8C8378);

  // ── Accent: terracotta ──
  static const accent = Color(0xFFC8553D);
  static const accentSoft = Color(0xFFF8E4DD);

  // ── Dark ink: primary buttons, selected chips and tabs ──
  static const black = Color(0xFF2A1F1A);

  // ── Status ──
  static const success = Color(0xFF3F7D4E);
  static const successSoft = Color(0xFFE5F0E7);
  static const warning = Color(0xFFA16207);
  static const warningSoft = Color(0xFFFBF0D5);
  static const danger = Color(0xFFB42318);
  static const dangerSoft = Color(0xFFFBE4E1);

  /// Background for neutral badges (counts, information without status).
  static const neutralSoft = Color(0xFFF5F1EC);

  // ── Compatibility aliases (neutral on purpose) ──
  static const primary = Color(0xFF2A1F1A);
  static const primaryDark = Color(0xFF1C1814);
  static const primaryLight = Color(0xFF3D3731);
  static const primarySoft = Color(0xFFF0E9E0);

  static const sales = Color(0xFF2A1F1A);
  static const salesSoft = Color(0xFFF0E9E0);
  static const purchases = Color(0xFF3D3731);
  static const purchasesSoft = Color(0xFFF0E9E0);
  static const stock = Color(0xFF3D3731);
  static const stockSoft = Color(0xFFF0E9E0);
  static const finance = Color(0xFF3D3731);
  static const financeSoft = Color(0xFFF0E9E0);
  static const ai = Color(0xFF2A1F1A);
  static const info = Color(0xFF3D3731);
  static const infoSoft = Color(0xFFF0E9E0);

  /// Kept for API compatibility — always flat, never a gradient.
  static const brandGradient = LinearGradient(
    colors: [Color(0xFF2A1F1A), Color(0xFF2A1F1A)],
  );

  /// The soft background that pairs with a status colour; neutral otherwise.
  static Color soft(Color color) {
    if (color == accent) return accentSoft;
    if (color == success) return successSoft;
    if (color == warning) return warningSoft;
    if (color == danger) return dangerSoft;
    return fill;
  }

  /// Kept for compatibility — returns a flat fill, not a gradient.
  static LinearGradient tintGradient(Color color) {
    final c = soft(color);
    return LinearGradient(colors: [c, c]);
  }

  /// Barely-there elevation, tinted warm so it doesn't read gray on cream.
  static List<BoxShadow> get cardShadow => const [
    BoxShadow(
      color: Color(0x0D3D2A1A),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  /// Kept for compatibility — same soft shadow regardless of colour.
  static List<BoxShadow> softShadow(Color color) => cardShadow;
}