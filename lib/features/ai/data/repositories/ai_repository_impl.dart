import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../models/ai_message_model.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDatasource remote;
  AiRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, AiMessageEntity>> ask(String question) async {
    try {
      final data = await remote.ask(question);
      return Right(AiMessageModel.fromJson(data).toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e, 'Failed to get AI response')));
    }
  }

  @override
  Future<Either<Failure, List<AiMessageEntity>>> getHistory() async {
    try {
      final data = await remote.getHistory();
      return Right(data.map((j) => AiMessageModel.fromJson(j).toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e, 'Failed to load history')));
    }
  }

  String _extractError(DioException e, String fallback) {
    return e.response?.data is Map ? (e.response?.data['error'] ?? fallback) : '$fallback — check your connection';
  }
}