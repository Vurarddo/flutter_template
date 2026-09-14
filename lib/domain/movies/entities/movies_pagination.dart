import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_template/domain/movies/entities/movie.dart';

part 'movies_pagination.freezed.dart';

@freezed
class MoviesPagination with _$MoviesPagination {
  final int page;
  final int totalPages;
  final int totalResults;
  final List<Movie> movies;

  const MoviesPagination({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.movies,
  });

  bool get hasMore => page < totalPages;
}
