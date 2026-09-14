import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_template/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Reset DI between tests to avoid container pollution
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('End-to-End Item User Journey', () {
    testWidgets('user can browse items, open details, and interact', (tester) async {
      // 1. Launch the actual application
      app.main();
      await tester.pumpAndSettle();

      // 2. Verify Home Screen is visible
      final homeView = find.byKey(const ValueKey('home_page_view'));
      expect(homeView, findsOneWidget);

      // 3. Scroll to target item if off-screen (works across Mobile, Web, Desktop)
      final targetItemKey = const ValueKey('item_card_item_1');
      await tester.scrollUntilVisible(
        find.byKey(targetItemKey),
        300.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // 4. Tap item card to navigate to Details
      await tester.tap(find.byKey(targetItemKey));
      await tester.pumpAndSettle();

      // 5. Verify navigation to detail screen
      expect(find.byKey(const ValueKey('item_detail_view')), findsOneWidget);
    });
  });
}
