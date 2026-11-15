import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_detail_body.dart';

/// One customer on its own page (phones, deep links). The content is the
/// same [CustomerDetailBody] the wide list shows in its side panel.
class CustomerDetailPage extends ConsumerWidget {
  final String customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = ref.watch(customerDetailProvider).customer;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: l10n.customerDetails,
        subtitle: c?.id == customerId ? c?.name : null,
        icon: Icons.person_outline,
        color: AppColors.finance,
        showMenuButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(customerDetailProvider.notifier).load(customerId),
        child: AppContentFrame(
          maxWidth: 760,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: CustomerDetailBody(customerId: customerId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
