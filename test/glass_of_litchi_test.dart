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

  group('Apple Squircle Continuous Curvature', () {
    test('SquirclePath.create generates valid continuous path for G2 smoothing', () {
      const rect = Rect.fromLTWH(0, 0, 200, 100);
      final borderRadius = BorderRadius.circular(24.0);

      // Smoothing = 0.0 (Circular RRect)
      final rrectPath = SquirclePath.create(
        rect: rect,
        borderRadius: borderRadius,
        smoothing: 0.0,
      );
      expect(rrectPath, isNotNull);

      // Smoothing = 0.6 (Apple G2 Continuous Squircle)
      final squirclePath = SquirclePath.create(
        rect: rect,
        borderRadius: borderRadius,
        smoothing: 0.6,
      );
      expect(squirclePath, isNotNull);
      expect(squirclePath.computeMetrics().isNotEmpty, isTrue);
    });

    test('SquircleClipper clips correctly and detects rebuild needs', () {
      final clipper = SquircleClipper(
        borderRadius: BorderRadius.circular(16.0),
        smoothing: 0.6,
      );
      final clip = clipper.getClip(const Size(150, 80));
      expect(clip, isNotNull);

      final sameClipper = SquircleClipper(
        borderRadius: BorderRadius.circular(16.0),
        smoothing: 0.6,
      );
      expect(clipper.shouldReclip(sameClipper), isFalse);

      final diffClipper = SquircleClipper(
        borderRadius: BorderRadius.circular(24.0),
        smoothing: 0.8,
      );
      expect(clipper.shouldReclip(diffClipper), isTrue);
    });
  });

  group('LitchiScope 1-Pass Batching & Ambient Lighting', () {
    testWidgets('LitchiScope coordinates batchBlur and disables child BackdropFilter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiScope(
              batchBlur: true,
              lightAngle: 45.0,
              cornerSmoothing: 0.8,
              child: LitchiGlass(
                child: const Text('Batched Glass Child'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Batched Glass Child'), findsOneWidget);
      // Under batchBlur: true, child does NOT spawn an independent BackdropFilter, saving GPU passes
      expect(find.byType(BackdropFilter), findsNothing);
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
    testWidgets('renders and handles tap with tactile spring feedback', (tester) async {
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
              cornerSmoothing: 0.6,
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
                cornerSmoothing: 0.6,
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
