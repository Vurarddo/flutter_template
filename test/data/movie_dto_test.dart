import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_template/data/movies/dto/movie_dto.dart';
import 'package:flutter_template/data/movies/dto/movie_response_dto.dart';

void main() {
  group('MovieDto & MovieResponseDto', () {
    test('MovieDto correctly maps to Movie Domain Entity', () {
      final json = {
        'id': 101,
        'title': 'Dune: Part Two',
        'overview': 'Paul Atreides unites with Chani and the Fremen...',
        'poster_path': '/dune_poster.jpg',
        'backdrop_path': '/dune_backdrop.jpg',
        'vote_average': 8.6,
        'vote_count': 4500,
        'release_date': '2024-03-01',
      };

      final dto = MovieDto.fromJson(json);
      final entity = dto.toDomain(imageBaseUrl: 'https://image.tmdb.org/t/p/w500');

      expect(entity.id, 101);
      expect(entity.title, 'Dune: Part Two');
      expect(entity.overview, 'Paul Atreides unites with Chani and the Fremen...');
      expect(entity.posterUrl, 'https://image.tmdb.org/t/p/w500/dune_poster.jpg');
      expect(entity.voteAverage, 8.6);
      expect(entity.voteCount, 4500);
      expect(entity.releaseDate, '2024-03-01');
    });

    test('MovieResponseDto maps to MoviesPagination Domain Entity', () {
      final json = {
        'page': 1,
        'total_pages': 5,
        'total_results': 100,
        'results': [
          {
            'id': 1,
            'title': 'Movie 1',
            'overview': 'Overview 1',
            'poster_path': '/p1.jpg',
            'vote_average': 7.5,
            'vote_count': 100,
          },
          {
            'id': 2,
            'title': 'Movie 2',
            'overview': 'Overview 2',
            'poster_path': null,
            'vote_average': 6.0,
            'vote_count': 50,
          },
        ],
      };

      final responseDto = MovieResponseDto.fromJson(json);
      final pagination = responseDto.toDomain();

      expect(pagination.page, 1);
      expect(pagination.totalPages, 5);
      expect(pagination.totalResults, 100);
      expect(pagination.hasMore, true);
      expect(pagination.movies.length, 2);
      expect(pagination.movies[0].title, 'Movie 1');
      expect(pagination.movies[1].posterUrl, isNull);
    });
  });
}
