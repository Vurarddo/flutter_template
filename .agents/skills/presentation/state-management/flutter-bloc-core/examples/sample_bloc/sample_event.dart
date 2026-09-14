part of 'sample_bloc.dart';

sealed class SampleEvent extends Equatable {
  const SampleEvent();

  @override
  List<Object?> get props => [];
}

final class SampleFetchRequested extends SampleEvent {
  final String query;

  const SampleFetchRequested({this.query = ''});

  @override
  List<Object?> get props => [query];
}

final class SampleSubmitPressed extends SampleEvent {
  final Map<String, dynamic> payload;

  const SampleSubmitPressed(this.payload);

  @override
  List<Object?> get props => [payload];
}

final class SampleRetryClicked extends SampleEvent {
  const SampleRetryClicked();
}
