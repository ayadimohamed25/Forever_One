import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document_entity.dart';

abstract class DocumentRepository {
  Future<Either<Failure, DocumentEntity>> scanDocument(File image);
  Future<Either<Failure, void>> confirmDocument({
    required String id,
    required double amount,
    String? date,
  });
}