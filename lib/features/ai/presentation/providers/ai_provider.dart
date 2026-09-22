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

  /// The backend's error code (AI_QUOTA, AI_NO_KEY…) or a plain message.
  final String? error;

  /// Kept so the user can retry the question that failed.
  final String? pendingQuestion;
  final String pendingLocale;

  const AiState({
    this.isLoading = false,
    this.messages = const [],
    this.error,
    this.pendingQuestion,
    this.pendingLocale = 'en',
  });
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

  Future<void> ask(String question, {String locale = 'en'}) async {
    state = AiState(isLoading: true, messages: state.messages);

    final result = await repository.ask(question, locale: locale);
    result.fold(
          (failure) => state = AiState(
        messages: state.messages,
        error: failure.message,
        pendingQuestion: question,
        pendingLocale: locale,
      ),
          (message) => state = AiState(messages: [...state.messages, message]),
    );
  }

  /// Re-sends the question that failed.
  Future<void> retry() async {
    final question = state.pendingQuestion;
    if (question == null) return;
    await ask(question, locale: state.pendingLocale);
  }

  void dismissError() {
    state = AiState(messages: state.messages, isLoading: state.isLoading);
  }
}

final aiProvider = StateNotifierProvider<AiNotifier, AiState>((ref) {
  return AiNotifier(ref.read(aiRepositoryProvider));
});