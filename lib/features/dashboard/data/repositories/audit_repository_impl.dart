import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../datasources/audit_remote_datasource.dart';

class AuditRepositoryImpl {
  final AuditRemoteDatasource remote;
  AuditRepositoryImpl(this.remote);

  Future<Either<Failure, List<AuditLogEntity>>> getAuditLogs() async {
    try {
      final data = await remote.getAuditLogs();
      return Right(data.map((j) => AuditLogEntity(
        id: j['id'],
        userEmail: j['user_email'],
        action: j['action'] ?? '',
        entityType: j['entity_type'],
        details: j['details'],
        createdAt: j['created_at'] ?? '',
      )).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return const Left(AuthFailure('Accès réservé aux administrateurs'));
      }
      final message = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Failed to load audit log')
          : 'Failed to load audit log — check your connection';
      return Left(ServerFailure(message));
    }
  }
}