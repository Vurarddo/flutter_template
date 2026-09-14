import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/movies/entities/movie.dart';
import 'package:flutter_template/domain/movies/failures/movies_failure.dart';
import 'package:flutter_template/domain/movies/usecases/get_now_playing_movies_usecase.dart';

part 'movies_bloc.g.dart';
part 'movies_event.dart';
part 'movies_state.dart';

@injectable
class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final GetNowPlayingMoviesUseCase _getNowPlayingMoviesUseCase;

  MoviesBloc(this._getNowPlayingMoviesUseCase) : super(const MoviesInitial()) {
    on<MoviesStarted>(_onStarted, transformer: restartable());
    on<MoviesRefreshed>(_onRefreshed, transformer: restartable());
    on<MoviesNextPageLoaded>(_onNextPageLoaded, transformer: droppable());
  }

  Future<void> _onStarted(
    MoviesStarted event,
    Emitter<MoviesState> emit,
  ) async {
    emit(const MoviesLoading());

    try {
      final pagination = await _getNowPlayingMoviesUseCase(page: 1);
      if (emit.isDone) return;

      emit(
        MoviesLoaded(
          movies: pagination.movies,
          page: pagination.page,
          hasMore: pagination.hasMore,
        ),
      );
    } on MoviesFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      if (emit.isDone) return;
      emit(MoviesError(failure.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      if (emit.isDone) return;
      emit(MoviesError(e.toString()));
    }
  }

  Future<void> _onRefreshed(
    MoviesRefreshed event,
    Emitter<MoviesState> emit,
  ) async {
    try {
      final pagination = await _getNowPlayingMoviesUseCase(page: 1);
      if (emit.isDone) return;

      emit(
        MoviesLoaded(
          movies: pagination.movies,
          page: pagination.page,
          hasMore: pagination.hasMore,
          isLoadingNextPage: false,
        ),
      );
    } on MoviesFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      if (emit.isDone) return;
      emit(MoviesError(failure.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      if (emit.isDone) return;
      emit(MoviesError(e.toString()));
    }
  }

  Future<void> _onNextPageLoaded(
    MoviesNextPageLoaded event,
    Emitter<MoviesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MoviesLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingNextPage) return;

    emit(currentState.copyWith(isLoadingNextPage: true));

    try {
      final nextPage = currentState.page + 1;
      final pagination = await _getNowPlayingMoviesUseCase(page: nextPage);
      if (emit.isDone) return;

      emit(
        currentState.copyWith(
          movies: [...currentState.movies, ...pagination.movies],
          page: pagination.page,
          hasMore: pagination.hasMore,
          isLoadingNextPage: false,
        ),
      );
    } on MoviesFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      if (emit.isDone) return;
      emit(currentState.copyWith(isLoadingNextPage: false));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      if (emit.isDone) return;
      emit(currentState.copyWith(isLoadingNextPage: false));
    }
  }
}
