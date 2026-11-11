import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return AuthRepositoryImpl(AuthRemoteDatasource(dio));
});

final loginUsecaseProvider = Provider((ref) {
  return LoginUsecase(ref.read(authRepositoryProvider));
});

/// Where the session stands. The router waits while it is [unknown] so a
/// restoring user is never bounced to the login screen and back.
///
///   app start ──► unknown ──restore()──► authenticated
///                    │                        │ logout() / 401
///                    └──── no token / 401 ──► unauthenticated ◄─┘
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final bool isLoading;
  final UserEntity? user;
  final String? error;

  /// Set when the session could not be restored because the server was
  /// unreachable. The token is kept, so the login screen offers a retry.
  final bool restoreFailedOffline;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.isLoading = false,
    this.user,
    this.error,
    this.restoreFailedOffline = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUsecase loginUsecase;
  final AuthRepository repository;

  AuthNotifier(this.loginUsecase, this.repository) : super(const AuthState());

  /// Rebuilds the session from the stored token. Called once at app start,
  /// and again from the login screen's Retry after an offline start.
  Future<void> restore() async {
    state = const AuthState(status: AuthStatus.unknown);
    final result = await repository.restoreSession();
    result.fold(
      (failure) {
        if (failure is! SessionExpiredFailure) {
          debugPrint('[auth] restore failed offline: ${failure.message}');
        }
        state = AuthState(
          status: AuthStatus.unauthenticated,
          restoreFailedOffline: failure is NetworkFailure,
        );
      },
      (user) => state = AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(
        status: AuthStatus.unauthenticated, isLoading: true);
    final result = await loginUsecase(email, password);
    result.fold(
      (failure) => state = AuthState(
          status: AuthStatus.unauthenticated, error: failure.message),
      (user) => state = AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> register({
    required String companyName,
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? city,
  }) async {
    state = const AuthState(
        status: AuthStatus.unauthenticated, isLoading: true);

    final result = await repository.register(
      companyName: companyName,
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      city: city,
    );

    result.fold(
      (failure) => state = AuthState(
          status: AuthStatus.unauthenticated, error: failure.message),
      (user) => state = AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  /// Deletes the token and clears the user, so no screen can be reached
  /// with Back after signing out.
  Future<void> logout() async {
    await repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// The API rejected the token mid-session (401). Same as a logout, but
  /// triggered by the network layer.
  Future<void> handleUnauthorized() async {
    if (state.status != AuthStatus.authenticated) return;
    debugPrint('[auth] 401 from the API, signing out');
    await logout();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  final notifier = AuthNotifier(LoginUsecase(repository), repository);
  // The interceptor reports 401s through this callback; wiring it here keeps
  // ApiClient free of any dependency on auth state.
  ref.read(apiClientProvider).onUnauthorized = notifier.handleUnauthorized;
  return notifier;
});
