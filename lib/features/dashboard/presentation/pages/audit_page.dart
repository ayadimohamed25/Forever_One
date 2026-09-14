import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
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
    switch (action) {
      case 'login':
        return Icons.login;
      case 'create_sale':
        return Icons.point_of_sale;
      case 'create_purchase':
        return Icons.shopping_cart;
      case 'record_payment':
        return Icons.payments;
      case 'stock_movement':
        return Icons.inventory;
      case 'confirm_document':
        return Icons.document_scanner;
      case 'ai_query':
        return Icons.smart_toy;
      case 'generate_report':
        return Icons.picture_as_pdf;
      default:
        return Icons.history;
    }
  }

  Color _actionColor(String action, ThemeData theme) {
    switch (action) {
      case 'login':
        return Colors.blueGrey;
      case 'create_sale':
        return Colors.green.shade700;
      case 'create_purchase':
        return theme.colorScheme.tertiary;
      case 'record_payment':
        return Colors.teal.shade700;
      case 'stock_movement':
        return Colors.indigo;
      case 'confirm_document':
        return Colors.deepOrange;
      case 'ai_query':
        return theme.colorScheme.primary;
      case 'generate_report':
        return Colors.brown;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
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
        return action;
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

  Widget _buildTimeline(
      List<dynamic> logs, ThemeData theme, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final color = _actionColor(log.action, theme);
        final isLast = index == logs.length - 1;
        final details = _formatDetails(log.details);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_actionIcon(log.action), size: 18, color: color),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        _actionLabel(log.action, l10n),
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              log.userEmail ?? l10n.system,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.schedule,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Text(
                            log.createdAt,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            details,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontFamily: 'monospace',
                              color: theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final filterOptions = _filterOptions(l10n);

    final filteredLogs = selectedFilter == null
        ? state.logs
        : state.logs.where((l) => l.action == selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.auditLog),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: () => ref.read(auditProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline,
                  size: 56, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 16),
              Text(l10n.restrictedAccess,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(state.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      )
          : state.logs.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history,
                size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(l10n.noActionsRecorded,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      )
          : Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
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
                    selectedFilter = selectedFilter == e.key
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
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_alt_off_outlined,
                      size: 48,
                      color:
                      theme.colorScheme.outlineVariant),
                  const SizedBox(height: 12),
                  Text(l10n.noActionsOfThisType,
                      style: TextStyle(
                          color: theme.colorScheme
                              .onSurfaceVariant)),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () =>
                  ref.read(auditProvider.notifier).load(),
              child:
              _buildTimeline(filteredLogs, theme, l10n),
            ),
          ),
        ],
      ),
    );
  }
}