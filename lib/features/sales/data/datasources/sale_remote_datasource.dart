import 'package:dio/dio.dart';

class SaleRemoteDatasource {
  final Dio dio;
  SaleRemoteDatasource(this.dio);

  Future<List<dynamic>> getSales({String? search}) async {
    final response = await dio.get(
      '/sales',
      queryParameters:
      search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getSaleDetail(String id) async {
    final response = await dio.get('/sales/show', queryParameters: {'id': id});
    return response.data;
  }

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> data) async {
    final response = await dio.post('/sales', data: data);
    return response.data;
  }

  Future<void> updateSale(Map<String, dynamic> data) async {
    await dio.post('/sales/update', data: data);
  }

  Future<void> deleteSale(String id) async {
    await dio.post('/sales/delete', data: {'id': id});
  }
}