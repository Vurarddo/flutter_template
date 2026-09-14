part of 'sample_bloc.dart';

sealed class SampleState extends Equatable {
  const SampleState();

  @override
  List<Object?> get props => [];
}

final class SampleInitial extends SampleState {}

final class SampleLoadInProgress extends SampleState {}

@CopyWith()
final class SampleLoadSuccess extends SampleState {
  final List<String> items;
  final bool hasMore;
  final bool isRefreshing;

  const SampleLoadSuccess({
    required this.items,
    this.hasMore = false,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [items, hasMore, isRefreshing];
}

final class SampleFailure extends SampleState {
  final String message;

  const SampleFailure(this.message);

  @override
  List<Object?> get props => [message];
}
