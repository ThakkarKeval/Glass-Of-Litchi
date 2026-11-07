import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flavour.dart';
import 'litchi_glass.dart';

/// An interactive, dewy glass chip component for tags, filters, and choice selections.
///
/// Features Apple continuous squircle curvature, tactile spring-press physics,
/// and smooth transitions between unselected and selected glass flavours.
class LitchiChip extends StatefulWidget {
  const LitchiChip({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onSelected,
    this.onPressed,
    this.flavour = LitchiFlavour.dewy,
    this.selectedFlavour,
    this.borderRadius = const BorderRadius.all(Radius.circular(22.0)),
    this.cornerSmoothing = 0.6,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
    this.lightAngle,
    this.lightPercent,
    this.refraction,
    this.depth,
    this.dispersion,
    this.frost,
    this.splay,
    this.noise,
    this.enableHaptics = true,
    this.enableBlur = true,
    this.shaderRefraction = false,
  });

  /// Factory constructor to instantiate a [LitchiChip] directly from Figma Glass properties.
  factory LitchiChip.fromFigma({
    Key? key,
    required Widget label,
    Widget? leading,
    Widget? trailing,
    bool selected = false,
    ValueChanged<bool>? onSelected,
    VoidCallback? onPressed,
    double lightAngle = 135.0,
    double lightPercent = 75.0,
    double refraction = 20.0,
    double depth = 6.0,
    double dispersion = 20.0,
    double frost = 22.0,
    double splay = 40.0,
    double noise = 0.0,
    double cornerSmoothing = 0.6,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(22.0),
    ),
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 14.0,
      vertical: 8.0,
    ),
    bool enableHaptics = true,
    bool enableBlur = true,
    bool shaderRefraction = false,
  }) {
    return LitchiChip(
      key: key,
      label: label,
      leading: leading,
      trailing: trailing,
      selected: selected,
      onSelected: onSelected,
      onPressed: onPressed,
      borderRadius: borderRadius,
      cornerSmoothing: cornerSmoothing,
      padding: padding,
      lightAngle: lightAngle,
      lightPercent: lightPercent,
      refraction: refraction,
      depth: depth,
      dispersion: dispersion,
      frost: frost,
      splay: splay,
      noise: noise,
      enableHaptics: enableHaptics,
      enableBlur: enableBlur,
      shaderRefraction: shaderRefraction,
    );
  }

  /// Primary text or content widget inside the chip.
  final Widget label;

  /// Optional widget displayed before the label (e.g. an icon or avatar).
  final Widget? leading;

  /// Optional widget displayed after the label (e.g. a checkmark or clear icon).
  final Widget? trailing;

  /// Whether the chip is currently selected.
  final bool selected;

  /// Callback invoked when the selection state changes.
  final ValueChanged<bool>? onSelected;

  /// Optional callback invoked when the chip is tapped.
  final VoidCallback? onPressed;

  /// Aesthetic flavour preset when unselected. Defaults to [LitchiFlavour.dewy].
  final LitchiFlavour flavour;

  /// Aesthetic flavour preset when selected. Defaults to [LitchiFlavour.juicy].
  final LitchiFlavour? selectedFlavour;

  /// Corner radius for the chip pill.
  final BorderRadiusGeometry borderRadius;

  /// Apple continuous curvature squircle smoothing factor (0.0 to 1.0, default: 0.6).
  final double cornerSmoothing;

  /// Inner padding around the chip content.
  final EdgeInsetsGeometry padding;

  /// Direction of primary key light in degrees.
  final double? lightAngle;

  /// Specular peak brightness percentage (0% to 100%).
  final double? lightPercent;

  /// Optical bending index at the rim (0% to 100%).
  final double? refraction;

  /// 3D slab thickness and elevation depth (0 to 50 px).
  final double? depth;

  /// Chromatic aberration / rainbow prismatic rim intensity (0% to 100%).
  final double? dispersion;

  /// Matte diffusion / surface roughness (0% to 100%).
  final double? frost;

  /// Angular spread of the specular highlight along the perimeter (0% to 100%).
  final double? splay;

  /// Optional override for the micro-surface roughness / film grain noise (0% to 100%).
  final double? noise;

  /// Whether to invoke light haptic feedback on tap down.
  final bool enableHaptics;

  /// Whether backdrop blur is enabled.
  final bool enableBlur;

  /// Whether GPU fragment shader optical refraction is enabled.
  ///
  /// Defaults to `false` on chips to ensure 120 FPS when many chips
  /// are rendered in horizontal scrolling lists.
  final bool shaderRefraction;

  @override
  State<LitchiChip> createState() => _LitchiChipState();
}

class _LitchiChipState extends State<LitchiChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    if (widget.onSelected != null) {
      widget.onSelected!(!widget.selected);
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onSelected != null || widget.onPressed != null;

    final effectiveSelectedFlavour =
        widget.selectedFlavour ?? LitchiFlavour.juicy;
    final effectiveFlavour =
        widget.selected ? effectiveSelectedFlavour : widget.flavour;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: 6.0),
        ],
        DefaultTextStyle(
          style: TextStyle(
            color: widget.selected ? Colors.white : Colors.white70,
            fontSize: 13.0,
            fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.1,
          ),
          child: widget.label,
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: 6.0),
          widget.trailing!,
        ],
      ],
    );

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: isInteractive,
      child: GestureDetector(
        onTapDown: isInteractive
            ? (_) {
                if (widget.enableHaptics) {
                  HapticFeedback.lightImpact();
                }
                _controller.forward();
              }
            : null,
        onTapUp: isInteractive ? (_) => _controller.reverse() : null,
        onTapCancel: isInteractive ? () => _controller.reverse() : null,
        onTap: isInteractive ? _handleTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: LitchiGlass(
              flavour: effectiveFlavour,
              borderRadius: widget.borderRadius,
              cornerSmoothing: widget.cornerSmoothing,
              padding: widget.padding,
              lightAngle: widget.lightAngle,
              lightPercent: widget.lightPercent,
              refraction: widget.refraction,
              depth: widget.depth,
              dispersion: widget.dispersion,
              frost: widget.frost,
              splay: widget.splay,
              noise: widget.noise,
              enableBlur: widget.enableBlur,
              shaderRefraction: widget.shaderRefraction,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
