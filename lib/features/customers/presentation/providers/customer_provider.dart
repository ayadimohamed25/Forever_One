import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/create_customer_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';

final customerRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return CustomerRepositoryImpl(CustomerRemoteDatasource(dio));
});

final getCustomersUseCaseProvider = Provider((ref) {
  return GetCustomersUseCase(ref.read(customerRepositoryProvider));
});

final createCustomerUseCaseProvider = Provider((ref) {
  return CreateCustomerUseCase(ref.read(customerRepositoryProvider));
});

class CustomerListState {
  final bool isLoading;
  final List<CustomerEntity> customers;
  final String? error;
  const CustomerListState({this.isLoading = false, this.customers = const [], this.error});
}

class CustomerListNotifier extends StateNotifier<CustomerListState> {
  final GetCustomersUseCase getCustomers;
  final CreateCustomerUseCase createCustomer;
  CustomerListNotifier(this.getCustomers, this.createCustomer) : super(const CustomerListState());

  Future<void> load() async {
    state = const CustomerListState(isLoading: true);
    final result = await getCustomers();
    result.fold(
          (failure) => state = CustomerListState(error: failure.message),
          (customers) => state = CustomerListState(customers: customers),
    );
  }

  Future<void> add({required String name, String? phone, String? email, required double creditLimit}) async {
    final result = await createCustomer(name: name, phone: phone, email: email, creditLimit: creditLimit);
    result.fold(
          (failure) => state = CustomerListState(customers: state.customers, error: failure.message),
          (customer) => state = CustomerListState(customers: [...state.customers, customer]),
    );
  }
}

final customerListProvider = StateNotifierProvider<CustomerListNotifier, CustomerListState>((ref) {
  return CustomerListNotifier(ref.read(getCustomersUseCaseProvider), ref.read(createCustomerUseCaseProvider));
});