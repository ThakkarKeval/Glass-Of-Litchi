import 'package:flutter/material.dart';
import 'package:glass_of_litchi/glass_of_litchi.dart';

class _CategoryData {
  final String id;
  final String label;
  final IconData icon;
  final LitchiFlavour flavour;

  const _CategoryData({
    required this.id,
    required this.label,
    required this.icon,
    required this.flavour,
  });
}

class _MenuItem {
  final String title;
  final String subtitle;
  final String categoryId;
  final LitchiFlavour flavour;
  final String price;
  final IconData icon;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.categoryId,
    required this.flavour,
    required this.price,
    required this.icon,
  });
}

/// A showcase screen demonstrating a rich, scrollable list of views
/// styled with the **Glass of Litchi** design system.
/// Uses [ClampingScrollPhysics] to prevent edge-scroll overdraw flickering.
class GlassListScreen extends StatefulWidget {
  const GlassListScreen({super.key});

  @override
  State<GlassListScreen> createState() => _GlassListScreenState();
}

class _GlassListScreenState extends State<GlassListScreen> {
  String _selectedCategoryId = 'All';
  bool _isPlaying = true;
  double _volume = 0.7;

  final List<_CategoryData> _categories = const [
    _CategoryData(
      id: 'All',
      label: 'All Drinks',
      icon: Icons.auto_awesome,
      flavour: LitchiFlavour.dewy,
    ),
    _CategoryData(
      id: 'Juicy',
      label: 'Juicy Pulp',
      icon: Icons.water_drop_rounded,
      flavour: LitchiFlavour.juicy,
    ),
    _CategoryData(
      id: 'Frosted',
      label: 'Frosted Dew',
      icon: Icons.ac_unit_rounded,
      flavour: LitchiFlavour.frosted,
    ),
    _CategoryData(
      id: 'Crystal',
      label: 'Crystal Glaze',
      icon: Icons.diamond_outlined,
      flavour: LitchiFlavour.crystal,
    ),
    _CategoryData(
      id: 'Desserts',
      label: 'Milky Treats',
      icon: Icons.icecream_outlined,
      flavour: LitchiFlavour.milkyLitchi,
    ),
    _CategoryData(
      id: 'Rose',
      label: 'Rose Petal',
      icon: Icons.spa_rounded,
      flavour: LitchiFlavour.roseTint,
    ),
    _CategoryData(
      id: 'Citrus',
      label: 'Golden Citrus',
      icon: Icons.wb_sunny_rounded,
      flavour: LitchiFlavour.goldenCitrus,
    ),
  ];

  final List<_MenuItem> _allMenuItems = const [
    _MenuItem(
      title: 'Milky Litchi Tapioca',
      subtitle: 'Creamy condensed coconut milk, fresh lychee balls',
      categoryId: 'Desserts',
      flavour: LitchiFlavour.milkyLitchi,
      price: '\$6.20',
      icon: Icons.bubble_chart,
    ),
    _MenuItem(
      title: 'Juicy Lychee Fizz',
      subtitle: 'Crushed pink litchi fruit, sparkling botanical soda',
      categoryId: 'Juicy',
      flavour: LitchiFlavour.juicy,
      price: '\$6.50',
      icon: Icons.local_bar,
    ),
    _MenuItem(
      title: 'Frosted Matcha Dew',
      subtitle: 'Ceremonial Uji green tea over clear cracked glass ice',
      categoryId: 'Frosted',
      flavour: LitchiFlavour.frosted,
      price: '\$7.00',
      icon: Icons.eco,
    ),
    _MenuItem(
      title: 'Crystal Glacier Tonic',
      subtitle: 'Ultra-clarified citrus blossom with mountain ice',
      categoryId: 'Crystal',
      flavour: LitchiFlavour.crystal,
      price: '\$6.80',
      icon: Icons.ac_unit,
    ),
    _MenuItem(
      title: 'Rose Petal Infusion',
      subtitle: 'Organic Damask rose elixir with sparkling mineral water',
      categoryId: 'Rose',
      flavour: LitchiFlavour.roseTint,
      price: '\$7.50',
      icon: Icons.spa,
    ),
    _MenuItem(
      title: 'Golden Yuzu Fizz',
      subtitle: 'Japanese wild citrus glaze and effervescent nectar',
      categoryId: 'Citrus',
      flavour: LitchiFlavour.goldenCitrus,
      price: '\$7.20',
      icon: Icons.wb_sunny,
    ),
  ];

  List<_MenuItem> get _filteredMenuItems {
    if (_selectedCategoryId == 'All') return _allMenuItems;
    return _allMenuItems
        .where((item) => item.categoryId == _selectedCategoryId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Sophisticated luxury dark ambient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F0B13),
                  Color(0xFF140D1C),
                  Color(0xFF191124),
                  Color(0xFF0D0A12),
                ],
                stops: [0.0, 0.35, 0.70, 1.0],
              ),
            ),
          ),

          // Soft elegant ambient light blooms (luxurious, non-clashing)
          Positioned(
            top: 40,
            left: -30,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x66B0305C), // Warm dusty litchi rose glow
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.75],
                ),
              ),
            ),
          ),
          Positioned(
            top: 380,
            right: -50,
            child: Container(
              width: 340,
              height: 340,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x55994A2D), // Warm soft amber peach bloom
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.75],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -40,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x5544226E), // Deep elegant twilight violet glow
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.75],
                ),
              ),
            ),
          ),

          // Scrollable list of glass views with ClampingScrollPhysics (no bounce/flicker)
          SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                physics: const ClampingScrollPhysics(),
                overscroll: false,
              ),
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                // 1. Floating Glass App Bar / Search Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: LitchiGlass(
                            flavour: LitchiFlavour.dewy,
                            borderRadius: BorderRadius.circular(20.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.white70,
                                  size: 20.0,
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  'Search glass beverages...',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        LitchiCard(
                          flavour: LitchiFlavour.juicy,
                          borderRadius: BorderRadius.circular(16.0),
                          padding: const EdgeInsets.all(10.0),
                          elevation: 4.0,
                          onTap: () {},
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. High-Fidelity Glass Category Chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44.0,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10.0),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategoryId == cat.id;

                        return _buildGlassCategoryChip(cat, isSelected);
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

                // 3. Featured Hero Glass Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: LitchiCard.fromFigma(
                      lightAngle: 135.0,
                      lightPercent: 90.0,
                      refraction: 25.0,
                      depth: 12.0,
                      dispersion: 40.0,
                      frost: 26.0,
                      splay: 50.0,
                      tintColor: const Color(0x30FF3366),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Text(
                                  'FEATURED COCKTAIL',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const Row(
                                children: [
                                  Icon(Icons.star, color: Color(0xFFFFD700), size: 16.0),
                                  SizedBox(width: 4.0),
                                  Text(
                                    '4.9',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14.0),
                          const Text(
                            'Lychee Rose Spritzer',
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          const Text(
                            'Fresh litchi pulp, crushed rose petals, botanical tonic, and sparkling dewy frost.',
                            style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Price',
                                    style: TextStyle(fontSize: 11.0, color: Colors.white60),
                                  ),
                                  Text(
                                    '\$8.50',
                                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              LitchiButton.fromFigma(
                                lightAngle: 135.0,
                                lightPercent: 85.0,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ordered Lychee Rose Spritzer! 🍹'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.local_bar, size: 18.0),
                                    SizedBox(width: 6.0),
                                    Text('Order Drink'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

                // 4. Two-Column Glass Metrics
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: LitchiCard(
                            flavour: LitchiFlavour.crystal,
                            padding: const EdgeInsets.all(16.0),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.water_drop, color: Color(0xFF64FFDA), size: 24.0),
                                SizedBox(height: 10.0),
                                Text(
                                  '99.8%',
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'Dewy Purity',
                                  style: TextStyle(fontSize: 12.0, color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: LitchiCard(
                            flavour: LitchiFlavour.goldenCitrus,
                            padding: const EdgeInsets.all(16.0),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.bolt, color: Color(0xFFFFD54F), size: 24.0),
                                SizedBox(height: 10.0),
                                Text(
                                  '12.4k',
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'Active Sips',
                                  style: TextStyle(fontSize: 12.0, color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

                // 5. Glass Media Player Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: LitchiCard(
                      flavour: LitchiFlavour.frosted,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              LitchiGlass(
                                flavour: LitchiFlavour.juicy,
                                borderRadius: BorderRadius.circular(12.0),
                                padding: const EdgeInsets.all(12.0),
                                child: const Icon(
                                  Icons.graphic_eq,
                                  color: Colors.white,
                                  size: 22.0,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Litchi Lounge Lo-Fi',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2.0),
                                    Text(
                                      'Chill Beats to Code Glass UI',
                                      style: TextStyle(fontSize: 12.0, color: Colors.white60),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 38.0,
                                ),
                                onPressed: () => setState(() => _isPlaying = !_isPlaying),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                              trackHeight: 3.0,
                            ),
                            child: Slider(
                              value: _volume,
                              onChanged: (val) => setState(() => _volume = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

                // 6. Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategoryId == 'All'
                              ? 'Artisanal Glass Menu (${_filteredMenuItems.length})'
                              : '$_selectedCategoryId Menu (${_filteredMenuItems.length})',
                          style: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (_selectedCategoryId != 'All')
                          GestureDetector(
                            onTap: () => setState(() => _selectedCategoryId = 'All'),
                            child: const Text(
                              'Clear Filter',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF64FFDA),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 7. Interactive Glass List Rows
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _filteredMenuItems[index];
                      return _buildGlassListItem(
                        context,
                        title: item.title,
                        subtitle: item.subtitle,
                        flavour: item.flavour,
                        price: item.price,
                        icon: item.icon,
                      );
                    },
                    childCount: _filteredMenuItems.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 90.0)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildGlassCategoryChip(_CategoryData cat, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = cat.id),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.0),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: cat.id == 'All'
                      ? [
                          Colors.white.withValues(alpha: 0.28),
                          Colors.white.withValues(alpha: 0.12),
                        ]
                      : [
                          cat.flavour.tintColor.withValues(alpha: 0.45),
                          cat.flavour.tintColor.withValues(alpha: 0.18),
                        ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              cat.icon,
              size: 15.0,
              color: isSelected ? Colors.white : Colors.white60,
            ),
            const SizedBox(width: 7.0),
            Text(
              cat.label,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.70),
                letterSpacing: 0.1,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6.0),
              Container(
                width: 5.0,
                height: 5.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGlassListItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required LitchiFlavour flavour,
    required String price,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: LitchiCard(
        flavour: flavour,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        elevation: 6.0,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected $title'),
              duration: const Duration(milliseconds: 900),
            ),
          );
        },
        child: Row(
          children: [
            LitchiGlass(
              flavour: flavour,
              borderRadius: BorderRadius.circular(14.0),
              padding: const EdgeInsets.all(10.0),
              child: Icon(icon, color: Colors.white, size: 20.0),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              price,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
