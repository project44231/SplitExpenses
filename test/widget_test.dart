import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: PokerTrackerApp(),
      ),
    );

    // Verify that the app starts
    expect(find.byType(PokerTrackerApp), findsOneWidget);
  });
}
