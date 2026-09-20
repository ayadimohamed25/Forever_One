import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl {
  final CategoryRemoteDatasource remote;
  CategoryRepositoryImpl(this.remote);

  CategoryEntity _map(Map<String, dynamic> j) => CategoryEntity(
    id: '${j['id']}',
    name: '${j['name'] ?? ''}',
    description: j['description']?.toString(),
    colorHex: j['color']?.toString(),
    productCount: int.tryParse('${j['product_count'] ?? 0}') ?? 0,
  );

  Future<Either<Failure, List<CategoryEntity>>> getCategories({String? search}) async {
    try {
      final data = await remote.getCategories(search: search);
      return Right(data
          .whereType<Map>()
          .map((j) => _map(Map<String, dynamic>.from(j)))
          .toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load categories')));
    }
  }

  Future<Either<Failure, CategoryEntity>> createCategory({
    required String name,
    String? description,
    String? colorHex,
  }) async {
    try {
      final data = await remote.createCategory({
        'name': name,
        'description': description,
        'color': colorHex,
      });
      return Right(_map(Map<String, dynamic>.from(data)));
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to create category')));
    }
  }

  Future<Either<Failure, void>> updateCategory({
    required String id,
    required String name,
    String? description,
    String? colorHex,
  }) async {
    try {
      await remote.updateCategory({
        'id': id,
        'name': name,
        'description': description,
        'color': colorHex,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to update category')));
    }
  }

  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await remote.deleteCategory(id);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('CATEGORY_IN_USE'));
      }
      return Left(ServerFailure(_err(e, 'Failed to delete category')));
    }
  }

  String _err(DioException e, String fallback) {
    return e.response?.data is Map
        ? (e.response?.data['error'] ?? fallback)
        : '$fallback — check your connection';
  }
}