class UserEntity {
  final String id;
  final String email;
  final String role;
  final String tenantId;
  final String companyName;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.tenantId,
    this.companyName = '',
  });

  /// The part of the email before @, used as a display name fallback.
  String get displayName {
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  String get initials {
    final name = displayName;
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}