import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final authRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return AuthRepositoryImpl(AuthRemoteDatasource(dio));
});

final loginUsecaseProvider = Provider((ref) {
  return LoginUsecase(ref.read(authRepositoryProvider));
});

class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;
  const AuthState({this.isLoading = false, this.user, this.error});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUsecase loginUsecase;
  final AuthRepository repository;
  AuthNotifier(this.loginUsecase, this.repository) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    final result = await loginUsecase(email, password);
    result.fold(
          (failure) => state = AuthState(error: failure.message),
          (user) => state = AuthState(user: user),
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
    state = const AuthState(isLoading: true);

    final result = await repository.register(
      companyName: companyName,
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      city: city,
    );

    result.fold(
          (failure) => state = AuthState(error: failure.message),
          (user) => state = AuthState(user: user),
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(LoginUsecase(repository), repository);
});