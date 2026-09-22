import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/audit_log_entity.dart';
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

  /// Filters match on part of the action name, so "sale" catches
  /// create_sale, update_sale and delete_sale together.
  List<({String key, String label})> _filters(AppLocalizations l10n) => [
    (key: 'sale', label: l10n.sales),
    (key: 'purchase', label: l10n.purchases),
    (key: 'payment', label: l10n.payments),
    (key: 'product', label: l10n.products),
    (key: 'stock', label: l10n.stock),
    (key: 'customer', label: l10n.customers),
    (key: 'supplier', label: l10n.suppliers),
    (key: 'user', label: l10n.users),
    (key: 'ai_', label: l10n.ai),
    (key: 'document', label: l10n.documents),
    (key: 'login', label: l10n.logins),
    (key: 'report', label: l10n.reports),
  ];

  String? _entityLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'product':
        return l10n.product;
      case 'category':
        return l10n.category;
      case 'customer':
        return l10n.customer;
      case 'supplier':
        return l10n.supplier;
      case 'warehouse':
        return l10n.warehouse;
      case 'user':
        return l10n.user;
      case 'sale':
        return l10n.sale;
      case 'purchase':
        return l10n.purchase;
      case 'profile':
        return l10n.myProfile;
      default:
        return null;
    }
  }

  /// Every action label comes from the ARB files.
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
      case 'receive_purchase':
        return l10n.purchaseReceived;
      case 'reset_password':
        return l10n.passwordReset;
      case 'change_password':
        return l10n.passwordChanged;
      case 'register_company':
        return l10n.auditCreated(l10n.company);
    }

    final sep = action.indexOf('_');
    if (sep > 0) {
      final entity = _entityLabel(action.substring(sep + 1), l10n);
      if (entity != null) {
        switch (action.substring(0, sep)) {
          case 'create':
            return l10n.auditCreated(entity);
          case 'update':
            return l10n.auditUpdated(entity);
          case 'delete':
            return l10n.auditDeleted(entity);
        }
      }
    }
    return action.replaceAll('_', ' ');
  }

  /// Colour carries meaning: created → success, changed → warning,
  /// deleted → danger, AI → accent, everything else neutral.
  BadgeTone _tone(String action) {
    if (action.startsWith('delete')) return BadgeTone.danger;
    if (action.startsWith('update') ||
        action == 'reset_password' ||
        action == 'change_password') {
      return BadgeTone.warning;
    }
    if (action.startsWith('create') ||
        action == 'record_payment' ||
        action == 'receive_purchase' ||
        action == 'confirm_document' ||
        action == 'register_company') {
      return BadgeTone.success;
    }
    if (action == 'ai_query') return BadgeTone.accent;
    return BadgeTone.neutral;
  }

  IconData _icon(String action) {
    if (action.contains('sale')) return Icons.point_of_sale_outlined;
    if (action.contains('purchase')) return Icons.shopping_cart_outlined;
    if (action.contains('payment')) return Icons.payments_outlined;
    if (action.contains('product')) return Icons.inventory_2_outlined;
    if (action.contains('category')) return Icons.label_outline;
    if (action.contains('customer')) return Icons.person_outline;
    if (action.contains('supplier')) return Icons.local_shipping_outlined;
    if (action.contains('warehouse')) return Icons.warehouse_outlined;
    if (action.contains('stock')) return Icons.swap_vert_outlined;
    if (action.contains('document')) return Icons.document_scanner_outlined;
    if (action.contains('ai')) return Icons.auto_awesome_outlined;
    if (action.contains('report')) return Icons.picture_as_pdf_outlined;
    if (action.contains('password')) return Icons.key_outlined;
    if (action.contains('user') || action.contains('profile')) {
      return Icons.group_outlined;
    }
    if (action == 'login') return Icons.login;
    return Icons.history;
  }

  /// Turns the JSON details into "key: value" pills, e.g. "type: director".
  List<String> _detailPills(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.entries
            .map((e) => '${e.key}: ${_detailValue('${e.key}', e.value)}')
            .toList();
      }
    } catch (_) {
      // Not JSON — show it as a single pill below.
    }
    return [raw];
  }

  String _detailValue(String key, dynamic value) {
    final amount = double.tryParse('$value');
    if (amount != null && (key == 'total' || key == 'amount')) {
      return formatDT(amount);
    }
    return '$value';
  }

  /// Neutral pill that can wrap onto several lines for long values
  /// (an AI question, for instance).
  Widget _detailPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTheme.font(
            size: 12, weight: FontWeight.w500, color: AppColors.black),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? AppColors.black : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
            color: selected ? AppColors.black : AppColors.track,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            widthFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                label,
                style: AppTheme.font(
                  size: 13,
                  weight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _entry(AuditLogEntity log, bool isLast, AppLocalizations l10n) {
    final date = DateTime.tryParse(log.createdAt);
    final pills = _detailPills(log.details);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          Column(
            children: [
              AppLeadingTile.icon(_icon(log.action), tone: _tone(log.action)),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: AppColors.track,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _actionLabel(log.action, l10n),
                      style: AppTheme.rowTitle,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.userEmail ?? l10n.system,
                      style: AppTheme.label,
                      maxLines: 2,
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 2),
                      // Always a single line under the email.
                      Text(
                        formatDateTime(date),
                        maxLines: 1,
                        softWrap: false,
                        style: AppTheme.font(
                          size: 12,
                          color: AppColors.textMuted,
                          tabularFigures: true,
                        ),
                      ),
                    ],
                    if (pills.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [for (final p in pills) _detailPill(p)],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditProvider);
    final l10n = AppLocalizations.of(context)!;
    final filters = _filters(l10n);

    final logs = selectedFilter == null
        ? state.logs
        : state.logs.where((l) => l.action.contains(selectedFilter!)).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      drawer: const AppDrawer(currentRoute: '/audit'),
      appBar: AppPageHeader(
        title: l10n.auditLog,
        subtitle: state.logs.isEmpty ? null : '${logs.length} / ${state.logs.length}',
        icon: Icons.history,
        color: AppColors.info,
        actions: [
          AppHeaderAction(
            icon: Icons.refresh,
            tooltip: l10n.refresh,
            onTap: () => ref.read(auditProvider.notifier).load(),
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
      )
          : state.logs.isEmpty
          ? AppEmptyState(
        icon: Icons.history,
        title: l10n.noActionsRecorded,
        subtitle: '',
      )
          : Column(
        children: [
          SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              children: [
                _filterChip(
                  label: l10n.all,
                  selected: selectedFilter == null,
                  onTap: () =>
                      setState(() => selectedFilter = null),
                ),
                for (final f in filters)
                  _filterChip(
                    label: f.label,
                    selected: selectedFilter == f.key,
                    onTap: () => setState(() => selectedFilter =
                    selectedFilter == f.key ? null : f.key),
                  ),
              ],
            ),
          ),
          Expanded(
            child: logs.isEmpty
                ? AppEmptyState(
              icon: Icons.filter_alt_off_outlined,
              title: l10n.noActionsOfThisType,
              subtitle: '',
            )
                : RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () =>
                  ref.read(auditProvider.notifier).load(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    20, 4, 20, 28),
                itemCount: logs.length,
                itemBuilder: (context, index) => _entry(
                  logs[index],
                  index == logs.length - 1,
                  l10n,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}