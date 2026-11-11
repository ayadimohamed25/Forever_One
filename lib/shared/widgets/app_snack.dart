import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One place for transient feedback, so every screen's snackbars look and
/// behave the same: floating, warm ink for success, danger red for errors,
/// with an icon so the meaning doesn't rely on colour alone.
class AppSnack {
  AppSnack._();

  static void success(BuildContext context, String message) =>
      _show(context, message, error: false);

  static void error(BuildContext context, String message) =>
      _show(context, message, error: true);

  /// For call sites that decide at runtime.
  static void show(BuildContext context, String message, {bool error = false}) =>
      _show(context, message, error: error);

  static void _show(BuildContext context, String message,
      {required bool error}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: error ? AppColors.danger : AppColors.black,
          duration: Duration(seconds: error ? 5 : 3),
          content: Row(
            children: [
              Icon(
                error ? Icons.error_outline : Icons.check_circle_outline,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTheme.font(
                      size: 15, weight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
