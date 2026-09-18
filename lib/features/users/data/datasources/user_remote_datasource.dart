import 'package:dio/dio.dart';

class UserRemoteDatasource {
  final Dio dio;
  UserRemoteDatasource(this.dio);

  Future<List<dynamic>> getUsers({String? search}) async {
    final response = await dio.get(
      '/users',
      queryParameters:
      search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await dio.post('/users', data: data);
    return response.data;
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    await dio.post('/users/update', data: data);
  }

  Future<void> deleteUser(String id) async {
    await dio.post('/users/delete', data: {'id': id});
  }

  Future<void> resetPassword(String id, String password) async {
    await dio.post('/users/reset-password',
        data: {'id': id, 'password': password});
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await dio.get('/profile');
    return response.data;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await dio.post('/profile', data: data);
  }

  Future<void> changeOwnPassword(
      String currentPassword, String newPassword) async {
    await dio.post('/profile/password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }
}