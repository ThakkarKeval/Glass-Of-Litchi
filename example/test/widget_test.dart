import 'package:flutter_test/flutter_test.dart';
import 'package:glass_of_litchi_example/main.dart';

void main() {
  testWidgets('Verify Glass of Litchi navigation, chips, and reset', (tester) async {
    await tester.pumpWidget(const GlassOfLitchiDemoApp());
    await tester.pumpAndSettle();

    // Verify top glass views in GlassListScreen render
    expect(find.text('Search glass beverages...'), findsOneWidget);
    expect(find.text('Lychee Rose Spritzer'), findsOneWidget);

    // Test tapping a category chip
    expect(find.text('Juicy Pulp'), findsOneWidget);
    await tester.tap(find.text('Juicy Pulp'));
    await tester.pumpAndSettle();

    // Switch to Figma Inspector tab
    await tester.tap(find.text('Figma Inspector'));
    await tester.pumpAndSettle();

    expect(find.text('🎨 Figma Glass Inspector'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    // Test Reset button
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
  });
}
