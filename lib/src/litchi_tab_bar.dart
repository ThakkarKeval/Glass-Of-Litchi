import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flavour.dart';
import 'litchi_glass.dart';
import 'squircle.dart';

/// Represents a single navigation destination item in a [LitchiTabBar].
class LitchiTabItem {
  const LitchiTabItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badgeText,
  });

  /// The icon displayed when the tab is unselected.
  final IconData icon;

  /// Optional icon displayed when the tab is selected.
  final IconData? selectedIcon;

  /// The text label for the tab.
  final String label;

  /// Optional badge text displayed next to or above the label (e.g. count or dot).
  final String? badgeText;
}

/// A signature floating glass navigation bar featuring an animated, sliding
/// liquid squircle selection pill that squashes and stretches with spring physics.
///
/// Supports Figma Glass optics, Apple continuous corner curvature, and tactile haptics.
class LitchiTabBar extends StatefulWidget {
  const LitchiTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.flavour = LitchiFlavour.dewy,
    this.borderRadius = const BorderRadius.all(Radius.circular(32.0)),
    this.cornerSmoothing = 0.6,
    this.pillColor,
    this.pillBorderColor,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white60,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    this.enableHaptics = true,
    this.enableBlur = true,
    this.shaderRefraction = true,
  }) : assert(items.length >= 2, 'LitchiTabBar requires at least 2 items.');

  /// The list of tab destinations.
  final List<LitchiTabItem> items;

  /// The currently active tab index (0-based).
  final int selectedIndex;

  /// Callback invoked when a tab is selected.
  final ValueChanged<int> onTabSelected;

  /// The aesthetic glass flavour for the navigation bar container.
  final LitchiFlavour flavour;

  /// Corner radius of the floating glass bar.
  final BorderRadiusGeometry borderRadius;

  /// Apple continuous squircle curvature factor (0.0 to 1.0, default: 0.6).
  final double cornerSmoothing;

  /// Custom fill color for the sliding glass selection pill.
  final Color? pillColor;

  /// Custom border color for the sliding glass selection pill.
  final Color? pillBorderColor;

  /// Text and icon color for the active tab.
  final Color activeColor;

  /// Text and icon color for inactive tabs.
  final Color inactiveColor;

  /// Inner padding around the tab items inside the glass bar.
  final EdgeInsetsGeometry padding;

  /// Whether to invoke selection haptic feedback on tab changes.
  final bool enableHaptics;

  /// Whether backdrop blur is enabled for the navigation bar container.
  final bool enableBlur;

  /// Whether GPU fragment shader optical refraction and dispersion are enabled.
  final bool shaderRefraction;

  @override
  State<LitchiTabBar> createState() => _LitchiTabBarState();
}

class _LitchiTabBarState extends State<LitchiTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pillController;
  late Animation<double> _pillAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _pillAnimation = CurvedAnimation(
      parent: _pillController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(covariant LitchiTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _pillController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pillController.dispose();
    super.dispose();
  }

  void _handleTabTap(int index) {
    if (index == widget.selectedIndex) return;
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    widget.onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    // Ultra-clean crystal glass pill without milky chalk fog
    final effectivePillColor = widget.pillColor ??
        const Color(0x18FFFFFF);
    final effectivePillBorderColor = widget.pillBorderColor ??
        Colors.white.withValues(alpha: 0.22);

    final effectiveFlavour = widget.flavour.copyWith(
      tintColor: const Color(0x0AFFFFFF),
      innerSheen: false,
      specularOpacity: 0.38,
      borderWidth: 0.8,
    );

    return LitchiGlass(
      flavour: effectiveFlavour,
      borderRadius: widget.borderRadius,
      cornerSmoothing: widget.cornerSmoothing,
      padding: widget.padding,
      enableBlur: widget.enableBlur,
      shaderRefraction: widget.shaderRefraction,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final tabCount = widget.items.length;
          final tabWidth = totalWidth / tabCount;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // 1. Sliding Liquid Glass Selection Pill with Spring Deformation
              AnimatedBuilder(
                animation: _pillAnimation,
                builder: (context, child) {
                  final t = _pillAnimation.value;
                  // Interpolate horizontal position between previous and target tab
                  final startX = _previousIndex * tabWidth;
                  final targetX = widget.selectedIndex * tabWidth;
                  final currentX = startX + (targetX - startX) * t;

                  // Fluid squash & stretch physics during motion
                  final travelDelta = (targetX - startX).abs();
                  final progress = _pillController.value;
                  // Stretch peaks at mid-transit (progress = 0.5)
                  final stretchFactor = travelDelta > 0
                      ? (1.0 + (1.0 - (progress - 0.5).abs() * 2.0) * 0.08)
                      : 1.0;

                  return Positioned(
                    left: currentX + (tabWidth * (1.0 - stretchFactor) / 2.0),
                    width: tabWidth * stretchFactor,
                    top: 0,
                    bottom: 0,
                    child: child!,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  decoration: ShapeDecoration(
                    color: effectivePillColor,
                    shape: _SquircleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      cornerSmoothing: widget.cornerSmoothing,
                      side: BorderSide(
                        color: effectivePillBorderColor,
                        width: 1.0,
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Tab Items Row
              Row(
                children: List.generate(tabCount, (index) {
                  final item = widget.items[index];
                  final isSelected = widget.selectedIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _handleTabTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? widget.activeColor : widget.inactiveColor,
                            letterSpacing: -0.1,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                                size: 19.0,
                                color: isSelected ? widget.activeColor : widget.inactiveColor,
                              ),
                              const SizedBox(width: 7.0),
                              Text(item.label),
                              if (item.badgeText != null) ...[
                                const SizedBox(width: 5.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5277),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    item.badgeText!,
                                    style: const TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ShapeBorder that clips and borders along an Apple squircle path.
class _SquircleBorder extends ShapeBorder {
  const _SquircleBorder({
    required this.borderRadius,
    this.cornerSmoothing = 0.6,
    this.side = BorderSide.none,
  });

  final BorderRadius borderRadius;
  final double cornerSmoothing;
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return SquirclePath.create(
      rect: rect.deflate(side.width),
      borderRadius: borderRadius,
      smoothing: cornerSmoothing,
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return SquirclePath.create(
      rect: rect,
      borderRadius: borderRadius,
      smoothing: cornerSmoothing,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width <= 0.0) return;

    final path = SquirclePath.create(
      rect: rect.deflate(side.width / 2.0),
      borderRadius: borderRadius,
      smoothing: cornerSmoothing,
    );
    final paint = side.toPaint();
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return _SquircleBorder(
      borderRadius: borderRadius * t,
      cornerSmoothing: cornerSmoothing,
      side: side.scale(t),
    );
  }
}
