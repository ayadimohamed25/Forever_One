class AuditLogEntity {
  final String id;
  final String? userEmail;
  final String action;
  final String? entityType;
  final String? details;
  final String createdAt;

  const AuditLogEntity({
    required this.id,
    this.userEmail,
    required this.action,
    this.entityType,
    this.details,
    required this.createdAt,
  });
}