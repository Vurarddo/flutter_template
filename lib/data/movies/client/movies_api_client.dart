import 'package:dio/dio.dart';
import 'package:flutter_template/data/movies/dto/movie_response_dto.dart';
import 'package:flutter_template/data/movies/endpoints/movies_endpoints.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'movies_api_client.g.dart';

@lazySingleton
@RestApi()
abstract class MoviesApiClient {
  @factoryMethod
  factory MoviesApiClient(Dio dio) = _MoviesApiClient;

  @GET(MoviesEndpoints.nowPlaying)
  Future<MovieResponseDto> getNowPlayingMovies({
    @Query('page') int page = 1,
    @Query('language') String? language,
  });
}
