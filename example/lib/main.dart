import 'package:flutter/material.dart';
import 'package:glass_of_litchi/glass_of_litchi.dart';

void main() {
  runApp(const GlassOfLitchiDemoApp());
}

class GlassOfLitchiDemoApp extends StatelessWidget {
  const GlassOfLitchiDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glass of Litchi - Figma Glass Inspector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFFF537A),
        useMaterial3: true,
      ),
      home: const LitchiShowcaseScreen(),
    );
  }
}

class LitchiShowcaseScreen extends StatefulWidget {
  const LitchiShowcaseScreen({super.key});

  @override
  State<LitchiShowcaseScreen> createState() => _LitchiShowcaseScreenState();
}

class _LitchiShowcaseScreenState extends State<LitchiShowcaseScreen> {
  LitchiFlavour _selectedFlavour = LitchiFlavour.juicy;

  // Figma 7 Glass Parameters
  double _lightAngle = 135.0;
  double _lightPercent = 85.0;
  double _refraction = 25.0;
  double _depth = 10.0;
  double _dispersion = 35.0;
  double _frost = 26.0;
  double _splay = 50.0;

  bool _enableBlur = true;
  int _counter = 0;

  final List<LitchiFlavour> _flavours = const [
    LitchiFlavour.dewy,
    LitchiFlavour.juicy,
    LitchiFlavour.frosted,
    LitchiFlavour.crystal,
    LitchiFlavour.milkyLitchi,
    LitchiFlavour.roseTint,
    LitchiFlavour.goldenCitrus,
  ];

  void _applyFlavour(LitchiFlavour flavour) {
    setState(() {
      _selectedFlavour = flavour;
      _lightAngle = flavour.lightAngle;
      _lightPercent = flavour.lightPercent;
      _refraction = flavour.refraction;
      _depth = flavour.depth;
      _dispersion = flavour.dispersion;
      _frost = flavour.frost;
      _splay = flavour.splay;
    });
  }

  String _getAngleLabel(double angle) {
    final norm = (angle % 360 + 360) % 360;
    if (norm >= 115 && norm <= 155) return 'Top-Left ↘ Bottom-Right';
    if (norm >= 25 && norm <= 65) return 'Bottom-Left ↗ Top-Right';
    if (norm >= 160 && norm <= 200) return 'Top ↓ Bottom';
    if (norm >= 70 && norm <= 110) return 'Left → Right';
    if (norm >= 295 && norm <= 335) return 'Bottom-Right ↖ Top-Left';
    if (norm >= 250 && norm <= 290) return 'Right ← Left';
    if (norm >= 340 || norm <= 20) return 'Bottom ↑ Top';
    return '${norm.round()}° Custom';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Vibrant organic fruit mesh background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A0818),
                  Color(0xFF5A1030),
                  Color(0xFFFF3366),
                  Color(0xFFFF8E53),
                  Color(0xFF1B072B),
                ],
                stops: [0.0, 0.25, 0.55, 0.8, 1.0],
              ),
            ),
          ),

          // Floating glowing neon fruit orbs for live refraction testing
          Positioned(
            top: 100,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFFF5E97), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            right: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFFFB300), Colors.transparent],
                ),
              ),
            ),
          ),

          // Main interactive content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          '🍹 Glass of Litchi',
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          'Figma 1:1 Glass Effect Inspector',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // Flavour selector chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _flavours.map((flavour) {
                        final isSelected = _selectedFlavour.name == flavour.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(flavour.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                _applyFlavour(flavour);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // Hero Glass Card with Figma Parameters
                  LitchiCard(
                    flavour: _selectedFlavour,
                    lightAngle: _lightAngle,
                    lightPercent: _lightPercent,
                    refraction: _refraction,
                    depth: _depth,
                    dispersion: _dispersion,
                    frost: _frost,
                    splay: _splay,
                    enableBlur: _enableBlur,
                    onTap: () {
                      setState(() {
                        _counter++;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 6.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                _selectedFlavour.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                if (_dispersion > 15)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6.0),
                                    child: Icon(
                                      Icons.looks,
                                      size: 16.0,
                                      color: Color(0xFF64FFDA),
                                    ),
                                  ),
                                Text(
                                  '${_lightAngle.round()}° / ${_lightPercent.round()}%',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Figma Optical Glass',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Dispersion (${_dispersion.round()}%) creates chromatic rainbow edge fringing. Refraction (${_refraction.round()}%) bends inner rim light. Depth (${_depth.round()}px) casts directional 3D shadow.',
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18.0),
                        Row(
                          children: [
                            Text(
                              'Interactions: $_counter',
                              style: const TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            LitchiButton(
                              flavour: _selectedFlavour,
                              lightAngle: _lightAngle,
                              lightPercent: _lightPercent,
                              refraction: _refraction,
                              depth: _depth,
                              dispersion: _dispersion,
                              frost: _frost,
                              splay: _splay,
                              enableBlur: _enableBlur,
                              onPressed: () {
                                setState(() {
                                  _counter += 5;
                                });
                              },
                              child: const Text('Taste Litchi'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Figma Parameters Inspector Card
                  LitchiCard(
                    flavour: LitchiFlavour.frosted,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '🎨 Figma Glass Inspector',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Icon(Icons.tune, size: 20.0, color: Colors.white70),
                          ],
                        ),
                        const SizedBox(height: 16.0),

                        // 1. Light Angle
                        _buildSliderRow(
                          label: 'Light Angle',
                          valueText: '${_lightAngle.round()}° (${_getAngleLabel(_lightAngle)})',
                          value: _lightAngle,
                          min: 0.0,
                          max: 360.0,
                          divisions: 72,
                          onChanged: (val) => setState(() => _lightAngle = val),
                        ),

                        // 2. Light Percent
                        _buildSliderRow(
                          label: 'Light Percent',
                          valueText: '${_lightPercent.round()}% (Brightness)',
                          value: _lightPercent,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (val) => setState(() => _lightPercent = val),
                        ),

                        // 3. Refraction
                        _buildSliderRow(
                          label: 'Refraction',
                          valueText: '${_refraction.round()}% (Inner Bevel)',
                          value: _refraction,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (val) => setState(() => _refraction = val),
                        ),

                        // 4. Depth
                        _buildSliderRow(
                          label: 'Depth',
                          valueText: '${_depth.toStringAsFixed(1)} px (3D Slab)',
                          value: _depth,
                          min: 0.0,
                          max: 30.0,
                          onChanged: (val) => setState(() => _depth = val),
                        ),

                        // 5. Dispersion
                        _buildSliderRow(
                          label: 'Dispersion',
                          valueText: '${_dispersion.round()}% (Rainbow Rim)',
                          value: _dispersion,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (val) => setState(() => _dispersion = val),
                        ),

                        // 6. Frost
                        _buildSliderRow(
                          label: 'Frost',
                          valueText: '${_frost.round()}% (Matte Blur)',
                          value: _frost,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (val) => setState(() => _frost = val),
                        ),

                        // 7. Splay
                        _buildSliderRow(
                          label: 'Splay',
                          valueText: '${_splay.round()}% (Highlight Arc)',
                          value: _splay,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (val) => setState(() => _splay = val),
                        ),

                        const Divider(height: 28.0, color: Colors.white24),

                        // Generated Figma Code snippet
                        const Text(
                          'Generated Figma-to-Dart Code:',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: SelectableText(
                            'LitchiCard.fromFigma(\n'
                            '  lightAngle: ${_lightAngle.round()}.0,\n'
                            '  lightPercent: ${_lightPercent.round()}.0,\n'
                            '  refraction: ${_refraction.round()}.0,\n'
                            '  depth: ${_depth.round()}.0,\n'
                            '  dispersion: ${_dispersion.round()}.0,\n'
                            '  frost: ${_frost.round()}.0,\n'
                            '  splay: ${_splay.round()}.0,\n'
                            '  child: ...,\n'
                            ')',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12.0,
                              color: Color(0xFF64FFDA),
                              height: 1.4,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12.0),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Hardware Backdrop Blur'),
                          subtitle: const Text(
                            'Turn off to test zero-cost fallback mode',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          value: _enableBlur,
                          onChanged: (val) {
                            setState(() {
                              _enableBlur = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.0)),
            Text(valueText, style: const TextStyle(fontSize: 12.0, color: Colors.white70)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
