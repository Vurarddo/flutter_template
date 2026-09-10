part of 'movies_bloc.dart';

sealed class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

final class MoviesInitial extends MoviesState {
  const MoviesInitial();
}

final class MoviesLoading extends MoviesState {
  const MoviesLoading();
}

@CopyWith()
final class MoviesLoaded extends MoviesState {
  final List<Movie> movies;
  final int page;
  final bool hasMore;
  final bool isLoadingNextPage;

  const MoviesLoaded({
    required this.movies,
    required this.page,
    required this.hasMore,
    this.isLoadingNextPage = false,
  });

  @override
  List<Object?> get props => [movies, page, hasMore, isLoadingNextPage];
}

final class MoviesError extends MoviesState {
  final String message;

  const MoviesError(this.message);

  @override
  List<Object?> get props => [message];
}
