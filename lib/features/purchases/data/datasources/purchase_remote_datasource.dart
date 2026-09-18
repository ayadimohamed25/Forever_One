import 'package:dio/dio.dart';

class PurchaseRemoteDatasource {
  final Dio dio;
  PurchaseRemoteDatasource(this.dio);

  Future<List<dynamic>> getPurchases({String? search}) async {
    final response = await dio.get(
      '/purchases',
      queryParameters:
      search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getPurchaseDetail(String id) async {
    final response =
    await dio.get('/purchases/show', queryParameters: {'id': id});
    return response.data;
  }

  Future<Map<String, dynamic>> createPurchase(Map<String, dynamic> data) async {
    final response = await dio.post('/purchases', data: data);
    return response.data;
  }

  Future<void> updatePurchase(Map<String, dynamic> data) async {
    await dio.post('/purchases/update', data: data);
  }

  Future<void> deletePurchase(String id) async {
    await dio.post('/purchases/delete', data: {'id': id});
  }

  Future<void> receivePurchase(String id, {String? receivedDate}) async {
    await dio.post('/purchases/receive',
        data: {'id': id, 'received_date': receivedDate});
  }
}