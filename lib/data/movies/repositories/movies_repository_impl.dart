import 'package:dio/dio.dart';
import 'package:flutter_template/data/movies/client/movies_api_client.dart';
import 'package:flutter_template/domain/movies/entities/movies_pagination.dart';
import 'package:flutter_template/domain/movies/failures/movies_failure.dart';
import 'package:flutter_template/domain/movies/repositories/i_movies_repository.dart';
import 'package:flutter_template/infrastructure/config/app_config.dart';
import 'package:flutter_template/infrastructure/network/dio_exception_mapper.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IMoviesRepository)
class MoviesRepositoryImpl implements IMoviesRepository {
  final MoviesApiClient _apiClient;
  final AppConfig _appConfig;

  const MoviesRepositoryImpl(
    this._apiClient,
    this._appConfig,
  );

  @override
  Future<MoviesPagination> getNowPlayingMovies({
    int page = 1,
    String? language,
  }) async {
    try {
      final responseDto = await _apiClient.getNowPlayingMovies(
        page: page,
        language: language,
      );

      return responseDto.toDomain(imageBaseUrl: _appConfig.imageBaseUrl);
    } on DioException catch (e) {
      throw DioExceptionMapper.mapToMoviesFailure(e);
    } catch (e, stackTrace) {
      throw UnknownMoviesFailure(
        message: e.toString(),
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
