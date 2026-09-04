import 'package:dio/dio.dart';

class WarehouseRemoteDatasource {
  final Dio dio;
  WarehouseRemoteDatasource(this.dio);

  Future<List<dynamic>> getWarehouses() async {
    final response = await dio.get('/warehouses');
    return response.data;
  }
}