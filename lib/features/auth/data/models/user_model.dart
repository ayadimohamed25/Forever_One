import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String role;
  final String tenantId;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.tenantId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      tenantId: json['tenant_id'] ?? '',
    );
  }

  UserEntity toEntity() {
    return UserEntity(id: id, email: email, role: role, tenantId: tenantId);
  }
}