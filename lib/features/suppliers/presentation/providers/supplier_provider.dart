import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/supplier_remote_datasource.dart';
import '../../data/repositories/supplier_repository_impl.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/usecases/create_supplier_usecase.dart';
import '../../domain/usecases/get_suppliers_usecase.dart';

final supplierRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return SupplierRepositoryImpl(SupplierRemoteDatasource(dio));
});

final getSuppliersUseCaseProvider = Provider((ref) {
  return GetSuppliersUseCase(ref.read(supplierRepositoryProvider));
});

final createSupplierUseCaseProvider = Provider((ref) {
  return CreateSupplierUseCase(ref.read(supplierRepositoryProvider));
});

class SupplierListState {
  final bool isLoading;
  final List<SupplierEntity> suppliers;
  final String? error;
  const SupplierListState({this.isLoading = false, this.suppliers = const [], this.error});
}

class SupplierListNotifier extends StateNotifier<SupplierListState> {
  final GetSuppliersUseCase getSuppliers;
  final CreateSupplierUseCase createSupplier;
  SupplierListNotifier(this.getSuppliers, this.createSupplier) : super(const SupplierListState());

  Future<void> load() async {
    state = const SupplierListState(isLoading: true);
    final result = await getSuppliers();
    result.fold(
          (failure) => state = SupplierListState(error: failure.message),
          (suppliers) => state = SupplierListState(suppliers: suppliers),
    );
  }

  Future<void> add({required String name, String? phone, String? email, required int leadTimeDays}) async {
    final result = await createSupplier(name: name, phone: phone, email: email, leadTimeDays: leadTimeDays);
    result.fold(
          (failure) => state = SupplierListState(suppliers: state.suppliers, error: failure.message),
          (supplier) => state = SupplierListState(suppliers: [...state.suppliers, supplier]),
    );
  }
}

final supplierListProvider = StateNotifierProvider<SupplierListNotifier, SupplierListState>((ref) {
  return SupplierListNotifier(ref.read(getSuppliersUseCaseProvider), ref.read(createSupplierUseCaseProvider));
});