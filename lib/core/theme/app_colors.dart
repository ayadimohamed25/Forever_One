import 'package:flutter/material.dart';

/// "Ledger" palette: light grey page, white bordered cards, an ink sidebar,
/// one indigo for action, status colours only for status. No gradients.
///
/// Older token names (accent, black, sales, stock…) are kept so every screen
/// picks up the new look without edits; they resolve to the values below.
class AppColors {
  AppColors._();

  // ── Canvas & surfaces ──
  static const canvas = Color(0xFFF5F6F8);
  static const surface = Color(0xFFFFFFFF);

  /// Table header rows, subtle zebra, hover.
  static const surfaceAlt = Color(0xFFF9FAFB);

  /// Neutral fills: selected segment, neutral chip, skeleton.
  static const fill = Color(0xFFF2F4F7);

  /// Card and divider border.
  static const border = Color(0xFFE5E7EB);

  /// Input border (a touch darker than card borders so fields read as fields).
  static const fieldBorder = Color(0xFFD0D5DD);

  /// Empty progress tracks, empty chart days.
  static const track = Color(0xFFEAECF0);

  // ── Text ──
  static const textPrimary = Color(0xFF101828);

  /// Secondary text and captions (at least 4.5:1 on white and on the page).
  static const textSecondary = Color(0xFF5D6676);

  /// Field labels.
  static const textLabel = Color(0xFF344054);

  /// Placeholders and disabled text only, never information (2.58:1).
  static const textMuted = Color(0xFF98A2B3);

  /// Secondary text on dark surfaces such as chart tooltips.
  static const textOnInkMuted = Color(0xFFD0D5DD);

  // ── Icons ──
  static const icon = Color(0xFF344054);
  static const iconMuted = Color(0xFF667085);

  // ── Primary: indigo ──
  static const primary = Color(0xFF4F46E5);
  static const primaryHover = Color(0xFF4338CA);
  static const primarySoft = Color(0xFFEEF2FF);
  static const primaryBorder = Color(0xFFC7D2FE);

  /// Text on a primarySoft fill (selected chip, active tab label).
  static const primaryText = Color(0xFF3730A3);

  /// Background of the selected table row (its panel is open).
  static const rowSelected = Color(0xFFF5F5FF);

  /// Light indigo for secondary chart bars.
  static const primaryLight = Color(0xFFC7D2FE);

  // ── Sidebar: ink ──
  static const sidebar = Color(0xFF0E1525);
  static const sidebarHover = Color(0xFF1A2236);
  static const sidebarActive = Color(0xFF1E2840);
  static const sidebarText = Color(0xFFB4BCCB);
  static const sidebarTextMuted = Color(0xFF8A94A7);
  static const sidebarRule = Color(0xFF253049);

  // Former accent names now point at the primary blue.
  static const accent = primary;
  static const accentSoft = primarySoft;
  static const accentText = primary;
  static const accentStrong = primary;

  /// Dark ink: tooltips, snackbars, neutral strong text.
  static const black = Color(0xFF101828);
  static const primaryDark = primaryHover;

  // ── Status ──
  // The base colours are for icons, dots and bars (3:1 non-text). Text on a
  // status chip uses the *Text shade, which reaches 4.5:1.
  static const success = Color(0xFF16A34A);
  static const successText = Color(0xFF067647);
  static const successSoft = Color(0xFFECFDF3);
  static const warning = Color(0xFFD97706);
  static const warningText = Color(0xFFB54708);
  static const warningSoft = Color(0xFFFFFAEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const danger = Color(0xFFDC2626);
  static const dangerText = Color(0xFFB42318);
  static const dangerSoft = Color(0xFFFEF3F2);

  /// Background for neutral badges (counts, information without status).
  static const neutralSoft = Color(0xFFF2F4F7);

  /// The colours a stock category can be given, stored as hex on the
  /// category. Distinct in lightness as well as hue.
  static const categorySwatches = [
    '#4F46E5', // indigo
    '#0E9384', // teal
    '#D97706', // amber
    '#DD2590', // pink
    '#16A34A', // green
    '#DC2626', // red
    '#101828', // ink
    '#667085', // grey
  ];

  // ── Compatibility aliases (neutral on purpose: colour is never a category) ──
  static const sales = textPrimary;
  static const salesSoft = fill;
  static const purchases = icon;
  static const purchasesSoft = fill;
  static const stock = icon;
  static const stockSoft = fill;
  static const finance = icon;
  static const financeSoft = fill;
  static const ai = primary;
  static const info = Color(0xFF3538CD);
  static const infoSoft = Color(0xFFEEF4FF);
  static const surfaceTint = fill;

  /// Kept for API compatibility — always flat, never a gradient.
  static const brandGradient = LinearGradient(colors: [primary, primary]);

  /// The soft background that pairs with a status colour; neutral otherwise.
  static Color soft(Color color) {
    if (color == primary) return primarySoft;
    if (color == info) return infoSoft;
    if (color == success || color == successText) return successSoft;
    if (color == warning || color == warningText) return warningSoft;
    if (color == danger || color == dangerText) return dangerSoft;
    return fill;
  }

  /// The readable text shade for a status colour (chips, amounts).
  static Color textOn(Color color) {
    if (color == success) return successText;
    if (color == warning) return warningText;
    if (color == danger) return dangerText;
    return color;
  }

  /// Kept for compatibility — returns a flat fill, not a gradient.
  static LinearGradient tintGradient(Color color) {
    final c = soft(color);
    return LinearGradient(colors: [c, c]);
  }

  /// Cards are separated by their 1px border; this shadow is barely there.
  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x0A101828),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ];

  /// Kept for compatibility — same light shadow regardless of colour.
  static List<BoxShadow> softShadow(Color color) => cardShadow;
}
