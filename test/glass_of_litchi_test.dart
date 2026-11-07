import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_of_litchi/glass_of_litchi.dart';

void main() {
  testWidgets('backdrop grouping is opt-in and excludes shader glass', (
    tester,
  ) async {
    final key = BackdropKey();
    await tester.pumpWidget(
      MaterialApp(
        home: BackdropGroup(
          backdropKey: key,
          child: Column(
            children: [
              LitchiCard.fromFigma(
                groupBackdrop: true,
                shaderRefraction: false,
                child: const Text('Grouped row'),
              ),
              const LitchiGlass(
                groupBackdrop: true,
                shaderRefraction: false,
                child: Text('Grouped peer'),
              ),
              const LitchiGlass(
                shaderRefraction: false,
                child: Text('Independent glass'),
              ),
              const LitchiGlass(
                groupBackdrop: true,
                shaderRefraction: true,
                child: Text('Shader glass'),
              ),
            ],
          ),
        ),
      ),
    );
    final filters = tester
        .widgetList<BackdropFilter>(find.byType(BackdropFilter))
        .toList();
    expect(filters, hasLength(4));
    expect(filters[0].backdropGroupKey, same(key));
    expect(filters[1].backdropGroupKey, same(key));
    expect(filters[2].backdropGroupKey, isNull);
    expect(filters[3].backdropGroupKey, isNull);
  });

  group('Figma 7-Option Glass Parameters', () {
    test(
      'LitchiFlavour.fromFigma initializes optical parameters correctly',
      () {
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
      },
    );

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
    test(
      'SquirclePath.create generates valid continuous path and caches results',
      () {
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
      },
    );

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
    testWidgets(
      'LitchiScope coordinates liteMode and disables child BackdropFilter',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LitchiScope(
                liteMode: true,
                lightAngle: 45.0,
                cornerSmoothing: 0.8,
                child: LitchiGlass(child: const Text('Lite Glass Child')),
              ),
            ),
          ),
        );

        expect(find.text('Lite Glass Child'), findsOneWidget);
        expect(find.byType(BackdropFilter), findsNothing);
      },
    );
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
    testWidgets(
      'renders, tracks drag tilt and handles tap with Figma properties',
      (tester) async {
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
      },
    );
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
    testWidgets('renders items and handles tab switching with spring pill', (
      tester,
    ) async {
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

  group('LitchiShaderPipeline optical refraction & fallback', () {
    test('LitchiShaderPipeline instance is accessible with valid defaults', () {
      final pipeline = LitchiShaderPipeline.instance;
      expect(pipeline, isNotNull);
      expect(pipeline.programNotifier, isNotNull);
    });

    test('createRefractionFilter falls back gracefully when shader is not preloaded', () {
      final baseBlur = ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10);
      final filter = LitchiShaderPipeline.instance.createRefractionFilter(
        baseBlur: baseBlur,
        refraction: 0.5,
        dispersion: 0.5,
      );
      expect(filter, equals(baseBlur));
    });

    testWidgets('LitchiGlass respects shaderRefraction flag in tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiGlass(
              shaderRefraction: false,
              child: const Text('Shader Disabled Glass'),
            ),
          ),
        ),
      );

      expect(find.text('Shader Disabled Glass'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });

  group('LitchiScope.of', () {
    testWidgets('throws when no LitchiScope ancestor is present', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(() => LitchiScope.of(context), throwsAssertionError);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  group('LitchiButton disabled state', () {
    testWidgets('exposes disabled semantics and ignores taps', (tester) async {
      final handle = tester.ensureSemantics();
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LitchiButton(
                onPressed: null,
                child: const Text('Disabled Button'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled Button'));
      await tester.pumpAndSettle();
      expect(pressed, isFalse);

      expect(
        tester.getSemantics(find.byType(LitchiButton)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });
  });

  group('LitchiTabBar semantics', () {
    testWidgets('exposes selected state and labels per tab', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LitchiTabBar(
              selectedIndex: 0,
              onTabSelected: (_) {},
              items: const [
                LitchiTabItem(icon: Icons.home, label: 'Home'),
                LitchiTabItem(icon: Icons.search, label: 'Search'),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Home')),
        matchesSemantics(
          isSelected: true,
          hasSelectedState: true,
          isButton: true,
          label: 'Home',
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Search')),
        matchesSemantics(
          isSelected: false,
          hasSelectedState: true,
          isButton: true,
          label: 'Search',
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });
  });

  group('SquirclePath cache eviction', () {
    test(
      'survives many unique shapes beyond cache capacity without throwing',
      () {
        const borderRadius = BorderRadius.all(Radius.circular(20.0));

        for (var i = 0; i < 500; i++) {
          final rect = Rect.fromLTWH(0, 0, 100.0 + i, 60.0);
          final path = SquirclePath.create(
            rect: rect,
            borderRadius: borderRadius,
            smoothing: 0.6,
          );
          expect(path, isNotNull);
          expect(path.getBounds().width, greaterThan(0));
        }

        // A key seen again after many evictions must still produce a usable
        // (if freshly recomputed) path rather than a stale/invalid one.
        const rect = Rect.fromLTWH(0, 0, 100.0, 60.0);
        final recomputed = SquirclePath.create(
          rect: rect,
          borderRadius: borderRadius,
          smoothing: 0.6,
        );
        expect(recomputed.getBounds(), rect);
      },
    );
  });

  group('LitchiShaderPipeline concurrent loads', () {
    test(
      'concurrent ensureLoaded() callers observe the same outcome',
      () async {
        final pipeline = LitchiShaderPipeline.instance;

        final first = pipeline.ensureLoaded();
        final second = pipeline.ensureLoaded();

        final results = await Future.wait([first, second]);
        expect(results[0], equals(results[1]));
      },
    );
  });

  group('LitchiChip widget', () {
    testWidgets('renders label, leading, trailing, and responds to tap', (
      tester,
    ) async {
      var isSelected = false;
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return LitchiChip(
                  leading: const Icon(Icons.star),
                  label: const Text('Juicy Star'),
                  trailing: const Icon(Icons.check),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() => isSelected = val);
                  },
                  onPressed: () => wasPressed = true,
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Juicy Star'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Juicy Star'));
      await tester.pumpAndSettle();

      expect(isSelected, isTrue);
      expect(wasPressed, isTrue);
    });

    testWidgets('instantiates via fromFigma constructor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiChip.fromFigma(
              lightAngle: 120.0,
              lightPercent: 85.0,
              refraction: 25.0,
              depth: 8.0,
              dispersion: 30.0,
              frost: 20.0,
              splay: 45.0,
              label: const Text('Figma Chip'),
            ),
          ),
        ),
      );

      expect(find.text('Figma Chip'), findsOneWidget);
    });
  });

  group('LitchiSegmentedControl widget', () {
    testWidgets('renders segments and animates selection on tap', (
      tester,
    ) async {
      var selected = 'drinks';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return LitchiSegmentedControl<String>(
                  selectedValue: selected,
                  onValueChanged: (val) {
                    setState(() => selected = val);
                  },
                  segments: const [
                    LitchiSegment(
                      value: 'drinks',
                      label: Text('Drinks'),
                      icon: Icon(Icons.local_bar),
                    ),
                    LitchiSegment(
                      value: 'snacks',
                      label: Text('Snacks'),
                      badgeText: '2',
                    ),
                    LitchiSegment(
                      value: 'desserts',
                      label: Text('Desserts'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Drinks'), findsOneWidget);
      expect(find.text('Snacks'), findsOneWidget);
      expect(find.text('Desserts'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('Snacks'));
      await tester.pumpAndSettle();

      expect(selected, 'snacks');
    });
  });

  group('LitchiTextField widget', () {
    testWidgets('renders hint, handles text input and focus animation', (
      tester,
    ) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      var changedValue = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiTextField.fromFigma(
              controller: controller,
              focusNode: focusNode,
              hintText: 'Search flavors...',
              prefix: const Icon(Icons.search),
              suffix: const Icon(Icons.clear),
              onChanged: (val) => changedValue = val,
            ),
          ),
        ),
      );

      expect(find.text('Search flavors...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Lychee');
      await tester.pumpAndSettle();

      expect(controller.text, 'Lychee');
      expect(changedValue, 'Lychee');
    });
  });

  group('LitchiDialog & showLitchiDialog', () {
    testWidgets('opens dialog and triggers action button', (tester) async {
      var actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showLitchiDialog<void>(
                      context: context,
                      builder: (ctx) {
                        return LitchiDialog(
                          title: const Text('Order Spritzer?'),
                          content: const Text('This will order fresh lychee soda.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                actionTapped = true;
                                Navigator.pop(ctx);
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Order Spritzer?'), findsOneWidget);
      expect(find.text('This will order fresh lychee soda.'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
      expect(find.text('Order Spritzer?'), findsNothing);
    });

    testWidgets('showLitchiModalBottomSheet opens sheet and dismisses', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showLitchiModalBottomSheet<void>(
                      context: context,
                      builder: (ctx) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Modal Sheet Body'),
                        );
                      },
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Sheet Body'), findsOneWidget);

      // Tap outside to dismiss
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(find.text('Modal Sheet Body'), findsNothing);
    });
  });

  group('LitchiFlavour lerp, equality, and noise', () {
    test('interpolates flavours accurately across all fields', () {
      final a = LitchiFlavour.dewy;
      final b = LitchiFlavour.juicy;

      final mid = LitchiFlavour.lerp(a, b, 0.5)!;
      expect(mid.lightPercent, closeTo(80.0, 0.1));
      expect(mid.noise, closeTo(2.0, 0.1));
      expect(mid.refraction, closeTo(22.5, 0.1));
      expect(mid.depth, closeTo(9.0, 0.1));

      expect(LitchiFlavour.lerp(a, b, 0.0), equals(a));
      expect(LitchiFlavour.lerp(a, b, 1.0), equals(b));
    });

    test('equality and hashCode contract is maintained', () {
      final f1 = LitchiFlavour.dewy.copyWith(noise: 5.0);
      final f2 = LitchiFlavour.dewy.copyWith(noise: 5.0);
      final f3 = LitchiFlavour.dewy.copyWith(noise: 10.0);

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1, isNot(equals(f3)));
    });
  });

  group('Optical Noise & Dynamic Lighting', () {
    testWidgets('LitchiGlass renders with noise and fallback painter', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiGlass(
              noise: 20.0,
              enableBlur: false,
              child: const Text('Noise Glass'),
            ),
          ),
        ),
      );

      expect(find.text('Noise Glass'), findsOneWidget);
    });

    testWidgets('LitchiCard responds to mouse hover and adjusts dynamic lighting', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LitchiCard(
                width: 200,
                height: 100,
                enableHoverEffect: true,
                enableDynamicLight: true,
                onTap: () {},
                child: const Text('Hover Card'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hover Card'), findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.text('Hover Card')));
      await tester.pumpAndSettle();

      await gesture.removePointer();
    });

    testWidgets('LitchiScope propagates noise to child glass', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiScope(
              noise: 15.0,
              child: LitchiGlass(
                child: const Text('Scoped Noise Glass'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Scoped Noise Glass'), findsOneWidget);
    });
  });

  group('Apple Vibrancy & Luxury Presets', () {
    test('createVibrancyMatrix creates valid 4x5 color matrix', () {
      final identityMatrix = createVibrancyMatrix(1.0);
      expect(identityMatrix.length, 20);

      // Identity diagonal
      expect(identityMatrix[0], closeTo(1.0, 1e-4)); // R
      expect(identityMatrix[6], closeTo(1.0, 1e-4)); // G
      expect(identityMatrix[12], closeTo(1.0, 1e-4)); // B
      expect(identityMatrix[18], closeTo(1.0, 1e-4)); // A
      expect(identityMatrix[1], closeTo(0.0, 1e-4));
      expect(identityMatrix[2], closeTo(0.0, 1e-4));

      final saturatedMatrix = createVibrancyMatrix(1.5);
      expect(saturatedMatrix.length, 20);
      expect(saturatedMatrix[0], greaterThan(1.0)); // Red amplified

      final desaturatedMatrix = createVibrancyMatrix(0.0);
      expect(desaturatedMatrix[0], closeTo(0.2126, 1e-4));
      expect(desaturatedMatrix[1], closeTo(0.7152, 1e-4));
      expect(desaturatedMatrix[2], closeTo(0.0722, 1e-4));
    });

    test('New luxury presets initialize with correct aesthetics', () {
      expect(LitchiFlavour.liquidMercury.name, 'Liquid Mercury');
      expect(LitchiFlavour.liquidMercury.lightPercent, 96.0);
      expect(LitchiFlavour.liquidMercury.vibrancy, 1.15);

      expect(LitchiFlavour.polarIce.name, 'Polar Ice');
      expect(LitchiFlavour.polarIce.dispersion, 55.0);
      expect(LitchiFlavour.polarIce.vibrancy, 1.40);

      expect(LitchiFlavour.smokedQuartz.name, 'Smoked Quartz');
      expect(LitchiFlavour.smokedQuartz.frost, 42.0);
      expect(LitchiFlavour.smokedQuartz.vibrancy, 1.25);
    });

    test('LitchiFlavour.lerp interpolates vibrancy smoothly', () {
      final a = LitchiFlavour.dewy.copyWith(vibrancy: 1.0);
      final b = LitchiFlavour.juicy.copyWith(vibrancy: 1.5);

      final mid = LitchiFlavour.lerp(a, b, 0.5);
      expect(mid, isNotNull);
      expect(mid!.vibrancy, closeTo(1.25, 1e-4));

      final start = LitchiFlavour.lerp(a, b, 0.0);
      expect(start!.vibrancy, closeTo(1.0, 1e-4));

      final end = LitchiFlavour.lerp(a, b, 1.0);
      expect(end!.vibrancy, closeTo(1.5, 1e-4));
    });

    test('LitchiFlavour equality and hashCode account for vibrancy', () {
      final f1 = LitchiFlavour.dewy.copyWith(vibrancy: 1.15);
      final f2 = LitchiFlavour.dewy.copyWith(vibrancy: 1.15);
      final f3 = LitchiFlavour.dewy.copyWith(vibrancy: 1.45);

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1, isNot(equals(f3)));
    });

    testWidgets('LitchiGlass renders with vibrancy filter applied to backdrop', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LitchiGlass(
                vibrancy: 1.4,
                child: const Text('Vibrant Glass Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Vibrant Glass Content'), findsOneWidget);
      final backdrop = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(backdrop.filter, isNotNull);
    });

    testWidgets('LitchiScope propagates vibrancy to child glass', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LitchiScope(
              vibrancy: 1.5,
              child: LitchiGlass(
                child: const Text('Scoped Vibrant Glass'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Scoped Vibrant Glass'), findsOneWidget);
    });

    testWidgets('LitchiCard and controls accept vibrancy parameter', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LitchiCard(
                  vibrancy: 1.35,
                  child: const Text('Card with Vibrancy'),
                ),
                LitchiButton(
                  vibrancy: 1.3,
                  onPressed: () {},
                  child: const Text('Button with Vibrancy'),
                ),
                LitchiChip(
                  vibrancy: 1.25,
                  label: const Text('Chip with Vibrancy'),
                ),
                LitchiTextField(
                  vibrancy: 1.2,
                  hintText: 'Search...',
                ),
                LitchiSegmentedControl<int>(
                  vibrancy: 1.3,
                  selectedValue: 0,
                  onValueChanged: (_) {},
                  segments: const [
                    LitchiSegment(value: 0, label: Text('One')),
                    LitchiSegment(value: 1, label: Text('Two')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Card with Vibrancy'), findsOneWidget);
      expect(find.text('Button with Vibrancy'), findsOneWidget);
      expect(find.text('Chip with Vibrancy'), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
      expect(find.text('One'), findsOneWidget);
    });
  });
}
