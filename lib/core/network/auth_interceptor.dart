import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Adds the bearer token to every request, and reports a rejected token.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  /// Called on a 401 from any endpoint except the sign-in ones, where a 401
  /// means "wrong password", not "session expired".
  final Future<void> Function()? onUnauthorized;

  AuthInterceptor({this.onUnauthorized, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _publicPaths = ['/auth/login', '/auth/register'];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isPublic =
        _publicPaths.any((p) => err.requestOptions.path.endsWith(p));
    if (err.response?.statusCode == 401 && !isPublic) {
      await onUnauthorized?.call();
    }
    return handler.next(err);
  }
}
