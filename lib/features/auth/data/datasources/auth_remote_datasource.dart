import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  final Dio dio;
  AuthRemoteDatasource(this.dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await dio.post('/auth/register', data: data);
    return response.data;
  }

  /// The signed-in user and their permissions: `{user: {...}, permissions: [...]}`.
  /// Used to restore a session from a stored token.
  Future<Map<String, dynamic>> profile() async {
    final response = await dio.get(
      '/profile',
      options: Options(receiveTimeout: const Duration(seconds: 10)),
    );
    return response.data;
  }
}