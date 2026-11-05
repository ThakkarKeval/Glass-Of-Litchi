import 'package:flutter_test/flutter_test.dart';
import 'package:glass_of_litchi_example/main.dart';

void main() {
  testWidgets('Verify Glass of Litchi showcase renders', (tester) async {
    await tester.pumpWidget(const GlassOfLitchiDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('🍹 Glass of Litchi'), findsOneWidget);
    expect(find.text('Figma Optical Glass'), findsOneWidget);
    expect(find.text('🎨 Figma Glass Inspector'), findsOneWidget);
  });
}
