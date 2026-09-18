import '../../domain/entities/user_entity.dart';

class UserModel {
  static UserEntity fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: '${json['id']}',
      email: '${json['email'] ?? ''}',
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      role: '${json['role'] ?? ''}',
      tenantId: '${json['tenant_id'] ?? ''}',
      companyName: '${json['company_name'] ?? ''}',
      isActive: '${json['is_active'] ?? 1}' != '0',
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse('${json['last_login_at']}')
          : null,
      permissions: ((json['permissions'] ?? []) as List)
          .map((p) => '$p')
          .toList(),
    );
  }
}