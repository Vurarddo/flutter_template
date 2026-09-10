part of 'movies_bloc.dart';

sealed class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => [];
}

final class MoviesStarted extends MoviesEvent {
  const MoviesStarted();
}

final class MoviesRefreshed extends MoviesEvent {
  const MoviesRefreshed();
}

final class MoviesNextPageLoaded extends MoviesEvent {
  const MoviesNextPageLoaded();
}
