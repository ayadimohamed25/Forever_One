import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/document_remote_datasource.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/entities/document_entity.dart';

final documentRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return DocumentRepositoryImpl(DocumentRemoteDatasource(dio));
});

class ScanState {
  final bool isLoading;
  final DocumentEntity? document;
  final bool confirmed;
  final String? error;
  const ScanState({this.isLoading = false, this.document, this.confirmed = false, this.error});
}

class ScanNotifier extends StateNotifier<ScanState> {
  final DocumentRepositoryImpl repository;
  ScanNotifier(this.repository) : super(const ScanState());

  Future<void> scan(File image) async {
    state = const ScanState(isLoading: true);
    final result = await repository.scanDocument(image);
    result.fold(
          (failure) => state = ScanState(error: failure.message),
          (document) => state = ScanState(document: document),
    );
  }

  Future<void> confirm({required String id, required double amount, String? date}) async {
    final result = await repository.confirmDocument(id: id, amount: amount, date: date);
    result.fold(
          (failure) => state = ScanState(document: state.document, error: failure.message),
          (_) => state = ScanState(document: state.document, confirmed: true),
    );
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref.read(documentRepositoryProvider));
});