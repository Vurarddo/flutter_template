import 'package:flutter_template/domain/movies/entities/movies_pagination.dart';
import 'package:flutter_template/domain/movies/repositories/i_movies_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetNowPlayingMoviesUseCase {
  final IMoviesRepository _moviesRepository;

  const GetNowPlayingMoviesUseCase(this._moviesRepository);

  Future<MoviesPagination> call({
    int page = 1,
    String? language,
  }) {
    return _moviesRepository.getNowPlayingMovies(
      page: page,
      language: language,
    );
  }
}
