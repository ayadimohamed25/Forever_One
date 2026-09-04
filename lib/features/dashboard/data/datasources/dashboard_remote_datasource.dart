import 'package:dio/dio.dart';

class DashboardRemoteDatasource {
  final Dio dio;
  DashboardRemoteDatasource(this.dio);

  Future<Map<String, dynamic>> getSummary() async {
    final response = await dio.get('/dashboard');
    return response.data;
  }
}