import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie.freezed.dart';

@freezed
class Movie with _$Movie {
  final int id;
  final String title;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String? posterPath;
  final String? posterUrl;
  final String? backdropPath;
  final String? releaseDate;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    this.posterPath,
    this.posterUrl,
    this.backdropPath,
    this.releaseDate,
  });
}
