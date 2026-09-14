import 'package:json_annotation/json_annotation.dart';

import 'package:flutter_template/domain/movies/entities/movie.dart';

part 'movie_dto.g.dart';

@JsonSerializable(createToJson: false)
class MovieDto {
  final int id;
  final String? title;
  final String? overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'vote_average')
  final num? voteAverage;
  @JsonKey(name: 'vote_count')
  final int? voteCount;
  @JsonKey(name: 'release_date')
  final String? releaseDate;

  const MovieDto({
    required this.id,
    this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.voteCount,
    this.releaseDate,
  });

  factory MovieDto.fromJson(Map<String, dynamic> json) =>
      _$MovieDtoFromJson(json);

  Movie toDomain({String imageBaseUrl = 'https://image.tmdb.org/t/p/w500'}) {
    final poster = posterPath;
    final String? fullPosterUrl =
        (poster != null && poster.isNotEmpty) ? '$imageBaseUrl$poster' : null;

    return Movie(
      id: id,
      title: title ?? '',
      overview: overview ?? '',
      voteAverage: (voteAverage ?? 0.0).toDouble(),
      voteCount: voteCount ?? 0,
      posterPath: posterPath,
      posterUrl: fullPosterUrl,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
    );
  }
}
