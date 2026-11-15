import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../providers/supplier_provider.dart';
import '../widgets/supplier_detail_body.dart';

/// One supplier on its own page (phones, deep links). The content is the
/// same [SupplierDetailBody] the wide list shows in its side panel.
class SupplierDetailPage extends ConsumerWidget {
  final String supplierId;

  const SupplierDetailPage({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final s = ref.watch(supplierDetailProvider).supplier;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: l10n.supplierDetails,
        subtitle: s?.id == supplierId ? s?.name : null,
        icon: Icons.local_shipping_outlined,
        color: AppColors.purchases,
        showMenuButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(supplierDetailProvider.notifier).load(supplierId),
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
                child: SupplierDetailBody(supplierId: supplierId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
