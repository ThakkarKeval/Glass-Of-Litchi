import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_of_litchi/glass_of_litchi.dart';

void main() {
  group('LitchiFlavour presets', () {
    test('standard presets have valid properties', () {
      expect(LitchiFlavour.dewy.name, 'Dewy');
      expect(LitchiFlavour.juicy.name, 'Juicy');
      expect(LitchiFlavour.frosted.name, 'Frosted');
      expect(LitchiFlavour.crystal.name, 'Crystal');
      expect(LitchiFlavour.milkyLitchi.name, 'Milky Litchi');
      expect(LitchiFlavour.roseTint.name, 'Rose Tint');
      expect(LitchiFlavour.goldenCitrus.name, 'Golden Citrus');

      expect(LitchiFlavour.dewy.blurSigma, greaterThan(0));
      expect(LitchiFlavour.juicy.tintColor.a, greaterThan(0));
    });

    test('copyWith properly modifies fields', () {
      final custom = LitchiFlavour.dewy.copyWith(
        name: 'Custom',
        blurSigma: 42.0,
      );
      expect(custom.name, 'Custom');
      expect(custom.blurSigma, 42.0);
      expect(custom.tintColor, LitchiFlavour.dewy.tintColor);
    });
  });

  group('LitchiGlass widget', () {
    testWidgets('renders child content with blur enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LitchiGlass(
              flavour: LitchiFlavour.juicy,
              child: Text('Lychee Pulp'),
            ),
          ),
        ),
      );

      expect(find.text('Lychee Pulp'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('renders fallback without BackdropFilter when enableBlur is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LitchiGlass(
              flavour: LitchiFlavour.juicy,
              enableBlur: false,
              child: Text('Performance Mode'),
            ),
          ),
        ),
      );

      expect(find.text('Performance Mode'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  group('LitchiCard widget', () {
    testWidgets('renders child and responds to tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiCard(
              flavour: LitchiFlavour.dewy,
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('LitchiButton widget', () {
    testWidgets('executes onPressed callback when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LitchiButton(
                onPressed: () => pressed = true,
                child: const Text('Drink Litchi'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Drink Litchi'), findsOneWidget);
      await tester.tap(find.text('Drink Litchi'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
  });
}
