import 'package:dio/dio.dart';

class PaymentRemoteDatasource {
  final Dio dio;
  PaymentRemoteDatasource(this.dio);

  Future<Map<String, dynamic>> getSaleBalance(String saleId) async {
    final response = await dio.get('/payments/sale-balance', queryParameters: {'sale_id': saleId});
    return response.data;
  }

  Future<Map<String, dynamic>> getPurchaseBalance(String purchaseId) async {
    final response = await dio.get('/payments/purchase-balance', queryParameters: {'purchase_id': purchaseId});
    return response.data;
  }

  Future<Map<String, dynamic>> recordPayment(Map<String, dynamic> data) async {
    final response = await dio.post('/payments', data: data);
    return response.data;
  }
}