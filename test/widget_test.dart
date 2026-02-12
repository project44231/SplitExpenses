import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_expenses/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SplitExpensesApp(),
      ),
    );

    // Verify that the app starts
    expect(find.byType(SplitExpensesApp), findsOneWidget);
  });
}
