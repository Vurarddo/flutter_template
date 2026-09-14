import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'sample_event.dart';
part 'sample_state.dart';
part 'sample_bloc.g.dart';

@injectable
class SampleBloc extends Bloc<SampleEvent, SampleState> {
  SampleBloc() : super(SampleInitial()) {
    // restartable for search/filtering
    on<SampleFetchRequested>(
      _onFetchRequested,
      transformer: restartable(),
    );

    // droppable for submission buttons to prevent spam clicks
    on<SampleSubmitPressed>(
      _onSubmitPressed,
      transformer: droppable(),
    );

    on<SampleRetryClicked>(
      _onRetryClicked,
      transformer: droppable(),
    );
  }

  Future<void> _onFetchRequested(
    SampleFetchRequested event,
    Emitter<SampleState> emit,
  ) async {
    emit(SampleLoadInProgress());
    try {
      // Async business logic here...
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (emit.isDone) return;

      emit(const SampleLoadSuccess(items: ['Item 1', 'Item 2']));
    } catch (e, st) {
      addError(e, st);
      if (emit.isDone) return;
      emit(SampleFailure(e.toString()));
    }
  }

  Future<void> _onSubmitPressed(
    SampleSubmitPressed event,
    Emitter<SampleState> emit,
  ) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (emit.isDone) return;
    } catch (e, st) {
      addError(e, st);
    }
  }

  Future<void> _onRetryClicked(
    SampleRetryClicked event,
    Emitter<SampleState> emit,
  ) async {
    add(const SampleFetchRequested());
  }
}
