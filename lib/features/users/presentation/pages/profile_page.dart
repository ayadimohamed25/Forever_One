import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/user_provider.dart';
import '../widgets/user_roles.dart';
import 'profile_edit_page.dart';

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
      case 'WRONG_PASSWORD':
        return l10n.wrongPassword;
      case 'PASSWORD_TOO_SHORT':
        return l10n.passwordTooShort;
      case 'EMAIL_TAKEN':
        return l10n.emailTaken;
      default:
        return code;
    }
  }

  Future<void> _edit(UserEntity user, AppLocalizations l10n) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProfileEditPage(user: user)),
    );
    if (changed == true && mounted) _showSnack(l10n.userUpdated);
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
                  style: AppTheme.font(size: 15),
                  decoration: InputDecoration(
                    labelText: l10n.currentPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  style: AppTheme.font(size: 15),
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    prefixIcon: const Icon(Icons.lock_reset),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  style: AppTheme.font(size: 15),
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
            TextButton(
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
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context)!;
    final user = state.user;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: l10n.myProfile,
        subtitle: user?.email,
        icon: Icons.person_outline,
        color: AppColors.primary,
        showMenuButton: false,
        actions: [
          if (user != null)
            AppHeaderAction(
              icon: Icons.edit_outlined,
              tooltip: l10n.edit,
              onTap: () => _edit(user, l10n),
            ),
        ],
      ),
      body: state.isLoading || user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => ref.read(profileProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ── Identity ──
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLeadingTile.initials(user.displayName, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          maxLines: 2,
                          style: AppTheme.font(
                              size: 18, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(user.email,
                            style: AppTheme.label, maxLines: 2),
                        const SizedBox(height: 10),
                        AppBadge(
                          label: roleLabel(user.role, l10n),
                          tone: roleTone(user.role),
                          icon: roleIcon(user.role),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Details ──
            AppFormSection(
              title: l10n.generalInfo,
              spacing: 0,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                AppInfoRow(
                  icon: Icons.mail_outline,
                  label: l10n.email,
                  value: user.email,
                ),
                if (user.phone != null && user.phone!.trim().isNotEmpty)
                  AppInfoRow(
                    icon: Icons.phone_outlined,
                    label: l10n.phone,
                    value: user.phone!,
                  ),
                AppInfoRow(
                  icon: Icons.business_outlined,
                  label: l10n.company,
                  value: user.companyName.isEmpty ? '—' : user.companyName,
                ),
                AppInfoRow(
                  icon: Icons.verified_user_outlined,
                  label: l10n.accessRights,
                  value: l10n.permissionsCount(user.permissions.length),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Security ──
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                l10n.accountSecurity,
                style: AppTheme.font(size: 16, weight: FontWeight.w600),
              ),
            ),
            AppCard(
              onTap: () => _changePassword(l10n),
              child: Row(
                children: [
                  const AppLeadingTile.icon(Icons.key_outlined),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(l10n.changePassword,
                        style: AppTheme.rowTitle),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 22, color: AppColors.textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}