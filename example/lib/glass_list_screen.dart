import 'package:flutter/material.dart';

import 'color_dots_background.dart';
import 'package:glass_of_litchi/glass_of_litchi.dart';

class _CategoryData {
  final String id;
  final String label;
  final IconData icon;

  const _CategoryData({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _MenuItem {
  final String title;
  final String subtitle;
  final String categoryId;
  final String price;
  final IconData icon;
  final Color badgeColor;
  final LitchiFlavour? flavour;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.categoryId,
    required this.price,
    required this.icon,
    required this.badgeColor,
    this.flavour,
  });
}

/// A showcase screen demonstrating a rich, scrollable list of views
/// styled with the **Glass of Litchi** design system.
/// Uses a refined, modern dark titanium & fresh litchi blush aesthetic.
class GlassListScreen extends StatefulWidget {
  const GlassListScreen({super.key});

  @override
  State<GlassListScreen> createState() => _GlassListScreenState();
}

class _GlassListScreenState extends State<GlassListScreen> {
  String _selectedCategoryId = 'All';
  String _servingTemp = 'chilled';
  bool _isPlaying = true;
  double _volume = 0.7;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<_CategoryData> _categories = const [
    _CategoryData(id: 'All', label: 'All Drinks', icon: Icons.auto_awesome),
    _CategoryData(id: 'Luxury', label: 'Luxury Reserve', icon: Icons.workspace_premium_rounded),
    _CategoryData(id: 'Juicy', label: 'Juicy Pulp', icon: Icons.water_drop_rounded),
    _CategoryData(id: 'Frosted', label: 'Frosted Dew', icon: Icons.ac_unit_rounded),
    _CategoryData(id: 'Crystal', label: 'Crystal Glaze', icon: Icons.diamond_outlined),
    _CategoryData(id: 'Desserts', label: 'Milky Treats', icon: Icons.icecream_outlined),
    _CategoryData(id: 'Rose', label: 'Rose Petal', icon: Icons.spa_rounded),
    _CategoryData(id: 'Citrus', label: 'Golden Yuzu', icon: Icons.wb_sunny_rounded),
  ];

  final List<_MenuItem> _allMenuItems = const [
    _MenuItem(
      title: 'Milky Litchi Tapioca',
      subtitle: 'Creamy condensed coconut milk, fresh lychee balls',
      categoryId: 'Desserts',
      price: '\$6.20',
      icon: Icons.bubble_chart,
      badgeColor: Color(0xFFF0E6EF),
    ),
    _MenuItem(
      title: 'Juicy Lychee Fizz',
      subtitle: 'Crushed pink litchi fruit, sparkling botanical soda',
      categoryId: 'Juicy',
      price: '\$6.50',
      icon: Icons.local_bar,
      badgeColor: Color(0xFFFF5277),
    ),
    _MenuItem(
      title: 'Frosted Matcha Dew',
      subtitle: 'Ceremonial Uji green tea over clear cracked glass ice',
      categoryId: 'Frosted',
      price: '\$7.00',
      icon: Icons.eco,
      badgeColor: Color(0xFF00E676),
    ),
    _MenuItem(
      title: 'Crystal Glacier Tonic',
      subtitle: 'Ultra-clarified citrus blossom with mountain ice',
      categoryId: 'Crystal',
      price: '\$6.80',
      icon: Icons.ac_unit,
      badgeColor: Color(0xFF00E5FF),
    ),
    _MenuItem(
      title: 'Rose Petal Infusion',
      subtitle: 'Organic Damask rose elixir with sparkling mineral water',
      categoryId: 'Rose',
      price: '\$7.50',
      icon: Icons.spa,
      badgeColor: Color(0xFFFF4081),
    ),
    _MenuItem(
      title: 'Polar Ice Glacier Fizz',
      subtitle: 'High-vibrancy cerulean ice with crystallized lychee pulp',
      categoryId: 'Luxury',
      price: '\$8.80',
      icon: Icons.ac_unit_rounded,
      badgeColor: Color(0xFF38BDF8),
      flavour: LitchiFlavour.polarIce,
    ),
    _MenuItem(
      title: 'Liquid Mercury Elixir',
      subtitle: 'Ultra-reflective silver-slate botanical cold drip',
      categoryId: 'Luxury',
      price: '\$9.50',
      icon: Icons.lens_blur_rounded,
      badgeColor: Color(0xFF8B9BB4),
      flavour: LitchiFlavour.liquidMercury,
    ),
    _MenuItem(
      title: 'Smoked Quartz Nitro Brew',
      subtitle: 'Velvety dark obsidian roast with warm amber crema',
      categoryId: 'Luxury',
      price: '\$8.20',
      icon: Icons.coffee_rounded,
      badgeColor: Color(0xFFD97706),
      flavour: LitchiFlavour.smokedQuartz,
    ),
    _MenuItem(
      title: 'Golden Yuzu Fizz',
      subtitle: 'Japanese wild citrus glaze and effervescent nectar',
      categoryId: 'Citrus',
      price: '\$7.20',
      icon: Icons.wb_sunny,
      badgeColor: Color(0xFFFFB300),
    ),
  ];

  List<_MenuItem> get _filteredMenuItems {
    var items = _allMenuItems;
    if (_selectedCategoryId != 'All') {
      items = items.where((item) => item.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((item) =>
          item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q)).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientMeshBackground(),

          // 3. Scrollable list of glass views
          SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                physics: const ClampingScrollPhysics(),
                overscroll: false,
              ),
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // Search Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: LitchiTextField(
                              controller: _searchController,
                              hintText: 'Search glass beverages...',
                              prefix: const Icon(Icons.search, size: 20.0),
                              suffix: _searchQuery.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                      child: const Icon(Icons.close, size: 18.0),
                                    )
                                  : null,
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          LitchiCard(
                            flavour: LitchiFlavour.dewy,
                            borderRadius: BorderRadius.circular(16.0),
                            padding: const EdgeInsets.all(11.0),
                            elevation: 4.0,
                            onTap: () {
                              showLitchiModalBottomSheet<void>(
                                context: context,
                                builder: (ctx) => Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Glass Notifications 🔔',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12.0),
                                      const Text(
                                        '• Happy Hour: 2-for-1 on all Lychee Fizz cocktails.\n'
                                        '• New Seasonal Flavor: Frosted Matcha Dew is back!\n'
                                        '• Impeller shader pipeline preloaded and running at 120 FPS.',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white70,
                                          height: 1.6,
                                        ),
                                      ),
                                      const SizedBox(height: 24.0),
                                      LitchiButton(
                                        flavour: LitchiFlavour.juicy,
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Center(
                                          child: Text('Got It'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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

                  // Horizontal Category Chips (Clean minimalist glass pills, NO white shadow)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44.0,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8.0),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategoryId == cat.id;
                          return _buildGlassCategoryChip(cat, isSelected);
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

                  // Featured Hero Glass Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LitchiCard.fromFigma(
                        lightAngle: 135.0,
                        lightPercent: 88.0,
                        refraction: 25.0,
                        depth: 10.0,
                        dispersion: 35.0,
                        frost: 24.0,
                        splay: 45.0,
                        tintColor: const Color(0x22FF4D79),
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
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: const Text(
                                    'FEATURED COCKTAIL',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                      color: Colors.white,
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
                                        color: Colors.white,
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
                                color: Colors.white,
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
                            const SizedBox(height: 18.0),
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
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                LitchiButton(
                                  flavour: LitchiFlavour.juicy.copyWith(
                                    tintColor: const Color(0x40FF4D79),
                                  ),
                                  onPressed: () {
                                    showLitchiDialog<void>(
                                      context: context,
                                      builder: (ctx) => LitchiDialog(
                                        title: const Text('Order Spritzer? 🍹'),
                                        content: const Text(
                                          'Place an order for the signature Lychee Rose Spritzer '
                                          'with crushed litchi fruit and sparkling dewy frost?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.white60,
                                              ),
                                            ),
                                          ),
                                          LitchiButton(
                                            flavour: LitchiFlavour.juicy,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 10.0,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Ordered Lychee Rose Spritzer! 🍹',
                                                  ),
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text('Confirm Order'),
                                          ),
                                        ],
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

                  // Two-Column Glass Metrics (Clean crystal & rose accents)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: LitchiCard(
                              flavour: LitchiFlavour.dewy,
                              padding: const EdgeInsets.all(16.0),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.water_drop, color: Color(0xFF00E5FF), size: 24.0),
                                  SizedBox(height: 10.0),
                                  Text(
                                    '99.8%',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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
                              flavour: LitchiFlavour.dewy,
                              padding: const EdgeInsets.all(16.0),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.auto_awesome, color: Color(0xFFFF6E8A), size: 24.0),
                                  SizedBox(height: 10.0),
                                  Text(
                                    '12.4k',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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

                  // Glass Media Player Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LitchiCard(
                        flavour: LitchiFlavour.dewy,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                LitchiGlass(
                                  flavour: LitchiFlavour.dewy,
                                  borderRadius: BorderRadius.circular(12.0),
                                  padding: const EdgeInsets.all(12.0),
                                  child: const Icon(
                                    Icons.graphic_eq,
                                    color: Color(0xFFFF5277),
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
                                          color: Colors.white,
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
                                activeTrackColor: const Color(0xFFFF5277),
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.white,
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

                  // Serving Style Segmented Control
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LitchiSegmentedControl<String>(
                        selectedValue: _servingTemp,
                        onValueChanged: (val) =>
                            setState(() => _servingTemp = val),
                        segments: const [
                          LitchiSegment(
                            value: 'chilled',
                            label: Text('Ice Chilled'),
                            icon: Icon(Icons.ac_unit, size: 15.0),
                          ),
                          LitchiSegment(
                            value: 'ambient',
                            label: Text('Ambient'),
                            icon: Icon(Icons.thermostat, size: 15.0),
                          ),
                          LitchiSegment(
                            value: 'sparkling',
                            label: Text('Sparkling'),
                            icon: Icon(Icons.bubble_chart, size: 15.0),
                            badgeText: 'HOT',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12.0)),

                  // Section Header
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
                              color: Colors.white,
                            ),
                          ),
                          if (_selectedCategoryId != 'All')
                            GestureDetector(
                              onTap: () => setState(() => _selectedCategoryId = 'All'),
                              child: const Text(
                                'Clear Filter',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Color(0xFF00E5FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Interactive Glass List Rows
                  BackdropGroup(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = _filteredMenuItems[index];
                          return _buildGlassListItem(
                            context,
                            title: item.title,
                            subtitle: item.subtitle,
                            price: item.price,
                            icon: item.icon,
                            badgeColor: item.badgeColor,
                            flavour: item.flavour,
                          );
                        },
                        childCount: _filteredMenuItems.length,
                      ),
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
    return LitchiChip(
      leading: Icon(
        cat.icon,
        size: 15.0,
        color: isSelected ? Colors.white : Colors.white60,
      ),
      label: Text(cat.label),
      selected: isSelected,
      flavour: LitchiFlavour.dewy,
      selectedFlavour: LitchiFlavour.juicy,
      onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
    );
  }

  Widget _buildGlassListItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
    required Color badgeColor,
    LitchiFlavour? flavour,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: LitchiCard(
        flavour: flavour ?? LitchiFlavour.dewy,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        elevation: 6.0,
        shaderRefraction: false,
        groupBackdrop: true,
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
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: Icon(icon, color: badgeColor, size: 20.0),
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
                      color: Colors.white,
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
