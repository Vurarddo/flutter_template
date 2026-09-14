import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_template/presentation/ui_kit/rating_badge.dart';

void main() {
  testWidgets('RatingBadge displays formatted rating and star icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingBadge(
            rating: 8.4,
            voteCount: 120,
          ),
        ),
      ),
    );

    expect(find.text('8.4'), findsOneWidget);
    expect(find.text('(120)'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
  });
}
