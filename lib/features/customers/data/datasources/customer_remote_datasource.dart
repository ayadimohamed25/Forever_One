import 'package:dio/dio.dart';

class CustomerRemoteDatasource {
  final Dio dio;
  CustomerRemoteDatasource(this.dio);

  Future<List<dynamic>> getCustomers() async {
    final response = await dio.get('/customers');
    return response.data;
  }

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> data) async {
    final response = await dio.post('/customers', data: data);
    return response.data;
  }
}