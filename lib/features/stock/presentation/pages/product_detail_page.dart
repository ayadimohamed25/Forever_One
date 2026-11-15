import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../providers/product_provider.dart';
import '../widgets/product_detail_body.dart';

/// One product on its own page (phones, deep links). The content is the
/// same [ProductDetailBody] the wide list shows in its side panel.
class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final p = ref.watch(productDetailProvider).product;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppPageHeader(
        title: l10n.productDetails,
        subtitle: p?.id == productId ? p?.name : null,
        icon: Icons.inventory_2_outlined,
        color: AppColors.stock,
        showMenuButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(productDetailProvider.notifier).load(productId),
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
                child: ProductDetailBody(productId: productId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
