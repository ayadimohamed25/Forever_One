import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient() : dio = Dio() {
    // 10.0.2.2 = special address the Android EMULATOR uses to reach your PC's localhost.
    // If you test on a real physical phone instead, tell me — the address needs to change.
    dio.options.baseUrl =
    'http://10.0.2.2/forever-one-backend/public/index.php/api/v1';
    dio.options.connectTimeout = const Duration(seconds: 20);
    dio.options.receiveTimeout = const Duration(seconds: 90);
    dio.interceptors.add(AuthInterceptor());
  }
}