import 'package:json_annotation/json_annotation.dart';

import 'package:flutter_template/data/movies/dto/movie_dto.dart';
import 'package:flutter_template/domain/movies/entities/movies_pagination.dart';

part 'movie_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class MovieResponseDto {
  final int? page;
  final List<MovieDto>? results;
  @JsonKey(name: 'total_pages')
  final int? totalPages;
  @JsonKey(name: 'total_results')
  final int? totalResults;

  const MovieResponseDto({
    this.page,
    this.results,
    this.totalPages,
    this.totalResults,
  });

  factory MovieResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseDtoFromJson(json);

  MoviesPagination toDomain({
    String imageBaseUrl = 'https://image.tmdb.org/t/p/w500',
  }) {
    final moviesList = results
            ?.map((dto) => dto.toDomain(imageBaseUrl: imageBaseUrl))
            .toList() ??
        const [];

    return MoviesPagination(
      page: page ?? 1,
      totalPages: totalPages ?? 1,
      totalResults: totalResults ?? moviesList.length,
      movies: moviesList,
    );
  }
}
