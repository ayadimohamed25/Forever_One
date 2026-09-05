import '../../domain/entities/ai_message_entity.dart';

class AiMessageModel {
  final String question;
  final String answer;

  AiMessageModel({required this.question, required this.answer});

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  AiMessageEntity toEntity() => AiMessageEntity(question: question, answer: answer);
}