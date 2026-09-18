import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/user_provider.dart';
import '../widgets/user_form_dialog.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).load());
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  String _translateError(String code, AppLocalizations l10n) {
    switch (code) {
      case 'EMAIL_TAKEN':
        return l10n.emailTaken;
      case 'WRONG_PASSWORD':
        return l10n.wrongPassword;
      case 'PASSWORD_TOO_SHORT':
        return l10n.passwordTooShort;
      default:
        return code;
    }
  }

  Future<void> _editProfile(AppLocalizations l10n) async {
    final user = ref.read(profileProvider).user;
    if (user == null) return;

    final emailController = TextEditingController(text: user.email);
    final nameController = TextEditingController(text: user.fullName ?? '');
    final phoneController = TextEditingController(text: user.phone ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.myProfile),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (emailController.text.trim().isEmpty) return;
              Navigator.of(context).pop(true);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final error = await ref.read(profileProvider.notifier).updateProfile(
      email: emailController.text.trim(),
      fullName: nameController.text.trim().isEmpty
          ? null
          : nameController.text.trim(),
      phone: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
    );

    if (!mounted) return;
    if (error == null) {
      _showSnack(l10n.userUpdated);
    } else {
      _showSnack(_translateError(error, l10n), isError: true);
    }
  }

  Future<void> _changePassword(AppLocalizations l10n) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? localError;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.changePassword),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  obscureText: true,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.currentPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    prefixIcon: const Icon(Icons.lock_reset),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    prefixIcon: const Icon(Icons.check),
                    errorText: localError,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (newController.text.length < 8) {
                  setState(() => localError = l10n.passwordTooShort);
                  return;
                }
                if (newController.text != confirmController.text) {
                  setState(() => localError = l10n.passwordsDoNotMatch);
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;

    final error = await ref
        .read(profileProvider.notifier)
        .changePassword(currentController.text, newController.text);

    if (!mounted) return;
    if (error == null) {
      _showSnack(l10n.passwordChanged);
    } else {
      _showSnack(_translateError(error, l10n), isError: true);
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context)!;
    final user = state.user;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.myProfile),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.edit,
              onPressed: () => _editProfile(l10n),
            ),
        ],
      ),
      body: state.isLoading || user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => ref.read(profileProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.softShadow(AppColors.primary),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Text(user.initials,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ),
                  const SizedBox(height: 14),
                  Text(user.displayName,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(user.email,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(roleIcon(user.role),
                            size: 13, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(roleLabel(user.role, l10n),
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _infoRow(Icons.mail_outline, l10n.email, user.email),
                  if (user.phone != null)
                    _infoRow(
                        Icons.phone_outlined, l10n.phone, user.phone!),
                  _infoRow(Icons.business, l10n.company,
                      user.companyName.isEmpty ? '—' : user.companyName),
                  _infoRow(
                      Icons.verified_user_outlined,
                      l10n.accessRights,
                      l10n.permissionsCount(user.permissions.length)),
                  const SizedBox(height: 6),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Text(l10n.accountSecurity,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),

            AppCard(
              onTap: () => _changePassword(l10n),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AppIconBadge(
                      icon: Icons.key_outlined,
                      color: AppColors.warning,
                      size: 42),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(l10n.changePassword,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}