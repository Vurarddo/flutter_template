import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/core/failures/domain_failure.dart';

// Sample events and states
sealed class ItemEvent {}
class ItemDetailsRequested extends ItemEvent {
  final String itemId;
  ItemDetailsRequested(this.itemId);
}

sealed class ItemState {
  const ItemState();
}
class ItemInitial extends ItemState {}
class ItemLoading extends ItemState {}
class ItemSuccess extends ItemState {
  final String data;
  ItemSuccess(this.data);
}
class ItemFailure extends ItemState {
  final DomainFailure failure;
  ItemFailure(this.failure);
}

@injectable
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  ItemBloc() : super(ItemInitial()) {
    on<ItemDetailsRequested>(_onDetailsRequested);
  }

  Future<void> _onDetailsRequested(
    ItemDetailsRequested event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoading());

    try {
      // Async business logic
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (emit.isDone) return;
      emit(ItemSuccess('Item details for ${event.itemId}'));
    } catch (error, stackTrace) {
      // 1. Mandatory stack trace forwarding for Crashlytics / Sentry
      addError(error, stackTrace);

      if (emit.isDone) return;

      // 2. Wrap into typed DomainFailure if not already typed
      final failure = error is DomainFailure
          ? error
          : DomainFailure.unknown(
              message: error.toString(),
            );

      // 3. Emit explicit Failure state without auto-resetting
      emit(ItemFailure(failure));
    }
  }
}
