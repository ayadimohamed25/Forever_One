import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class ApiClient {
  /// The API root. Defaults to 10.0.2.2, the address the Android emulator
  /// uses to reach the PC's localhost. For web, desktop or a real phone pass
  /// your own, e.g.
  ///   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost/forever-one-backend/public/index.php/api/v1
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2/forever-one-backend/public/index.php/api/v1',
  );

  final Dio dio;

  /// Called when the API rejects the stored token (401). Set by the auth
  /// provider; null until then, in which case 401s just surface as errors.
  Future<void> Function()? onUnauthorized;

  ApiClient() : dio = Dio() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 20);
    dio.options.receiveTimeout = const Duration(seconds: 90);
    dio.interceptors.add(AuthInterceptor(onUnauthorized: () async => onUnauthorized?.call()));
  }
}
