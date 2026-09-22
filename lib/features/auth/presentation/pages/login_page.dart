import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController(text: 'admin@demo.com');
  final passwordController = TextEditingController(text: 'test1234');
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    ref.read(authNotifierProvider.notifier).login(
      emailController.text.trim(),
      passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.user != null) context.go('/dashboard');
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // EN / FR switch
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _langChip('en', 'EN', locale.languageCode),
                      _langChip('fr', 'FR', locale.languageCode),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  const SizedBox(height: 36),

                  // Logo: 64×64, accentSoft, terracotta icon
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.all_inclusive,
                          size: 30, color: AppColors.accent),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    l10n.appTitle,
                    style: AppTheme.greeting,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appTagline,
                    style: AppTheme.body
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 36),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.login, style: AppTheme.sectionTitle),
                        const SizedBox(height: 4),
                        Text(l10n.loginSubtitle,
                            style: AppTheme.label, maxLines: 2),

                        const SizedBox(height: 24),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.email,
                            prefixIcon: const Icon(Icons.mail_outline),
                          ),
                        ),

                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
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

                        const SizedBox(height: 24),
                        authState.isLoading
                            ? const SizedBox(
                          height: 56,
                          child:
                          Center(child: CircularProgressIndicator()),
                        )
                            : FilledButton(
                          onPressed: _submit,
                          child: Text(l10n.signIn),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.noAccountYet, style: AppTheme.label),
                      TextButton(
                        onPressed: () => context.push('/signup'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          l10n.signUp,
                          style: AppTheme.font(
                            size: 14,
                            weight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l10n.copyright,
                      style: AppTheme.font(
                          size: 13, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Selected language: accentSoft background, terracotta text.
  Widget _langChip(String code, String label, String current) {
    final selected = current == code;
    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(code)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTheme.font(
            size: 13,
            weight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}