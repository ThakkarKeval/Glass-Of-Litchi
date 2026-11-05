import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_of_litchi/glass_of_litchi.dart';

void main() {
  group('Figma 7-Option Glass Parameters', () {
    test('LitchiFlavour.fromFigma initializes optical parameters correctly', () {
      final figmaFlavour = LitchiFlavour.fromFigma(
        lightAngle: 120.0,
        lightPercent: 90.0,
        refraction: 30.0,
        depth: 12.0,
        dispersion: 40.0,
        frost: 35.0,
        splay: 60.0,
      );

      expect(figmaFlavour.lightAngle, 120.0);
      expect(figmaFlavour.lightPercent, 90.0);
      expect(figmaFlavour.refraction, 30.0);
      expect(figmaFlavour.depth, 12.0);
      expect(figmaFlavour.dispersion, 40.0);
      expect(figmaFlavour.frost, 35.0);
      expect(figmaFlavour.splay, 60.0);
      expect(figmaFlavour.blurSigma, closeTo(14.0, 0.1));
      expect(figmaFlavour.specularOpacity, 0.9);
    });

    test('createSpecularBorderGradient generates dispersion rainbow stops', () {
      final gradient = createSpecularBorderGradient(
        angle: 135.0,
        lightPercent: 80.0,
        dispersion: 50.0,
        splay: 40.0,
      );

      // Chromatic dispersion creates 6 prismatic stops (cyan lead, white core, rose trail, bounce)
      expect(gradient.stops?.length, 6);
      expect(gradient.colors.length, 6);
    });
  });

  group('LitchiGlass widget with Figma properties', () {
    testWidgets('renders child content with Figma factory', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiGlass.fromFigma(
              lightAngle: 135.0,
              lightPercent: 80.0,
              refraction: 25.0,
              depth: 10.0,
              dispersion: 30.0,
              frost: 20.0,
              splay: 45.0,
              child: const Text('Figma Glass Child'),
            ),
          ),
        ),
      );

      expect(find.text('Figma Glass Child'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });

  group('LitchiCard widget with fromFigma factory', () {
    testWidgets('renders and handles tap with Figma properties', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiCard.fromFigma(
              lightAngle: 135.0,
              lightPercent: 85.0,
              refraction: 20.0,
              depth: 8.0,
              dispersion: 25.0,
              frost: 25.0,
              splay: 40.0,
              onTap: () => tapped = true,
              child: const Text('Figma Card Tap'),
            ),
          ),
        ),
      );

      expect(find.text('Figma Card Tap'), findsOneWidget);
      await tester.tap(find.text('Figma Card Tap'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('LitchiButton widget with fromFigma factory', () {
    testWidgets('executes onPressed callback when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LitchiButton.fromFigma(
                lightAngle: 135.0,
                lightPercent: 90.0,
                refraction: 20.0,
                depth: 6.0,
                dispersion: 20.0,
                frost: 20.0,
                splay: 40.0,
                onPressed: () => pressed = true,
                child: const Text('Figma Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Figma Button'), findsOneWidget);
      await tester.tap(find.text('Figma Button'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
  });
}
