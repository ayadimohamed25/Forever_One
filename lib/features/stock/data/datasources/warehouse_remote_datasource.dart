import 'package:dio/dio.dart';

class WarehouseRemoteDatasource {
  final Dio dio;
  WarehouseRemoteDatasource(this.dio);

  Future<List<dynamic>> getWarehouses({String? search}) async {
    final response = await dio.get(
      '/warehouses',
      queryParameters:
      search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createWarehouse(Map<String, dynamic> data) async {
    final response = await dio.post('/warehouses', data: data);
    return response.data;
  }

  Future<void> updateWarehouse(Map<String, dynamic> data) async {
    await dio.post('/warehouses/update', data: data);
  }

  Future<void> deleteWarehouse(String id) async {
    await dio.post('/warehouses/delete', data: {'id': id});
  }
}