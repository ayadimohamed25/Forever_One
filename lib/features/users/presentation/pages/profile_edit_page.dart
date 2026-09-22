import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/user_provider.dart';

/// Full-page form for the signed-in user's own details. Saves directly and
/// pops with `true` on success, so the profile page can confirm it.
class ProfileEditPage extends ConsumerStatefulWidget {
  final UserEntity user;

  const ProfileEditPage({super.key, required this.user});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  bool isSaving = false;

  bool get canSave => emailController.text.trim().isNotEmpty && !isSaving;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.fullName ?? '');
    emailController = TextEditingController(text: widget.user.email)
      ..addListener(() => setState(() {}));
    phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String? _orNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  String _translateError(String code, AppLocalizations l10n) {
    switch (code) {
      case 'EMAIL_TAKEN':
        return l10n.emailTaken;
      case 'INVALID_EMAIL':
        return l10n.invalidEmail;
      default:
        return code;
    }
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!canSave) return;
    setState(() => isSaving = true);

    final error = await ref.read(profileProvider.notifier).updateProfile(
      email: emailController.text.trim(),
      fullName: _orNull(nameController),
      phone: _orNull(phoneController),
    );

    if (!mounted) return;
    setState(() => isSaving = false);

    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translateError(error, l10n)),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: l10n.myProfile,
        subtitle: widget.user.email,
        icon: Icons.person_outline,
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
        ],
      ),
      bottomNavigationBar: AppBottomActionBar(
        child: isSaving
            ? const SizedBox(
          height: 56,
          child: Center(child: CircularProgressIndicator()),
        )
            : FilledButton(
          onPressed: canSave ? () => _save(l10n) : null,
          child: Text(l10n.save),
        ),
      ),
    );
  }
}