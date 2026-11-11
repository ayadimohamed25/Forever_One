import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Shown for the moment it takes to restore a saved session at launch, so a
/// signed-in user never sees the login screen flash before their dashboard.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: Semantics(
          label: l10n.loading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: const Icon(Icons.all_inclusive,
                    size: 30, color: AppColors.accent),
              ),
              const SizedBox(height: 20),
              Text('Forever One',
                  style: AppTheme.font(
                      size: 20, weight: FontWeight.w600, letterSpacing: -0.4)),
              const SizedBox(height: 24),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
