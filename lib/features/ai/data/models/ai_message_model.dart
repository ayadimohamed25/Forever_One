import '../../domain/entities/ai_message_entity.dart';

class AiMessageModel {
  final String question;
  final String answer;
  final DateTime? createdAt;

  AiMessageModel({
    required this.question,
    required this.answer,
    this.createdAt,
  });

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      question: '${json['question'] ?? ''}',
      answer: '${json['answer'] ?? ''}',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}')
          : null,
    );
  }

  AiMessageEntity toEntity() => AiMessageEntity(
    question: question,
    answer: answer,
    createdAt: createdAt,
  );
}