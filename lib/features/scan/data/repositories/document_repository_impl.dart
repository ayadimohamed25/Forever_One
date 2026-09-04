import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDatasource remote;
  DocumentRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, DocumentEntity>> scanDocument(File image) async {
    try {
      final data = await remote.scanDocument(image);
      return Right(DocumentModel.fromJson(data).toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e, 'Failed to scan document')));
    }
  }

  @override
  Future<Either<Failure, void>> confirmDocument({
    required String id,
    required double amount,
    String? date,
  }) async {
    try {
      await remote.confirmDocument({'id': id, 'amount': amount, 'date': date});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e, 'Failed to confirm document')));
    }
  }

  String _extractError(DioException e, String fallback) {
    return e.response?.data is Map ? (e.response?.data['error'] ?? fallback) : '$fallback — check your connection';
  }
}