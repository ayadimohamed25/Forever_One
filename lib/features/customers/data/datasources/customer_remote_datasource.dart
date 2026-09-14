import 'package:dio/dio.dart';

class CustomerRemoteDatasource {
  final Dio dio;
  CustomerRemoteDatasource(this.dio);

  Future<List<dynamic>> getCustomers({String? search}) async {
    final response = await dio.get(
      '/customers',
      queryParameters:
      search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getCustomerDetail(String id) async {
    final response = await dio.get('/customers/show', queryParameters: {'id': id});
    return response.data;
  }

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> data) async {
    final response = await dio.post('/customers', data: data);
    return response.data;
  }

  Future<void> updateCustomer(Map<String, dynamic> data) async {
    await dio.post('/customers/update', data: data);
  }

  Future<void> deleteCustomer(String id) async {
    await dio.post('/customers/delete', data: {'id': id});
  }
}