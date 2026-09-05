import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ai_message_entity.dart';

abstract class AiRepository {
  Future<Either<Failure, AiMessageEntity>> ask(String question);
  Future<Either<Failure, List<AiMessageEntity>>> getHistory();
}