class AiMessageEntity {
  final String question;
  final String answer;

  /// When the answer was generated — shown under it so older, saved
  /// answers are never mistaken for current ones.
  final DateTime? createdAt;

  /// True when the answer was computed from the database rather than by the
  /// AI, so the app can label it.
  final bool isLocal;

  const AiMessageEntity({
    required this.question,
    required this.answer,
    this.createdAt,
    this.isLocal = false,
  });
}