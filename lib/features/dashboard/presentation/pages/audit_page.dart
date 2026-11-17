import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../users/presentation/widgets/user_roles.dart';
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
        return l10n.auditSignedIn;
      case 'update_profile':
        return l10n.auditProfileUpdated;
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
            .where((e) => '${e.value}'.trim().isNotEmpty)
            .map((e) => _detailValue('${e.key}', e.value))
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
    if (key == 'quantity') return '× $value';
    if (key == 'role') {
      return roleLabel('$value', AppLocalizations.of(context)!);
    }
    if (key == 'type') {
      final l10n = AppLocalizations.of(context)!;
      switch ('$value') {
        case 'in':
          return l10n.stockIn;
        case 'out':
          return l10n.stockOut;
        // Report types: words, not internal codes.
        case 'director':
          return l10n.reportTypeDirector;
      }
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
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        text,
        style: AppTheme.font(
          size: 12,
          weight: FontWeight.w500,
          color: AppColors.textLabel,
        ),
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
        color: selected ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.fieldBorder,
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
                  color: selected ? AppColors.primary : AppColors.textLabel,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// One compact row per entry, all rows in one bordered list:
  ///   wide:  [icon] Title · user · date time ............ [chips]
  ///   phone: [icon] Title ........................ [chip]
  ///                 user · date time
  Widget _entry(
    AuditLogEntity log,
    bool isFirst,
    bool isLast,
    AppLocalizations l10n,
  ) {
    final date = DateTime.tryParse(log.createdAt);
    final pills = _detailPills(log.details);
    final tone = badgeColors(_tone(log.action));
    final who = log.userEmail ?? l10n.system;
    final when = date != null ? formatDateTime(date) : '';

    final icon = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_icon(log.action), size: 17, color: tone.fg),
    );
    final title = Text(
      _actionLabel(log.action, l10n),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.font(size: 14, weight: FontWeight.w500),
    );
    final meta = Text(
      when.isEmpty ? who : '$who · $when',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.font(
        size: 12,
        color: AppColors.textSecondary,
        tabularFigures: true,
      ),
    );
    final chips = Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: [for (final p in pills) _detailPill(p)],
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: const BorderSide(color: AppColors.border),
          right: const BorderSide(color: AppColors.border),
          top: isFirst
              ? const BorderSide(color: AppColors.border)
              : BorderSide.none,
          bottom: const BorderSide(color: AppColors.border),
        ),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(AppRadius.card) : Radius.zero,
          bottom: isLast ? const Radius.circular(AppRadius.card) : Radius.zero,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(minHeight: 52),
      child: LayoutBuilder(
        builder: (context, box) {
          if (box.maxWidth >= 720) {
            // Title, then who and when filling the middle, details pinned
            // to the right edge (flex shares left them floating mid-row).
            return Row(
              children: [
                icon,
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: title,
                ),
                const SizedBox(width: 12),
                Expanded(child: meta),
                if (pills.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: box.maxWidth * 0.35),
                    child: chips,
                  ),
                ],
              ],
            );
          }
          return Row(
            children: [
              icon,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [title, const SizedBox(height: 2), meta],
                ),
              ),
              if (pills.isNotEmpty) ...[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: box.maxWidth * 0.4),
                  child: chips,
                ),
              ],
            ],
          );
        },
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
      appBar: AppPageHeader(
        title: l10n.auditLog,
        subtitle: state.logs.isEmpty
            ? null
            // "25 entries", or "6 of 25 entries" while a filter is on.
            : logs.length == state.logs.length
                ? l10n.auditEntries(logs.length)
                : l10n.auditEntriesFiltered(logs.length, state.logs.length),
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
          ? AppSkeletonList(semanticLabel: l10n.loading)
          : state.error != null
          // Access is enforced by the router guard; an error here is a
          // failed load, so offer Retry rather than "restricted access".
          ? AppErrorState(
              title: l10n.loadFailedTitle,
              message: l10n.serverUnreachable,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(auditProvider.notifier).load(),
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
                  height: 58,
                  child: AppContentFrame(
                    maxWidth: 1248,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      children: [
                        _filterChip(
                          label: l10n.all,
                          selected: selectedFilter == null,
                          onTap: () => setState(() => selectedFilter = null),
                        ),
                        for (final f in filters)
                          _filterChip(
                            label: f.label,
                            selected: selectedFilter == f.key,
                            onTap: () => setState(
                              () => selectedFilter = selectedFilter == f.key
                                  ? null
                                  : f.key,
                            ),
                          ),
                      ],
                    ),
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
                          onRefresh: () =>
                              ref.read(auditProvider.notifier).load(),
                          child: AppContentFrame(
                            maxWidth: 1248,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                              itemCount: logs.length,
                              itemBuilder: (context, index) => _entry(
                                logs[index],
                                index == 0,
                                index == logs.length - 1,
                                l10n,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
