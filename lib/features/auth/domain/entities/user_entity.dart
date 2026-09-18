class UserEntity {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String role;
  final String tenantId;
  final String companyName;
  final bool isActive;
  final DateTime? lastLoginAt;
  final List<String> permissions;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    required this.role,
    required this.tenantId,
    this.companyName = '',
    this.isActive = true,
    this.lastLoginAt,
    this.permissions = const [],
  });

  /// Prefers the real name, falls back to the email prefix.
  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) return fullName!;
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  bool get isAdmin => role == 'admin';

  /// The UI hides what the role cannot use, rather than letting the
  /// user hit a 403 wall.
  bool can(String permission) => permissions.contains(permission);
}