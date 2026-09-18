import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/audit_provider.dart';

class AuditPage extends ConsumerStatefulWidget {
  const AuditPage({super.key});

  @override
  ConsumerState<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends ConsumerState<AuditPage> {
  String? selectedFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(auditProvider.notifier).load());
  }

  Map<String, String> _filterOptions(AppLocalizations l10n) {
    return {
      'create_sale': l10n.sales,
      'create_purchase': l10n.purchases,
      'record_payment': l10n.payments,
      'stock_movement': l10n.stock,
      'ai_query': l10n.ai,
      'confirm_document': l10n.documents,
      'login': l10n.logins,
      'generate_report': l10n.reports,
    };
  }

  IconData _actionIcon(String action) {
    if (action.contains('sale')) return Icons.point_of_sale;
    if (action.contains('purchase')) return Icons.shopping_cart;
    if (action.contains('payment')) return Icons.payments;
    if (action.contains('product')) return Icons.inventory_2;
    if (action.contains('customer')) return Icons.person;
    if (action.contains('supplier')) return Icons.local_shipping;
    if (action.contains('warehouse')) return Icons.warehouse;
    if (action.contains('category')) return Icons.label;
    if (action.contains('stock')) return Icons.inventory;
    if (action.contains('document')) return Icons.document_scanner;
    if (action.contains('ai')) return Icons.smart_toy;
    if (action.contains('report')) return Icons.picture_as_pdf;
    if (action == 'login') return Icons.login;
    return Icons.history;
  }

  Color _actionColor(String action) {
    if (action.startsWith('delete')) return AppColors.danger;
    if (action.startsWith('update')) return AppColors.warning;
    if (action.contains('sale')) return AppColors.sales;
    if (action.contains('purchase')) return AppColors.purchases;
    if (action.contains('payment')) return AppColors.finance;
    if (action.contains('stock') || action.contains('product')) {
      return AppColors.stock;
    }
    if (action.contains('ai')) return AppColors.primary;
    if (action == 'login') return AppColors.textSecondary;
    return AppColors.info;
  }

  String _actionLabel(String action, AppLocalizations l10n) {
    switch (action) {
      case 'login':
        return l10n.connection;
      case 'create_sale':
        return l10n.saleCreatedAction;
      case 'create_purchase':
        return l10n.purchaseRecordedAction;
      case 'record_payment':
        return l10n.paymentRecordedAction;
      case 'stock_movement':
        return l10n.stockMovementAction;
      case 'confirm_document':
        return l10n.documentValidatedAction;
      case 'ai_query':
        return l10n.aiQueryAction;
      case 'generate_report':
        return l10n.reportGeneratedAction;
      default:
      // Newer actions (create_product, delete_customer…) are shown
      // readably without needing a translation for every one.
        return action.replaceAll('_', ' ');
    }
  }

  String _formatDetails(String? details) {
    if (details == null || details.isEmpty) return '';
    return details
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('"', '')
        .replaceAll(':', ' : ')
        .replaceAll(',', ' · ');
  }

  Widget _timeline(List<dynamic> logs, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final color = _actionColor(log.action);
        final isLast = index == logs.length - 1;
        final details = _formatDetails(log.details);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: AppColors.tintGradient(color),
                      shape: BoxShape.circle,
                      border:
                      Border.all(color: color.withValues(alpha: 0.25)),
                    ),
                    child: Icon(_actionIcon(log.action), size: 17, color: color),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: AppColors.border),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        _actionLabel(log.action, l10n),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      AppMetaRow(items: [
                        (
                        icon: Icons.person_outline,
                        text: log.userEmail ?? l10n.system
                        ),
                        (icon: Icons.schedule, text: log.createdAt),
                      ]),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            details,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditProvider);
    final l10n = AppLocalizations.of(context)!;
    final filterOptions = _filterOptions(l10n);

    final filteredLogs = selectedFilter == null
        ? state.logs
        : state.logs.where((l) => l.action.contains(selectedFilter!)).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/audit'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.auditLog),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(auditProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? AppEmptyState(
        icon: Icons.lock_outline,
        title: l10n.restrictedAccess,
        subtitle: state.error!,
        color: AppColors.danger,
      )
          : state.logs.isEmpty
          ? AppEmptyState(
        icon: Icons.history,
        title: l10n.noActionsRecorded,
        subtitle: '',
        color: AppColors.info,
      )
          : Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 7),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(l10n.all,
                        style: const TextStyle(fontSize: 12)),
                    selected: selectedFilter == null,
                    onSelected: (_) =>
                        setState(() => selectedFilter = null),
                  ),
                ),
                ...filterOptions.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(e.value,
                        style: const TextStyle(fontSize: 12)),
                    selected: selectedFilter == e.key,
                    onSelected: (_) => setState(() =>
                    selectedFilter =
                    selectedFilter == e.key
                        ? null
                        : e.key),
                  ),
                )),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredLogs.isEmpty
                ? AppEmptyState(
              icon: Icons.filter_alt_off_outlined,
              title: l10n.noActionsOfThisType,
              subtitle: '',
              color: AppColors.textSecondary,
            )
                : RefreshIndicator(
              onRefresh: () =>
                  ref.read(auditProvider.notifier).load(),
              child: _timeline(filteredLogs, l10n),
            ),
          ),
        ],
      ),
    );
  }
}