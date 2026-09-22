import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../widgets/user_roles.dart';

/// Full-page user form. Pops with a [UserInput] on save, or null when the
/// user backs out. The password field only appears when creating a user —
/// existing users get a password reset from the Users list instead.
class UserFormPage extends StatefulWidget {
  final UserEntity? existing;

  const UserFormPage({super.key, this.existing});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController passwordController;
  late String role;
  late bool isActive;
  bool obscurePassword = true;

  bool get isEdit => widget.existing != null;

  bool get canSave =>
      emailController.text.trim().isNotEmpty &&
          (isEdit || passwordController.text.length >= 8);

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    nameController = TextEditingController(text: e?.fullName ?? '');
    emailController = TextEditingController(text: e?.email ?? '')
      ..addListener(() => setState(() {}));
    phoneController = TextEditingController(text: e?.phone ?? '');
    passwordController = TextEditingController()
      ..addListener(() => setState(() {}));
    role = e?.role ?? 'employee';
    isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _orNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  void _save() {
    if (!canSave) return;
    Navigator.of(context).pop(UserInput(
      email: emailController.text.trim(),
      fullName: _orNull(nameController),
      phone: _orNull(phoneController),
      role: role,
      isActive: isActive,
      password: isEdit ? null : passwordController.text,
    ));
  }

  /// Selected role: accentSoft background, terracotta border, icon and text.
  Widget _roleOption(String r, AppLocalizations l10n) {
    final selected = role == r;

    return Material(
      color: selected ? AppColors.accentSoft : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.accent : AppColors.track,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => role = r),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(
                roleIcon(r),
                size: 20,
                color: selected ? AppColors.accent : AppColors.iconMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  roleLabel(r, l10n),
                  style: AppTheme.font(
                    size: 14,
                    weight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppColors.accent : AppColors.textPrimary,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle,
                    size: 18, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final password = passwordController.text;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: isEdit ? l10n.editUser : l10n.newUser,
        subtitle: isEdit ? widget.existing!.email : null,
        icon: Icons.group_outlined,
        color: AppColors.primary,
        showMenuButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          AppFormSection(
            title: l10n.generalInfo,
            children: [
              AppTextField(
                controller: nameController,
                label: l10n.fullName,
                icon: Icons.badge_outlined,
                autofocus: !isEdit,
              ),
              AppTextField(
                controller: emailController,
                label: l10n.email,
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              AppTextField(
                controller: phoneController,
                label: l10n.phone,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),

          if (!isEdit) ...[
            const SizedBox(height: 24),
            AppFormSection(
              title: l10n.password,
              children: [
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: AppTheme.font(size: 15),
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    // Explains the rule as soon as it's broken, not on save.
                    errorText: password.isNotEmpty && password.length < 8
                        ? l10n.passwordTooShort
                        : null,
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),
          AppFormSection(
            title: l10n.role,
            spacing: 8,
            children: [for (final r in roleKeys) _roleOption(r, l10n)],
          ),

          const SizedBox(height: 24),
          AppFormSection(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: isActive,
                title: Text(l10n.userActive, style: AppTheme.font(size: 15)),
                onChanged: (v) => setState(() => isActive = v),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: AppBottomActionBar(
        child: FilledButton(
          onPressed: canSave ? _save : null,
          child: Text(l10n.save),
        ),
      ),
    );
  }
}