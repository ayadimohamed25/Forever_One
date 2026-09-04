import 'package:dio/dio.dart';

class SupplierRemoteDatasource {
  final Dio dio;
  SupplierRemoteDatasource(this.dio);

  Future<List<dynamic>> getSuppliers() async {
    final response = await dio.get('/suppliers');
    return response.data;
  }

  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> data) async {
    final response = await dio.post('/suppliers', data: data);
    return response.data;
  }
}