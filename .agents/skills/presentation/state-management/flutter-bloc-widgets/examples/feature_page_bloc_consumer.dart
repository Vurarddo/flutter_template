import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Sample sealed states for illustration
sealed class FeatureState {
  const FeatureState();
}

final class FeatureInitial extends FeatureState {}

final class FeatureLoading extends FeatureState {}

final class FeatureSuccess extends FeatureState {
  final List<String> items;
  const FeatureSuccess(this.items);
}

final class FeatureFailure extends FeatureState {
  final String message;
  const FeatureFailure(this.message);
}

sealed class FeatureEvent {
  const FeatureEvent();
}

class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc() : super(FeatureInitial());
}

class FeatureView extends StatelessWidget {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeatureBloc, FeatureState>(
      listenWhen: (previous, current) => current is FeatureFailure,
      listener: (context, state) {
        if (state is FeatureFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      buildWhen: (previous, current) => current is! FeatureFailure,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Feature Details'),
          ),
          body: switch (state) {
            FeatureInitial() || FeatureLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            FeatureSuccess(:final items) => ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(title: Text(items[index])),
              ),
            FeatureFailure() => const Center(child: Text('Failed to load items.')),
          },
        );
      },
    );
  }
}
