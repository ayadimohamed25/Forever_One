class DocumentEntity {
  final String id;
  final String rawText;
  final double? extractedAmount;
  final String? extractedDate;
  final int confidence;

  const DocumentEntity({
    required this.id,
    required this.rawText,
    this.extractedAmount,
    this.extractedDate,
    required this.confidence,
  });
}