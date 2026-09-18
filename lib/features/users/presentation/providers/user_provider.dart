import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return UserRepositoryImpl(UserRemoteDatasource(dio));
});

// ---------- User list ----------

class UserListState {
  final bool isLoading;
  final List<UserEntity> users;
  final String? error;
  final String searchQuery;
  final bool hasSearched;

  const UserListState({
    this.isLoading = false,
    this.users = const [],
    this.error,
    this.searchQuery = '',
    this.hasSearched = false,
  });
}

class UserListNotifier extends StateNotifier<UserListState> {
  final UserRepositoryImpl repository;
  UserListNotifier(this.repository) : super(const UserListState());

  Future<void> load({String? search}) async {
    final query = search ?? state.searchQuery;
    state = UserListState(
      isLoading: true,
      users: state.users,
      searchQuery: query,
      hasSearched: query.isNotEmpty,
    );

    final result = await repository.getUsers(search: query);
    result.fold(
          (failure) => state = UserListState(
          error: failure.message,
          searchQuery: query,
          hasSearched: query.isNotEmpty),
          (users) => state = UserListState(
          users: users, searchQuery: query, hasSearched: query.isNotEmpty),
    );
  }

  Future<void> search(String query) => load(search: query);
  Future<void> clearSearch() => load(search: '');

  /// Returns null on success, or the backend error code.
  Future<String?> add(UserInput input) async {
    final result = await repository.createUser(input);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }

  Future<String?> update(String id, UserInput input) async {
    final result = await repository.updateUser(id, input);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }

  Future<String?> remove(String id) async {
    final result = await repository.deleteUser(id);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }

  Future<String?> resetPassword(String id, String password) async {
    final result = await repository.resetPassword(id, password);
    return result.fold((f) => f.message, (_) => null);
  }
}

final userListProvider =
StateNotifierProvider<UserListNotifier, UserListState>((ref) {
  return UserListNotifier(ref.read(userRepositoryProvider));
});

// ---------- Own profile ----------

class ProfileState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;

  const ProfileState({this.isLoading = false, this.user, this.error});
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final UserRepositoryImpl repository;
  ProfileNotifier(this.repository) : super(const ProfileState());

  Future<void> load() async {
    state = const ProfileState(isLoading: true);
    final result = await repository.getProfile();
    result.fold(
          (failure) => state = ProfileState(error: failure.message),
          (user) => state = ProfileState(user: user),
    );
  }

  Future<String?> updateProfile({
    required String email,
    String? fullName,
    String? phone,
  }) async {
    final result = await repository.updateProfile(
      email: email,
      fullName: fullName,
      phone: phone,
    );
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }

  Future<String?> changePassword(
      String currentPassword, String newPassword) async {
    final result =
    await repository.changeOwnPassword(currentPassword, newPassword);
    return result.fold((f) => f.message, (_) => null);
  }
}

final profileProvider =
StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.read(userRepositoryProvider));
});