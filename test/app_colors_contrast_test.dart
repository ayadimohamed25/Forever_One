import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/core/theme/app_colors.dart';

/// WCAG 2.x relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  // Every pair that renders informational text must reach WCAG AA (4.5:1).
  final textPairs = <String, (Color, Color)>{
    'textPrimary on canvas': (AppColors.textPrimary, AppColors.canvas),
    'textSecondary on white': (AppColors.textSecondary, AppColors.surface),
    'textSecondary on canvas': (AppColors.textSecondary, AppColors.canvas),
    'textLabel on white': (AppColors.textLabel, AppColors.surface),
    'primary text on white': (AppColors.primary, AppColors.surface),
    'primary text on canvas': (AppColors.primary, AppColors.canvas),
    'primary on primarySoft': (AppColors.primary, AppColors.primarySoft),
    'white on primary (buttons)': (Colors.white, AppColors.primary),
    'white on ink (tooltips, snackbars)': (Colors.white, AppColors.black),
    'textOnInkMuted on ink': (AppColors.textOnInkMuted, AppColors.black),
    'successText on successSoft': (AppColors.successText, AppColors.successSoft),
    'successText on white': (AppColors.successText, AppColors.surface),
    'warningText on warningSoft': (AppColors.warningText, AppColors.warningSoft),
    'warningText on white': (AppColors.warningText, AppColors.surface),
    'dangerText on dangerSoft': (AppColors.dangerText, AppColors.dangerSoft),
    'dangerText on white': (AppColors.dangerText, AppColors.surface),
    'white on danger (badge count)': (Colors.white, AppColors.danger),
  };

  for (final entry in textPairs.entries) {
    test('${entry.key} is at least 4.5:1', () {
      final (fg, bg) = entry.value;
      expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
    });
  }

  // Non-text UI (icons, focus ring) needs 3:1.
  test('status and primary colours are at least 3:1 as icons and bars', () {
    for (final c in [AppColors.primary, AppColors.success, AppColors.warning, AppColors.danger]) {
      expect(contrast(c, AppColors.surface), greaterThanOrEqualTo(3.0));
    }
  });

  test('textMuted is only used for placeholders and disabled text', () {
    // Placeholders and disabled controls are exempt from WCAG contrast; this
    // documents the value so nobody starts using it for information.
    expect(contrast(AppColors.textMuted, AppColors.surface), lessThan(4.5));
  });
}
