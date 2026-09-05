import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/ai_remote_datasource.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/entities/ai_message_entity.dart';

final aiRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return AiRepositoryImpl(AiRemoteDatasource(dio));
});

class AiState {
  final bool isLoading;
  final List<AiMessageEntity> messages;
  final String? error;
  const AiState({this.isLoading = false, this.messages = const [], this.error});
}

class AiNotifier extends StateNotifier<AiState> {
  final AiRepositoryImpl repository;
  AiNotifier(this.repository) : super(const AiState());

  Future<void> loadHistory() async {
    final result = await repository.getHistory();
    result.fold(
          (failure) => state = AiState(error: failure.message),
          (messages) => state = AiState(messages: messages.reversed.toList()),
    );
  }

  Future<void> ask(String question) async {
    state = AiState(isLoading: true, messages: state.messages);
    final result = await repository.ask(question);
    result.fold(
          (failure) => state = AiState(messages: state.messages, error: failure.message),
          (message) => state = AiState(messages: [...state.messages, message]),
    );
  }
}

final aiProvider = StateNotifierProvider<AiNotifier, AiState>((ref) {
  return AiNotifier(ref.read(aiRepositoryProvider));
});