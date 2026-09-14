import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_sale_entity.dart';
import '../../domain/repositories/customer_repository.dart';
final customerRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return CustomerRepositoryImpl(CustomerRemoteDatasource(dio));
});

class CustomerListState {
  final bool isLoading;
  final List<CustomerEntity> customers;
  final String? error;
  final String searchQuery;
  final bool hasSearched;

  const CustomerListState({
    this.isLoading = false,
    this.customers = const [],
    this.error,
    this.searchQuery = '',
    this.hasSearched = false,
  });

  CustomerListState copyWith({
    bool? isLoading,
    List<CustomerEntity>? customers,
    String? error,
    String? searchQuery,
    bool? hasSearched,
  }) {
    return CustomerListState(
      isLoading: isLoading ?? this.isLoading,
      customers: customers ?? this.customers,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class CustomerListNotifier extends StateNotifier<CustomerListState> {
  final CustomerRepositoryImpl repository;
  CustomerListNotifier(this.repository) : super(const CustomerListState());

  Future<void> load({String? search}) async {
    final query = search ?? state.searchQuery;
    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      hasSearched: query.isNotEmpty,
    );

    final result = await repository.getCustomers(search: query);
    result.fold(
          (failure) =>
      state = state.copyWith(isLoading: false, error: failure.message),
          (customers) =>
      state = state.copyWith(isLoading: false, customers: customers),
    );
  }

  Future<void> search(String query) => load(search: query);
  Future<void> clearSearch() => load(search: '');

  Future<void> add(CustomerInput input) async {
    final result = await repository.createCustomer(input);
    if (result.isLeft()) {
      state = state.copyWith(error: result.fold((f) => f.message, (_) => ''));
      return;
    }
    await load();
  }

  Future<void> update(String id, CustomerInput input) async {
    final result = await repository.updateCustomer(id, input);
    if (result.isLeft()) {
      state = state.copyWith(error: result.fold((f) => f.message, (_) => ''));
      return;
    }
    await load();
  }
  Future<String?> remove(String id) async {
    final result = await repository.deleteCustomer(id);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => null);
    }
    await load();
    return null;
  }
}

final customerListProvider =
StateNotifierProvider<CustomerListNotifier, CustomerListState>((ref) {
  return CustomerListNotifier(ref.read(customerRepositoryProvider));
});

// ---------- Detail ----------

class CustomerDetailState {
  final bool isLoading;
  final CustomerEntity? customer;
  final List<CustomerSaleEntity> sales;
  final String? error;

  const CustomerDetailState({
    this.isLoading = false,
    this.customer,
    this.sales = const [],
    this.error,
  });
}

class CustomerDetailNotifier extends StateNotifier<CustomerDetailState> {
  final CustomerRepositoryImpl repository;
  CustomerDetailNotifier(this.repository) : super(const CustomerDetailState());

  Future<void> load(String id) async {
    state = const CustomerDetailState(isLoading: true);
    final result = await repository.getCustomerDetail(id);
    result.fold(
          (failure) => state = CustomerDetailState(error: failure.message),
          (detail) => state = CustomerDetailState(
        customer: detail.customer,
        sales: detail.sales,
      ),
    );
  }
}

final customerDetailProvider =
StateNotifierProvider<CustomerDetailNotifier, CustomerDetailState>((ref) {
  return CustomerDetailNotifier(ref.read(customerRepositoryProvider));
});