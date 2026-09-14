import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Sample Bloc for scoping demo
sealed class FilterState {}
class FilterInitial extends FilterState {}
class FilterBloc extends Bloc<Object, FilterState> {
  FilterBloc() : super(FilterInitial());
}

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.filter_list),
      onPressed: () => _showFilterModal(context),
    );
  }

  void _showFilterModal(BuildContext context) {
    // Read the existing bloc from the current page's context
    final filterBloc = context.read<FilterBloc>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        // ✅ CORRECT: Reuses existing bloc without calling close() when sheet is popped
        return BlocProvider.value(
          value: filterBloc,
          child: const _FilterSheetContent(),
        );
      },
    );
  }
}

class _FilterSheetContent extends StatelessWidget {
  const _FilterSheetContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Text('Filter options here...'),
    );
  }
}
