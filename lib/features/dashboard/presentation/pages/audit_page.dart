import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audit_provider.dart';

class AuditPage extends ConsumerStatefulWidget {
  const AuditPage({super.key});

  @override
  ConsumerState<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends ConsumerState<AuditPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(auditProvider.notifier).load());
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
      default:
        return Icons.history;
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'login':
        return 'Connexion';
      case 'create_sale':
        return 'Vente créée';
      case 'create_purchase':
        return 'Achat enregistré';
      case 'record_payment':
        return 'Paiement enregistré';
      case 'stock_movement':
        return 'Mouvement de stock';
      case 'confirm_document':
        return 'Document validé';
      case 'ai_query':
        return 'Question IA';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal d\'audit'),
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
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(state.error!, textAlign: TextAlign.center),
            ],
          ),
        ),
      )
          : state.logs.isEmpty
          ? const Center(child: Text('Aucune action enregistrée'))
          : ListView.separated(
        itemCount: state.logs.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final log = state.logs[index];
          return ListTile(
            leading: Icon(_actionIcon(log.action)),
            title: Text(_actionLabel(log.action)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${log.userEmail ?? "système"} · ${log.createdAt}',
                    style: const TextStyle(fontSize: 12)),
                if (log.details != null)
                  Text(log.details!,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            isThreeLine: log.details != null,
          );
        },
      ),
    );
  }
}