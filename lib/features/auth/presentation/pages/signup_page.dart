import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

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

  String _translateError(String code, AppLocalizations l10n) {
    switch (code) {
      case 'EMAIL_TAKEN':
        return l10n.emailTaken;
      case 'INVALID_EMAIL':
        return l10n.invalidEmail;
      case 'PASSWORD_TOO_SHORT':
        return l10n.passwordTooShort;
      case 'REGISTRATION_FAILED':
        return l10n.registrationFailed;
      default:
        return code;
    }
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
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountCreated),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/dashboard');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_translateError(next.error!, l10n)),
            backgroundColor: AppColors.danger,
          ),
        );
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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.go('/login'),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.signUp,
                              style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(l10n.signUpSubtitle,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color:
                                  Colors.white.withValues(alpha: 0.85))),
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
                      TextField(
                        controller: companyController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n.companyName,
                          prefixIcon: const Icon(Icons.storefront_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: cityController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: '${l10n.city} (${l10n.optional})',
                          prefixIcon: const Icon(Icons.place_outlined),
                        ),
                      ),

                      const SizedBox(height: 26),
                      _sectionTitle(l10n.yourAccount, Icons.person_outline),
                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n.yourName,
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
                          labelText: '${l10n.phone} (${l10n.optional})',
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: l10n.confirmPassword,
                          prefixIcon: const Icon(Icons.check),
                          errorText: validationError,
                        ),
                      ),

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
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: authState.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : FilledButton(
                          onPressed: () => _submit(l10n),
                          child: Text(l10n.createMyAccount,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.alreadyHaveAccount,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(l10n.backToLogin,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
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