import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String role;
  final String tenantId;
  final String companyName;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.tenantId,
    required this.companyName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      tenantId: json['tenant_id'] ?? '',
      companyName: json['company_name'] ?? '',
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    role: role,
    tenantId: tenantId,
    companyName: companyName,
  );
}