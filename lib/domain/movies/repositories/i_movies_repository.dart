import 'package:flutter_template/domain/movies/entities/movies_pagination.dart';

abstract interface class IMoviesRepository {
  Future<MoviesPagination> getNowPlayingMovies({
    int page = 1,
    String? language,
  });
}
