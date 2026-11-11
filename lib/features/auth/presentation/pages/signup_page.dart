import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../core/errors/error_text.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final companyController = TextEditingController();
  final cityController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscurePassword = true;
  String? validationError;

  @override
  void dispose() {
    companyController.dispose();
    cityController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }


  void _submit(AppLocalizations l10n) {
    FocusScope.of(context).unfocus();

    if (companyController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      return;
    }

    if (passwordController.text.length < 8) {
      setState(() => validationError = l10n.passwordTooShort);
      return;
    }

    if (passwordController.text != confirmController.text) {
      setState(() => validationError = l10n.passwordsDoNotMatch);
      return;
    }

    setState(() => validationError = null);

    ref.read(authNotifierProvider.notifier).register(
      companyName: companyController.text.trim(),
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      phone: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
      city: cityController.text.trim().isEmpty
          ? null
          : cityController.text.trim(),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Text(text,
              style: AppTheme.font(size: 14, weight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.user != null) {
        AppSnack.success(context, l10n.accountCreated);
        // The router guard redirects to the new user's home screen.
      }
      if (next.error != null) {
        AppSnack.error(context, errorText(next.error!, l10n));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l10n.back,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.go('/login'),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.signUp,
                              style: AppTheme.font(size: 22, weight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(l10n.signUpSubtitle,
                              style: AppTheme.font(size: 13, color: Colors.white.withValues(alpha: 0.85))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
                    children: [
                      _sectionTitle(l10n.companyInfo, Icons.business),
                      AppLabeledField(label: l10n.companyName, child: TextField(
                        controller: companyController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.storefront_outlined),
                        ),
                      )),
                      const SizedBox(height: 12),
                      AppLabeledField(label: '${l10n.city} (${l10n.optional})', child: TextField(
                        controller: cityController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.place_outlined),
                        ),
                      )),

                      const SizedBox(height: 26),
                      _sectionTitle(l10n.yourAccount, Icons.person_outline),
                      AppLabeledField(label: l10n.yourName, child: TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                      )),
                      const SizedBox(height: 12),
                      AppLabeledField(label: l10n.email, child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.mail_outline),
                        ),
                      )),
                      const SizedBox(height: 12),
                      AppLabeledField(label: '${l10n.phone} (${l10n.optional})', child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                      )),
                      const SizedBox(height: 12),
                      AppLabeledField(label: l10n.password, child: TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: obscurePassword ? l10n.showPassword : l10n.hidePassword,
                            icon: Icon(obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword),
                          ),
                        ),
                      )),
                      const SizedBox(height: 12),
                      AppLabeledField(label: l10n.confirmPassword, child: TextField(
                        controller: confirmController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.check),
                          errorText: validationError,
                        ),
                      )),

                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 16, color: AppColors.info),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(l10n.signUpDisclaimer,
                                  style: AppTheme.font(size: 12, color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: authState.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : AppBlockButton(height: 52, child: FilledButton(
                          onPressed: () => _submit(l10n),
                          child: Text(l10n.createMyAccount,
                              style: AppTheme.font(size: 15, weight: FontWeight.w700)),
                        )),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.alreadyHaveAccount,
                              style: AppTheme.font(size: 13, color: AppColors.textSecondary)),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(l10n.backToLogin,
                                style: AppTheme.font(size: 13, weight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}