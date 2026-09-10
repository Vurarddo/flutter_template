import 'package:flutter_template/domain/movies/entities/movie.dart';
import 'package:flutter_template/domain/movies/entities/movies_pagination.dart';
import 'package:flutter_template/domain/movies/repositories/i_movies_repository.dart';
import 'package:flutter_template/domain/movies/usecases/get_now_playing_movies_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMoviesRepository implements IMoviesRepository {
  @override
  Future<MoviesPagination> getNowPlayingMovies({
    int page = 1,
    String? language,
  }) async {
    return MoviesPagination(
      page: page,
      totalPages: 3,
      totalResults: 60,
      movies: [
        Movie(
          id: 1,
          title: 'Test Movie $page',
          overview: 'Test overview',
          voteAverage: 8.0,
          voteCount: 100,
        ),
      ],
    );
  }
}

void main() {
  group('GetNowPlayingMoviesUseCase', () {
    test('calls repository and returns MoviesPagination entity', () async {
      final repository = FakeMoviesRepository();
      final useCase = GetNowPlayingMoviesUseCase(repository);

      final result = await useCase(page: 2);

      expect(result.page, 2);
      expect(result.totalPages, 3);
      expect(result.hasMore, true);
      expect(result.movies.length, 1);
      expect(result.movies.first.title, 'Test Movie 2');
    });
  });
}
