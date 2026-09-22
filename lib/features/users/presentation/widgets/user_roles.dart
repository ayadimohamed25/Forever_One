import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_widgets.dart';

/// The roles the backend's permission matrix knows about.
const roleKeys = [
  'admin',
  'finance',
  'stock',
  'commercial',
  'employee',
  'auditor',
];

String roleLabel(String role, AppLocalizations l10n) {
  switch (role) {
    case 'admin':
      return l10n.roleAdmin;
    case 'finance':
      return l10n.roleFinance;
    case 'stock':
      return l10n.roleStock;
    case 'commercial':
      return l10n.roleCommercial;
    case 'employee':
      return l10n.roleEmployee;
    case 'auditor':
      return l10n.roleAuditor;
    default:
      return role;
  }
}

/// Admin is highlighted in the accent; the other roles are neutral
/// information, not a status.
BadgeTone roleTone(String role) =>
    role == 'admin' ? BadgeTone.accent : BadgeTone.neutral;

/// Kept for screens that still take a colour.
Color roleColor(String role) =>
    role == 'admin' ? AppColors.accent : AppColors.textSecondary;

IconData roleIcon(String role) {
  switch (role) {
    case 'admin':
      return Icons.admin_panel_settings_outlined;
    case 'finance':
      return Icons.account_balance_wallet_outlined;
    case 'stock':
      return Icons.inventory_2_outlined;
    case 'commercial':
      return Icons.handshake_outlined;
    case 'auditor':
      return Icons.fact_check_outlined;
    default:
      return Icons.person_outline;
  }
}