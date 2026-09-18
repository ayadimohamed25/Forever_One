import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

const roleKeys = ['admin', 'finance', 'stock', 'commercial', 'employee', 'auditor'];

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

Color roleColor(String role) {
  switch (role) {
    case 'admin':
      return AppColors.primary;
    case 'finance':
      return AppColors.finance;
    case 'stock':
      return AppColors.stock;
    case 'commercial':
      return AppColors.sales;
    case 'auditor':
      return AppColors.info;
    default:
      return AppColors.textSecondary;
  }
}

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

Future<UserInput?> showUserFormDialog(
    BuildContext context, {
      UserEntity? existing,
    }) {
  final l10n = AppLocalizations.of(context)!;
  final isEdit = existing != null;

  final emailController = TextEditingController(text: existing?.email ?? '');
  final nameController = TextEditingController(text: existing?.fullName ?? '');
  final phoneController = TextEditingController(text: existing?.phone ?? '');
  final passwordController = TextEditingController();

  var role = existing?.role ?? 'employee';
  var isActive = existing?.isActive ?? true;
  var obscure = true;

  return showDialog<UserInput>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(isEdit ? l10n.editUser : l10n.newUser),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: !isEdit,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Text(l10n.role,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                ...roleKeys.map((r) {
                  final selected = role == r;
                  final color = roleColor(r);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: InkWell(
                      onTap: () => setState(() => role = r),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(alpha: 0.09)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? color : AppColors.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(roleIcon(r),
                                size: 18,
                                color: selected
                                    ? color
                                    : AppColors.textSecondary),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(roleLabel(r, l10n),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                    color: selected
                                        ? color
                                        : AppColors.textPrimary,
                                  )),
                            ),
                            if (selected)
                              Icon(Icons.check_circle, size: 17, color: color),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isActive,
                  title: Text(l10n.userActive,
                      style: const TextStyle(fontSize: 13.5)),
                  onChanged: (v) => setState(() => isActive = v),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (emailController.text.trim().isEmpty) return;
              if (!isEdit && passwordController.text.length < 8) return;

              String? orNull(TextEditingController c) =>
                  c.text.trim().isEmpty ? null : c.text.trim();

              Navigator.of(context).pop(UserInput(
                email: emailController.text.trim(),
                fullName: orNull(nameController),
                phone: orNull(phoneController),
                role: role,
                isActive: isActive,
                password: isEdit ? null : passwordController.text,
              ));
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    ),
  );
}