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
      title: 'Glass of Litchi Demo',
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
  double _customBlur = 22.0;
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

          // Organic decorative floating glowing spheres
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
            bottom: 120,
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
                          'Dewy, organic glass UI kit for Flutter',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24.0),

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
                                setState(() {
                                  _selectedFlavour = flavour;
                                  _customBlur = flavour.blurSigma;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Hero Glass Card
                  LitchiCard(
                    flavour: _selectedFlavour,
                    blur: _customBlur,
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
                            const Icon(
                              Icons.auto_awesome,
                              color: Colors.white70,
                              size: 20.0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18.0),
                        const Text(
                          'Artisanal Dewy Glass',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Tactile, organic glass with dual specular edge gradients and ambient fruit tinting. Tap this card to feel interactive spring physics.',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20.0),
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
                              enableBlur: _enableBlur,
                              onPressed: () {
                                setState(() {
                                  _counter += 5;
                                });
                              },
                              child: const Text('Drink +5'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Controls Panel
                  LitchiCard(
                    flavour: LitchiFlavour.frosted,
                    enableBlur: _enableBlur,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Tuning & Controls',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Backdrop Blur'),
                            Text('${_customBlur.toStringAsFixed(1)} px'),
                          ],
                        ),
                        Slider(
                          value: _customBlur,
                          min: 0.0,
                          max: 40.0,
                          onChanged: _enableBlur
                              ? (val) {
                                  setState(() {
                                    _customBlur = val;
                                  });
                                }
                              : null,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Enable Gaussian Blur'),
                          subtitle: const Text(
                            'Toggle off for high-FPS fallback mode on low-end hardware',
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
}
