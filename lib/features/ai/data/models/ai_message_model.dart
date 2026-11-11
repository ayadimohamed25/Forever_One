import '../../domain/entities/ai_message_entity.dart';

class AiMessageModel {
  final String question;
  final String answer;
  final DateTime? createdAt;
  final bool isLocal;

  AiMessageModel({
    required this.question,
    required this.answer,
    this.createdAt,
    this.isLocal = false,
  });

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      question: '${json['question'] ?? ''}',
      answer: '${json['answer'] ?? ''}',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}')
          : null,
      // Anything other than 'local' — including a missing column — is an AI answer.
      isLocal: '${json['source'] ?? 'ai'}' == 'local',
    );
  }

  AiMessageEntity toEntity() => AiMessageEntity(
    question: question,
    answer: answer,
    createdAt: createdAt,
    isLocal: isLocal,
  );
}