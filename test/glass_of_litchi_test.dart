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

      expect(gradient.stops?.length, 6);
      expect(gradient.colors.length, 6);
    });
  });

  group('Apple Squircle Continuous Curvature & Memoization', () {
    test('SquirclePath.create generates valid continuous path and caches results', () {
      const rect = Rect.fromLTWH(0, 0, 200, 100);
      final borderRadius = BorderRadius.circular(24.0);

      final rrectPath = SquirclePath.create(
        rect: rect,
        borderRadius: borderRadius,
        smoothing: 0.0,
      );
      expect(rrectPath, isNotNull);

      final squirclePath1 = SquirclePath.create(
        rect: rect,
        borderRadius: borderRadius,
        smoothing: 0.6,
      );
      final squirclePath2 = SquirclePath.create(
        rect: rect,
        borderRadius: borderRadius,
        smoothing: 0.6,
      );
      expect(squirclePath1, isNotNull);
      // Memoized cache returns same Path reference
      expect(identical(squirclePath1, squirclePath2), isTrue);
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

  group('LitchiScope liteMode & Ambient Lighting', () {
    testWidgets('LitchiScope coordinates liteMode and disables child BackdropFilter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiScope(
              liteMode: true,
              lightAngle: 45.0,
              cornerSmoothing: 0.8,
              child: LitchiGlass(
                child: const Text('Lite Glass Child'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Lite Glass Child'), findsOneWidget);
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

  group('LitchiCard widget with tactile feedback', () {
    testWidgets('renders, tracks drag tilt and handles tap with Figma properties', (tester) async {
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

  group('LitchiTabBar signature floating glass navigation', () {
    testWidgets('renders items and handles tab switching with spring pill', (tester) async {
      var activeIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return LitchiTabBar(
                  selectedIndex: activeIndex,
                  onTabSelected: (index) {
                    setState(() => activeIndex = index);
                  },
                  items: const [
                    LitchiTabItem(icon: Icons.home, label: 'Home'),
                    LitchiTabItem(icon: Icons.search, label: 'Search'),
                    LitchiTabItem(icon: Icons.person, label: 'Profile'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(activeIndex, 1);
    });
  });
}
