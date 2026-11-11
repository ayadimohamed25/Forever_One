import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../core/errors/error_text.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
      // After a successful sign-in the router guard redirects (to where the
      // user was headed, or their home screen).
      if (next.error != null) {
        AppSnack.error(context, errorText(next.error, l10n));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // EN / FR switch
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.fieldBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _langChip('en', 'EN', locale.languageCode),
                      Container(width: 1, height: 36, color: AppColors.fieldBorder),
                      _langChip('fr', 'FR', locale.languageCode),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                            ),
                            child: const Icon(Icons.all_inclusive,
                                size: 26, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(l10n.appTitle,
                            style: AppTheme.font(
                                size: 13,
                                weight: FontWeight.w600,
                                color: AppColors.primary)),
                        const SizedBox(height: 6),
                        Text(l10n.login,
                            style: AppTheme.font(
                                size: 24,
                                weight: FontWeight.w600,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 6),
                        Text(l10n.loginSubtitle,
                            style: AppTheme.font(
                                size: 14, color: AppColors.textSecondary),
                            maxLines: 2),

                        if (authState.restoreFailedOffline) ...[
                          const SizedBox(height: 20),
                          _OfflineBanner(
                            message: l10n.serverUnreachable,
                            retryLabel: l10n.retry,
                            onRetry: () =>
                                ref.read(authNotifierProvider.notifier).restore(),
                          ),
                        ],

                        const SizedBox(height: 28),
                        AppLabeledField(
                          label: l10n.email,
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              // Example placeholder: shown while empty, gone as soon as you type.
                              hintText: 'name@company.com',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppLabeledField(
                          label: l10n.password,
                          child: TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                tooltip: obscurePassword
                                    ? l10n.showPassword
                                    : l10n.hidePassword,
                                icon: Icon(obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: authState.isLoading
                              ? const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  ),
                                )
                              : FilledButton(
                                  onPressed: _submit,
                                  child: Text(l10n.signIn),
                                ),
                        ),

                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(l10n.noAccountYet,
                                style: AppTheme.font(
                                    size: 14, color: AppColors.textSecondary)),
                            TextButton(
                              onPressed: () => context.push('/signup'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: Text(l10n.signUp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                l10n.copyright,
                style: AppTheme.font(size: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Language switch segment: selected on a light grey fill.
  Widget _langChip(String code, String label, String current) {
    final selected = current == code;
    return AppPressable(
      onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(code)),
      selected: selected,
      borderRadius: BorderRadius.zero,
      semanticLabel: label,
      child: Container(
        width: 48,
        height: 36,
        color: selected ? AppColors.fill : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.font(
            size: 13,
            weight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Shown when the saved session couldn't be checked because the server was
/// unreachable. The session is kept; Retry checks again.
class _OfflineBanner extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _OfflineBanner({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 20, color: AppColors.warningText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: AppTheme.font(size: 13, color: AppColors.textPrimary)),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: AppColors.accentText),
            child: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}
