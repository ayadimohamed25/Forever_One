import '../../domain/entities/document_entity.dart';

class DocumentModel {
  final String id;
  final String rawText;
  final double? extractedAmount;
  final String? extractedDate;
  final int confidence;

  DocumentModel({
    required this.id,
    required this.rawText,
    this.extractedAmount,
    this.extractedDate,
    required this.confidence,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      rawText: json['raw_text'] ?? '',
      extractedAmount: json['extracted_amount'] != null
          ? double.tryParse(json['extracted_amount'].toString())
          : null,
      extractedDate: json['extracted_date'],
      confidence: int.parse((json['confidence'] ?? 0).toString()),
    );
  }

  DocumentEntity toEntity() => DocumentEntity(
    id: id, rawText: rawText, extractedAmount: extractedAmount,
    extractedDate: extractedDate, confidence: confidence,
  );
}