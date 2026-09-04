class UserEntity {
  final String id;
  final String email;
  final String role;
  final String tenantId;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.tenantId,
  });
}