class AiMessageEntity {
  final String question;
  final String answer;

  /// When the answer was generated — shown under it so older, saved
  /// answers are never mistaken for current ones.
  final DateTime? createdAt;

  const AiMessageEntity({
    required this.question,
    required this.answer,
    this.createdAt,
  });
}