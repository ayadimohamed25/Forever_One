import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/audit_remote_datasource.dart';
import '../../data/repositories/audit_repository_impl.dart';
import '../../domain/entities/audit_log_entity.dart';

final auditRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return AuditRepositoryImpl(AuditRemoteDatasource(dio));
});

class AuditState {
  final bool isLoading;
  final List<AuditLogEntity> logs;
  final String? error;
  const AuditState({this.isLoading = false, this.logs = const [], this.error});
}

class AuditNotifier extends StateNotifier<AuditState> {
  final AuditRepositoryImpl repository;
  AuditNotifier(this.repository) : super(const AuditState());

  Future<void> load() async {
    state = const AuditState(isLoading: true);
    final result = await repository.getAuditLogs();
    result.fold(
          (failure) => state = AuditState(error: failure.message),
          (logs) => state = AuditState(logs: logs),
    );
  }
}

final auditProvider = StateNotifierProvider<AuditNotifier, AuditState>((ref) {
  return AuditNotifier(ref.read(auditRepositoryProvider));
});