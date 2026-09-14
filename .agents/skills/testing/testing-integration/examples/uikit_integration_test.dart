import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_template/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('UiKitPage Integration Smoke Test', () {
    testWidgets('renders UiKitPage, switches theme modes, and validates UI sections', (tester) async {
      // 1. Launch the actual application
      app.main();
      await tester.pumpAndSettle();

      // 2. Verify UiKit landing is displayed
      expect(find.text('UI Kit & Design System'), findsWidgets);

      // 3. Toggle Theme Switcher (System -> Light -> Dark)
      final darkThemeButton = find.text('Dark');
      if (darkThemeButton.evaluate().isNotEmpty) {
        await tester.tap(darkThemeButton);
        await tester.pumpAndSettle();
      }

      final lightThemeButton = find.text('Light');
      if (lightThemeButton.evaluate().isNotEmpty) {
        await tester.tap(lightThemeButton);
        await tester.pumpAndSettle();
      }

      // 4. Scroll through UI showcase sections smoothly without overflow
      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pumpAndSettle();

      // 5. Verify Buttons & Form Controls exist
      expect(find.byType(FilledButton), findsWidgets);
      expect(find.byType(OutlinedButton), findsWidgets);
    });
  });
}
