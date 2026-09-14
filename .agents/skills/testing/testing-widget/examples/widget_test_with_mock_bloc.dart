import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../examples/widget_test_wrapper_sample.dart';

// Dummy state and event for illustration
sealed class ItemState {
  const ItemState();
}
class ItemLoading extends ItemState {}
class ItemSuccess extends ItemState {
  final String title;
  const ItemSuccess(this.title);
}

sealed class ItemEvent {}

class MockItemBloc extends MockBloc<ItemEvent, ItemState> implements Bloc<ItemEvent, ItemState> {}

class SimpleItemView extends StatelessWidget {
  const SimpleItemView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MockItemBloc, ItemState>(
      builder: (context, state) {
        return switch (state) {
          ItemLoading() => const CircularProgressIndicator(),
          ItemSuccess(:final title) => Text(title),
        };
      },
    );
  }
}

void main() {
  late MockItemBloc mockItemBloc;

  setUp(() {
    mockItemBloc = MockItemBloc();
  });

  tearDown(() {
    mockItemBloc.close();
  });

  testWidgets('renders spinner without pumpAndSettle timeout', (tester) async {
    when(() => mockItemBloc.state).thenReturn(ItemLoading());

    await tester.pumpWidget(
      WidgetTestWrapper(
        child: BlocProvider<MockItemBloc>.value(
          value: mockItemBloc,
          child: const SimpleItemView(),
        ),
      ),
    );

    // Pump a single frame without pumpAndSettle
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders item title on success', (tester) async {
    when(() => mockItemBloc.state).thenReturn(const ItemSuccess('Super Product'));

    await tester.pumpWidget(
      WidgetTestWrapper(
        child: BlocProvider<MockItemBloc>.value(
          value: mockItemBloc,
          child: const SimpleItemView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Super Product'), findsOneWidget);
  });
}
