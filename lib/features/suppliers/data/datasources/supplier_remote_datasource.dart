import 'package:dio/dio.dart';

class SupplierRemoteDatasource {
  final Dio dio;
  SupplierRemoteDatasource(this.dio);

  Future<List<dynamic>> getSuppliers({String? search}) async {
    final response = await dio.get(
      '/suppliers',
      queryParameters:
      search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getSupplierDetail(String id) async {
    final response = await dio.get('/suppliers/show', queryParameters: {'id': id});
    return response.data;
  }

  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> data) async {
    final response = await dio.post('/suppliers', data: data);
    return response.data;
  }

  Future<void> updateSupplier(Map<String, dynamic> data) async {
    await dio.post('/suppliers/update', data: data);
  }

  Future<void> deleteSupplier(String id) async {
    await dio.post('/suppliers/delete', data: {'id': id});
  }
}